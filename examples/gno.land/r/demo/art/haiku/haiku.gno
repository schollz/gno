package haiku

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"regexp"
	"std"
	"strings"
	"time"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/grc/grc721"
	"gno.land/p/demo/ufmt"
	"gno.land/r/demo/users"
)

// globals
var (
	pageURL              = "/r/demo/art/haiku"
	nonAlphanumericRegex = regexp.MustCompile(`[^a-zA-Z ]+`)
	wordsWithSyllables   avl.Tree
	nftName              = "TextNFT"
	nftSymbol            = "NFTEXT"
	nfts                 *grc721.BasicNFT
	nftDB                avl.Tree // tokenID (string) -> haikuAmulet
)

// errors
var (
	ErrNotEnglish          error  = errors.New("non-english word detected")
	ErrIncorrectLineNumber error  = errors.New("incorrect number of lines")
	ErrIncorrectSyllables  error  = errors.New("incorrect number of syllables")
	StatusNotFound         string = "404"
)

func init() {
	nfts = grc721.NewBasicNFT(nftName, nftSymbol)
	nftDB = avl.Tree{}
	// load dicitionary of words
	wordsWithSyllables = avl.Tree{}
	for _, line := range strings.Split(rawwordlist, "\n") {
		line = strings.TrimSpace(line)
		word := strings.Replace(line, ";", "", -1)
		wordsWithSyllables.Set(word, strings.Count(line, ";")+1)
	}
}

// sanitizeString will remove puncuation and extra spaces that might
// be used to "game" the contract.
func sanitizeString(unclean string) string {
	cleaned := ""
	for _, line := range strings.Split(unclean, "\n") {
		line = strings.Join(strings.Fields(nonAlphanumericRegex.ReplaceAllString(line, "")), " ")
		if line != "" {
			cleaned += line + "\n"
		}
	}
	cleaned = strings.ToLower(cleaned)
	cleaned = strings.TrimSpace(cleaned)
	return cleaned
}

// countSyllables will count the syllables in a line
// and return an error if a non-english word is detected
func countSyllables(line string) (numSyllables int, err error) {
	for _, word := range strings.Fields(line) {
		v, ok := wordsWithSyllables.Get(word)
		if !ok {
			v, ok = wordsWithSyllables.Get(word + "s")
			if !ok {
				v, ok = wordsWithSyllables.Get(strings.TrimSuffix(word, "s"))
				if !ok {
					v, ok = wordsWithSyllables.Get(strings.TrimSuffix(word, "ed"))
					if !ok {
						err = errors.New(ufmt.Sprintf("'%s' is not an english word", word))
						return
					} else {
						numSyllables += v.(int)
					}
				} else {
					numSyllables += v.(int)
				}
			} else {
				numSyllables += v.(int)
			}
		} else {
			numSyllables += v.(int)
		}
	}
	return
}

// isHaiku determines whether the text contains
// three lines and syllables of each line is
// 5-7-5. the text is assumed to be sanitized.
func isHaiku(text string) (err error) {
	text = strings.Replace(text, `\n`, "\n", -1)
	lines := strings.Split(strings.TrimSpace(text), "\n")
	if len(lines) != 3 {
		return errors.New(ufmt.Sprintf("incorrect number of lines: %d != 3", len(lines)))
	}
	v, err := countSyllables(lines[0])
	if err != nil {
		return
	}
	if v != 5 {
		return errors.New(ufmt.Sprintf("incorrect number of syllables: %d != 5 for '%s'", v, lines[0]))
	}
	v, err = countSyllables(lines[1])
	if err != nil {
		return
	}
	if v != 7 {
		return errors.New(ufmt.Sprintf("incorrect number of syllables: %d != 7 for '%s'", v, lines[1]))
	}
	v, err = countSyllables(lines[2])
	if err != nil {
		return
	}
	if v != 5 {
		return errors.New(ufmt.Sprintf("incorrect number of syllables: %d != 5 for '%s'", v, lines[2]))
	}
	return
}

// The number of sequential 8s in the hash determines the rarity of the haiku:
//
//	8888: common
//	88888: uncommon
//	888888: rare
//	8888888: epic
//	88888888: legendary
//	888888888: mythic
//	8888888888+: ???
//
// https://archive.is/IADSf
// arbitrary/artificial scarcity
func calculateRarity(s string) string {
	res := 0
	resBest := 0
	for _, v := range s {
		if string(v) == "8" {
			res++
			if res > resBest {
				resBest = res
			}
		} else {
			res = 0
		}
	}
	if resBest <= 4 {
		return "common"
	} else if resBest == 5 {
		return "uncommon"
	} else if resBest == 6 {
		return "rare"
	} else if resBest == 7 {
		return "epic"
	} else if resBest == 8 {
		return "legendary"
	} else {
		return "mythic"
	}
}

type haikuAmulet struct {
	Text      string
	TokenID   string
	Rarity    string
	CreatedAt time.Time
	CreatedBy std.Address
}

func (ha *haikuAmulet) String() string {
	tokenid := ha.TokenID
	for _, s := range []string{"888888888", "88888888", "8888888", "888888", "88888", "8888", "888", "88", "8"} {
		if strings.Contains(tokenid, s) {
			tokenid = strings.Replace(tokenid, s, "***"+s+"***", 1)
			break
		}
	}
	render := ufmt.Sprintf("### [%s](%s:%s)\n\n", tokenid, pageURL, ha.TokenID)
	render += "```\n" + ha.Text + "\n```\n\n"
	render += ufmt.Sprintf("[rarity](%s:rarity): **", pageURL) + ha.Rarity + "**\n\n"
	render += "*created on " + ha.CreatedAt.Format(time.RFC1123) + " "
	render += "by " + renderUserAddress(ha.CreatedBy) + ", "
	owner, err := nfts.OwnerOf(grc721.TokenID(ha.TokenID))
	if err == nil {
		render += "collected by " + renderUserAddress(owner)
	}
	render += "*"
	render += "\n\n"
	return render
}

func Mint(text string) string {
	// basic sanitiziation
	text = strings.Replace(text, `\n`, "\n", -1)
	text = strings.TrimSpace(text)
	// under-the-hood sanitation
	cleanedText := sanitizeString(text)
	println(cleanedText)
	if err := isHaiku(cleanedText); err != nil {
		println(cleanedText)
		return err.Error()
	}

	var buf bytes.Buffer
	buf.Write([]byte(cleanedText))
	hash := sha256.Sum256(buf.Bytes())
	hashHex := hex.EncodeToString(hash[:])
	rarity := calculateRarity(hashHex)
	ha := haikuAmulet{
		Text:      text,
		TokenID:   hashHex,
		Rarity:    rarity,
		CreatedAt: time.Now(),
		CreatedBy: std.GetOrigCaller(),
	}

	err := nfts.Mint(std.GetOrigCaller(), grc721.TokenID(ha.TokenID))
	if err != nil {
		return err.Error()
	}

	nftDB.Set(ha.TokenID, &ha)
	return ""
}

func renderUserAddress(addr std.Address) string {
	if u := users.GetUserByAddress(addr); u != nil {
		return ufmt.Sprintf("[%s](/r/demo/users:%s)", u.Name(), u.Name())
	}
	return addr.String()
}

func renderAll() string {
	render := "# haikus\n\n"
	nftDB.Iterate("", "", func(key string, value interface{}) bool {
		ha := value.(*haikuAmulet)
		render += ha.String()
		return false
	})
	return render
}

func renderSingle(tokenid string) string {
	value, found := nftDB.Get(tokenid)
	if !found {
		return StatusNotFound
	}
	ha := value.(*haikuAmulet)
	return ha.String()
}

func Render(path string) string {
	if path == "" {
		return renderAll()
	} else if path == "rarity" {
		return `## about "rarity"

The number of sequential 8s in the SHA-256 hash of the sanitized text determines the rarity of the haiku:

	8888: common
	88888: uncommon
	888888: rare
	8888888: epic
	88888888: legendary
	888888888+: mythic

Please note that a haiku should be judged by its total effect and not simply by its adherence to this arbitrary definition of rarity.
	`
	} else {
		return renderSingle(path)
	}
}

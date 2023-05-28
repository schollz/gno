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
)

// globals
var (
	nonAlphanumericRegex = regexp.MustCompile(`[^a-zA-Z ]+`)
	wordsWithSyllables   map[string]int
	nftName              = "TextNFT"
	nftSymbol            = "NFTEXT"
	nfts                 *grc721.BasicNFT
	nftDB                avl.Tree // tokenID (string) -> haikuAmulet
)

// errors
var (
	ErrNotEnglish          error = errors.New("non-english word detected")
	ErrIncorrectLineNumber error = errors.New("incorrect number of lines")
	ErrIncorrectSyllables  error = errors.New("incorrect number of syllables")
)

func init() {
	nfts = grc721.NewBasicNFT(nftName, nftSymbol)
	nftDB = avl.Tree{}
	// load dicitionary of words
	wordsWithSyllables = make(map[string]int)
	for _, line := range strings.Split(rawwordlist, "\n") {
		line = strings.TrimSpace(line)
		word := strings.Replace(line, ";", "", -1)
		wordsWithSyllables[word] = strings.Count(line, ";") + 1
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
		v, ok := wordsWithSyllables[word]
		if !ok {
			err = errors.New(ufmt.Sprintf("'%s' is not an english word", word))
			return
		}
		numSyllables += v
	}
	return
}

// isHaiku determines whether the text contains
// three lines and syllables of each line is
// 5-7-5. the text is assumed to be sanitized.
func isHaiku(text string) (err error) {
	text = strings.TrimSpace(text)
	lines := strings.Split(text, "\n")
	if len(lines) != 3 {
		return ErrIncorrectLineNumber
	}
	v, err := countSyllables(lines[0])
	if err != nil {
		return
	}
	if v != 5 {
		return ErrIncorrectSyllables
	}
	v, err = countSyllables(lines[1])
	if err != nil {
		return
	}
	if v != 7 {
		return ErrIncorrectSyllables
	}
	v, err = countSyllables(lines[2])
	if err != nil {
		return
	}
	if v != 5 {
		return ErrIncorrectSyllables
	}
	return
}

// The number of sequential 8s in the hash determines the rarity of the amulet:
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
// https://twitter.com/WildAmulet/status/1374506730575437828
func calculateRarity(s string) int {
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
	return resBest
}

func listAllNFTs() (ha []*haikuAmulet) {
	ha = make([]*haikuAmulet, nftDB.Size())
	i := 0
	nftDB.Iterate("", "", func(key string, value interface{}) bool {
		ha[i] = value.(*haikuAmulet)
		i++
		return false
	})
	return
}

type haikuAmulet struct {
	Text      string
	TokenID   string
	Rarity    int
	CreatedAt time.Time
}

func Mint(text string) string {
	cleanedText := sanitizeString(text)
	if err := isHaiku(cleanedText); err != nil {
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
	}

	err := nfts.Mint(std.GetOrigCaller(), grc721.TokenID(ha.TokenID))
	if err != nil {
		return err.Error()
	}

	nftDB.Set(ha.TokenID, &ha)
	return ""
}

func Render(path string) string {
	return path
}

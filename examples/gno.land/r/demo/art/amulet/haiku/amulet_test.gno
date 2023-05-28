package amulet

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"regexp"
	"strings"
	"testing"

	"gno.land/p/demo/ufmt"
)

var (
	ErrNotEnglish          error = errors.New("non-english word detected")
	ErrIncorrectLineNumber error = errors.New("incorrect number of lines")
	ErrIncorrectSyllables  error = errors.New("incorrect number of syllables")
	nonAlphanumericRegex         = regexp.MustCompile(`[^a-zA-Z ]+`)
	wordsWithSyllables     map[string]int
)

func init() {
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
	return nil
}

type HaikuAmulet struct {
	Text string
	Hash string
}

func Mint(text string) string {
	cleanedText := sanitizeString(text)
	var buf bytes.Buffer
	buf.Write([]byte(cleanedText))
	hash := sha256.Sum256(buf.Bytes())
	hashHex := hex.EncodeToString(hash[:])
	println(cleanedText)
	println(hashHex)
	return cleanedText
}

func TestAmulet(t *testing.T) {
	ok := Mint("hi.!as89 jf3s89fjk\nsome   someklj ")
	println(ok)
	println(wordsWithSyllables["butter"])

	haiku := `yes web three is here
	now you can own your data
the future is bright`
	if err := isHaiku(haiku); err != nil {
		t.Errorf("%s", err)
	}
}

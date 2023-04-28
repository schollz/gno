package wav

import (
	"bufio"
	"bytes"
	"testing"
)

func TestWav(t *testing.T) {
	var buf bytes.Buffer
	w := NewWriter(bufio.NewWriter(&buf), []byte("wav"), 100)
	if w == nil {
		t.Errorf("could not make")
	}
}

package bytebeat

import (
	"testing"
)

func TestByteBeat(t *testing.T) {
	s := Render("")
	if len(s) != 42862 {
		t.Errorf("correct len: %d", len(s))
	}
	println(s)
}

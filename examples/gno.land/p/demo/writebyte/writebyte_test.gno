package writebyte

import (
	"testing"
)

func TestWriteByte(t *testing.T) {
	data := WriteByte()
	if data != "" {
		t.Errorf("should return nothing")
	}
}

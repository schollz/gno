package bytebeat

import (
	"encoding/base64"
	"strings"
	"testing"
)

func TestByteBeat(tt *testing.T) {
	data := ByteBeat(4, 8000, func(t int) int {
		return (t>>4)*(t>>2) | t>>(t>>12)%4
	})
	if strings.Contains(data, "error") {
		tt.Fatalf("%s", data)
	}

	// TRY AT HOME: write bytes to base64
	println(data)
	// save to bytes.base64
	// using sox:
	// base64 -d bytes.base64 | play
}

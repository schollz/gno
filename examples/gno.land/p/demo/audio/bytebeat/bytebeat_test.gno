package bytebeat

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"testing"
)

func TestByteBeat(tt *testing.T) {
	var b bytes.Buffer
	foo := bufio.NewWriter(&b)
	err := ByteBeat(foo, 3, 8000, func(t int) int {
		return (t>>10^t>>11)%5*((t>>14&3^t>>15&1)+1)*t%99 + ((3 + (t >> 14 & 3) - (t >> 16 & 1)) / 3 * t % 99 & 64)
	})
	if err != nil {
		tt.Fatalf("%s", err)
	}
	err = foo.Flush()
	if err != nil {
		tt.Fatalf("%s", err)
	}

	// TRY AT HOME: write bytes to base64
	// println(base64.StdEncoding.EncodeToString(b.Bytes()))
	// save to bytes.base64
	// using sox:
	// base64 -d bytes.base64 | play
}

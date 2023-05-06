package bytebeat

import (
	"bufio"
	"bytes"
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

	// TRY AT HOME: write bytes to file
	// f, _ := os.Create("test.wav")
	// f.Write(b.Bytes())
	// f.Close()
	// you can now play the bytebeat "test.wav"
}

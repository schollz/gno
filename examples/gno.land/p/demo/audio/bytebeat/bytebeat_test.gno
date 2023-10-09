package bytebeat

import (
	"strings"
	"testing"
)

func TestByteBeat(tt *testing.T) {
	data := ByteBeat(10, 8000, func(t int) int {
		// http://macumbista.net/wp-content/uploads/2016/11/music_formula_collection.txt
		return (t>>10^t>>11)%5*((t>>14&3^t>>15&1)+1)*t%99 + ((3 + (t >> 14 & 3) - (t >> 16 & 1)) / 3 * t % 99 & 64)
	})
	if strings.Contains(data, "error") {
		tt.Fatalf("%s", data)
	}

	// TRY AT HOME: write bytes to base64
	// uncomment this line:
	println(data)
	// then run:
	// $ gno test --verbose examples/gno.land/p/demo/audio/bytebeat | base64 -d > bytebeat.wav
	// $ play bytebeat.wav
}

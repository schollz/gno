package bytebeat

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"math"

	wav "gno.land/p/demo/audio/wav/v1"
	"gno.land/p/demo/ufmt"
)

func ByteBeat(seconds uint32, sampleRate uint32, bytebeat_func func(t int) int) (data string) {
	b := new(bytes.Buffer)
	w := bufio.NewWriter(b)

	var numSamples uint32 = sampleRate * seconds
	var numChannels uint16 = 1
	var bitsPerSample uint16 = 16

	writer, err := wav.NewWriter(w, numSamples, numChannels, sampleRate, bitsPerSample)
	if err != nil {
		data = ufmt.Sprintf("error: %s", err)
		return
	}

	samples := make([]wav.Sample, numSamples)
	for i := int(0); i < int(numSamples); i++ {
		samples[i].Values[0] = bytebeat_func(i) * 10 // increase volume
	}

	err = writer.WriteSamples(samples)
	if err != nil {
		data = ufmt.Sprintf("error: %s", err)
		return
	}

	w.Flush()

	data = base64.StdEncoding.EncodeToString(b.Bytes())
	return
}

package bytebeat

import (
	"io"
	"math"

	"github.com/gnolang/gno/examples/gno.land/p/demo/audio/biquad"
	"github.com/gnolang/gno/examples/gno.land/p/demo/audio/wav"
)

func ByteBeat(w io.Writer, seconds uint32, sampleRate uint32, bytebeat_func func(t int) int) (err error) {
	var numSamples uint32 = sampleRate * seconds
	var numChannels uint16 = 1
	var bitsPerSample uint16 = 16

	writer, err := wav.NewWriter(w, numSamples*2, numChannels, sampleRate, bitsPerSample)
	if err != nil {
		return
	}

	samples := make([]wav.Sample, numSamples)
	maxValue := 0
	lastValue := 0
	for i := int(0); i < int(numSamples); i++ {
		lastValue = bytebeat_func(i)
		samples[i].Values[0] = lastValue
		if samples[i].Values[0] > maxValue {
			maxValue = samples[i].Values[0]
		}
	}

	// normalize samples
	for i := uint32(0); i < numSamples; i++ {
		samples[i].Values[0] = (samples[i].Values[0] * 28000 / maxValue)
	}

	// highpass filter
	hpf := biquad.New(10, float64(sampleRate), 0.707, 0, "highpass")
	for i := uint32(0); i < numSamples; i++ {
		samples[i].Values[0] = int(math.Round(hpf.Update(float64(samples[i].Values[0]))))
	}
	//lowpass
	lpf := biquad.New(float64(sampleRate)*0.25, float64(sampleRate), 0.707, 0, "lowpass")
	for i := uint32(0); i < numSamples; i++ {
		samples[i].Values[0] = int(math.Round(lpf.Update(float64(samples[i].Values[0]))))
	}

	err = writer.WriteSamples(samples)
	if err != nil {
		return
	}

	err = writer.WriteSamples(samples)
	if err != nil {
		return
	}
	return
}

package wav

import (
	"io"
	"math"
	"os"
	"testing"

	"github.com/gnolang/gno/examples/gno.land/p/demo/audio/biquad"
	"github.com/gnolang/gno/examples/gno.land/p/demo/audio/riff"
)

func TestWav(t *testing.T) {
	outfile, err := os.Create("test.wav")
	if err != nil {
		t.Fatal(err)
	}

	var numSamples uint32 = 2
	var numChannels uint16 = 2
	var sampleRate uint32 = 44100
	var bitsPerSample uint16 = 16

	writer, err := NewWriter(outfile, numSamples, numChannels, sampleRate, bitsPerSample)
	if err != nil {
		t.Fatal(err)
	}
	samples := make([]Sample, numSamples)

	samples[0].Values[0] = 32767
	samples[0].Values[1] = -32768
	samples[1].Values[0] = 123
	samples[1].Values[1] = -123

	err = writer.WriteSamples(samples)
	if err != nil {
		t.Fatal(err)
	}

	outfile.Close()
}

func ByteBeat1(t int) int {
	return (t>>10^t>>11)%5*((t>>14&3^t>>15&1)+1)*t%99 + ((3 + (t >> 14 & 3) - (t >> 16 & 1)) / 3 * t % 99 & 64)
}

func TestByteBeat(t *testing.T) {
	outfile, err := os.Create("bytebeat.wav")
	if err != nil {
		t.Fatal(err)
	}

	var seconds uint32 = 2
	var sampleRate uint32 = 8000
	var numSamples uint32 = sampleRate * seconds
	var numChannels uint16 = 1
	var bitsPerSample uint16 = 16

	writer, err := NewWriter(outfile, numSamples*2, numChannels, sampleRate, bitsPerSample)
	if err != nil {
		t.Fatal(err)
	}
	samples := make([]Sample, numSamples)
	maxValue := 0
	lastValue := 0
	j := 0
	for i := uint32(0); i < numSamples; i++ {
		if i%1 == 0 {
			j++
			lastValue = ByteBeat1(j)
		}
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
		t.Fatal(err)
	}

	err = writer.WriteSamples(samples)
	if err != nil {
		t.Fatal(err)
	}

	outfile.Close()
}

const (
	AudioFormatPCM       = 1
	AudioFormatIEEEFloat = 3
	AudioFormatALaw      = 6
	AudioFormatMULaw     = 7
)

type WavFormat struct {
	AudioFormat   uint16
	NumChannels   uint16
	SampleRate    uint32
	ByteRate      uint32
	BlockAlign    uint16
	BitsPerSample uint16
}

type WavData struct {
	io.Reader
	Size uint32
	pos  uint32
}

type Sample struct {
	Values [2]int
}

type Writer struct {
	io.Writer
	Format *WavFormat
}

func NewWriter(w io.Writer, numSamples uint32, numChannels uint16, sampleRate uint32, bitsPerSample uint16) (writer *Writer, err error) {
	blockAlign := numChannels * bitsPerSample / 8
	byteRate := sampleRate * uint32(blockAlign)
	format := &WavFormat{AudioFormatPCM, numChannels, sampleRate, byteRate, blockAlign, bitsPerSample}
	dataSize := numSamples * uint32(format.BlockAlign)
	riffSize := 4 + 8 + 16 + 8 + dataSize
	riffWriter, err := riff.NewWriter(w, []byte("WAVE"), riffSize)

	writer = &Writer{riffWriter, format}
	riffWriter.WriteChunk([]byte("fmt "), 16)
	riffWriter.WriteUint16(format.AudioFormat)
	riffWriter.WriteUint16(format.NumChannels)
	riffWriter.WriteUint32(format.SampleRate)
	riffWriter.WriteUint32(format.ByteRate)
	riffWriter.WriteUint16(format.BlockAlign)
	riffWriter.WriteUint16(format.BitsPerSample)
	riffWriter.WriteChunk([]byte("data"), dataSize)
	return
}

func (w *Writer) WriteSamples(samples []Sample) (err error) {
	bitsPerSample := w.Format.BitsPerSample
	numChannels := w.Format.NumChannels

	var i, b uint16
	var by []byte
	for _, sample := range samples {
		for i = 0; i < numChannels; i++ {
			value := toUint(sample.Values[i], int(bitsPerSample))

			for b = 0; b < bitsPerSample; b += 8 {
				by = append(by, uint8((value>>b)&math.MaxUint8))
			}
		}
	}

	_, err = w.Write(by)
	return
}

func toUint(value int, bits int) uint {
	var result uint

	switch bits {
	case 32:
		result = uint(uint32(value))
	case 16:
		result = uint(uint16(value))
	case 8:
		result = uint(value)
	default:
		if value < 0 {
			result = uint((1 << uint(bits)) + value)
		} else {
			result = uint(value)
		}
	}

	return result
}

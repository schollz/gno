package wav

import (
	"io"
	"math"

	"github.com/gnolang/gno/examples/gno.land/p/demo/audio/riff"
)

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

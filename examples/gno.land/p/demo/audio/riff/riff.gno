// riff is the basic writer for
// creating wav files which enables
// multiple types, according to the spec
// http://soundfile.sapp.org/doc/WaveFormat/
package riff

import (
	"encoding/binary"
	"io"
)

type Writer struct {
	io.Writer
}

func NewWriter(w io.Writer, fileType []byte, fileSize uint32) (w2 *Writer, err error) {
	w2 = &Writer{w}
	_, err = w2.Write([]byte("RIFF"))
	if err != nil {
		return
	}
	// convert filesize to uint32
	fileSizeBytes := make([]byte, 4)
	binary.LittleEndian.PutUint32(fileSizeBytes, fileSize)

	_, err = w2.Write(fileSizeBytes)
	if err != nil {
		return
	}
	_, err = w2.Write(fileType)
	if err != nil {
		return
	}
	return
}

func (w *Writer) WriteChunk(chunkID []byte, chunkSize uint32) (n int, err error) {
	n1, err := w.Write(chunkID)
	n = n1
	if err != nil {
		return
	}

	chunkSizeBytes := make([]byte, 4)
	binary.LittleEndian.PutUint32(chunkSizeBytes, chunkSize)

	n2, err := w.Write(chunkSizeBytes)
	n += n2
	return
}

func (w *Writer) WriteUint32(v uint32) (n int, err error) {
	b := make([]byte, 4)
	binary.LittleEndian.PutUint32(b, v)
	n, err = w.Write(b)
	return
}

func (w *Writer) WriteUint16(v uint16) (n int, err error) {
	b := make([]byte, 2)
	binary.LittleEndian.PutUint16(b, v)
	n, err = w.Write(b)
	return
}

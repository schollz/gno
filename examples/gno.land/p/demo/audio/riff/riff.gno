package riff

import (
	"encoding/binary"
	"io"
)

type Writer struct {
	io.Writer
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

func NewWriter(w io.Writer, fileType []byte, fileSize uint32) (w2 *Writer, err error) {
	w2 = &Writer{w}
	_, err = w2.Write([]byte("RIFF"))
	if err != nil {
		return
	}
	// write as uint32
	w2.WriteUint32(fileSize)
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

	n2, err := w.WriteUint32(chunkSize)
	n += n2
	return
}

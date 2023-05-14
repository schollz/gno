package writebyte

import (
	"bufio"
	"bytes"
)

func WriteByte() (data string) {
	var b bytes.Buffer
	w := bufio.NewWriter(&b)
	_ = w
	return
}

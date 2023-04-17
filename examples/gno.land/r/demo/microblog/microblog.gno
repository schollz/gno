package microblog

import (
	"gno.land/p/demo/microblog"
)

var (
	name = "gno-based microblog"
	m    *microblog.Microblog
)

func init() {
	m = microblog.NewMicroblog()
}

package microblog

import (
	"std"

	"gno.land/p/demo/microblog"
)

var (
	title  = "gno-based microblog"
	prefix = "/r/demo/microblog:"
	m      *microblog.Microblog
)

func init() {
	m = microblog.NewMicroblog(title, prefix)
}

func Render(path string) string {
	return m.Render(path)
}

func NewPost(text string) string {
	if m.NewPost(text) == "" {
		return "unable to add new post"
	}
	return "added new post"
}

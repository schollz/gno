package keystore

import (
	"strings"

	"gno.land/p/demo/avl"
)

var data avl.Tree

func init() {
	data = avl.Tree{}
}

func Set(k, v string) string {
	data.Set(k, v)
	return "ok"
}

func Get(k string) string {
	dat, found := data.Get(k)
	if !found {
		return "404"
	}
	return dat.(string)
}

func Render(p string) string {
	if strings.HasPrefix(p, "set:") {
		kv := strings.Split(strings.TrimPrefix(p, "set:"), ":")
		if len(kv) == 2 {
			return Set(kv[0], kv[1])
		} else {
			return "incorrect :"
		}
	} else if strings.HasPrefix(p, "get:") {
		return Get(strings.TrimPrefix(p, "get:"))
	} else {
		return "404"
	}
}

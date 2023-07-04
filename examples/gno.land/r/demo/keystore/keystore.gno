package keystore

import (
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
	return Get(p)
}

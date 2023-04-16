package microblog

import (
	"errors"
	"std"
	"strconv"
	"strings"
	"time"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
)

type Domain struct {
	Title  string
	Prefix string   // i.e. r/gnoland/blog:
	Silos  avl.Tree // std.Address -> Silo
}

type Silo struct {
	Author    std.Address
	CreatedAt time.Time
}

func (d Domain) Render(path string) string {
	parts := strings.Split(path, "/")

	isHome := path == ""
	isUser := len(parts) == 2

	switch {
	case isHome:
		output := "home"

		return output

	case isUser:
		user := parts[1]

		silo, found := d.Silos.Get(user)
		if !found {
			return "404"
		}
		s := silo.(*Silo)

		output = s.Author

		return output
	}

	return "404"
}

func (d *Domain) NewSilo(author std.Address) error {
	_, found := d.Silos.Get(author)
	if found {
		return errors.New("slug already exists.")
	}

	silo := &Silo{
		Author:    author,
		CreatedAt: time.Now(),
	}
	return nil
}

func (d *Domain) GetSilo(author std.Address) *Post {
	_, found := d.Silos.Get(author)
	if !found {
		return nil
	}
	return silo.(*Silo)
}

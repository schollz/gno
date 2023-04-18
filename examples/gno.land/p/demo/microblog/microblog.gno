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

type Microblog struct {
	Title  string
	Prefix string   // i.e. r/gnoland/blog:
	Pages  avl.Tree // author (string) -> Page
}

func NewMicroblog(title string, prefix string) (m *Microblog) {
	return &Microblog{
		Title:  title,
		Prefix: prefix,
		Pages:  avl.Tree{},
	}
}

func (m *Microblog) GetPages() []*Page {
	var (
		pages = make([]*Page, m.Pages.Size())
		index = 0
	)

	m.Pages.Iterate("", "", func(page *avl.Node) bool {
		pages[index] = page.Value().(*Page)
		index++
		return false
	})

	// TODO: sort by last updated

	return pages
}

func (m *Microblog) Render(path string) string {
	parts := strings.Split(path, "/")

	isHome := path == ""
	isUser := len(parts) == 1

	switch {
	case isHome:
		output := ufmt.Sprintf("# %s\n\n", m.Title)
		output += "# pages\n\n"

		for _, page := range m.GetPages() {
			output += ufmt.Sprintf("- [%s](%s%s)\n", page.Author.String(), m.Prefix, page.Author.String())
		}

		return output

	case isUser:
		user := parts[0]

		silo, found := m.Pages.Get(user)
		if !found {
			return "404"
		}

		return (silo.(*Page)).String()
	}

	return "404"
}

func (m *Microblog) NewPage() error {
	author := std.GetOrigCaller()
	_, found := m.Pages.Get(author.String())
	if found {
		return errors.New("author already exists")
	}

	m.Pages.Set(author.String(), &Page{
		Author:    author,
		CreatedAt: time.Now(),
	})
	return nil
}

func (m *Microblog) NewPost(text string) error {
	author := std.GetOrigCaller()
	_, found := m.Pages.Get(author.String())
	if !found {
		// make a new page for the new author
		if err := m.NewPage(); err != nil {
			return err
		}
	}

	return m.GetPage(author.String()).NewPost(text)
}

func (m *Microblog) GetPage(author string) *Page {
	silo, found := m.Pages.Get(author)
	if !found {
		return nil
	}
	return silo.(*Page)
}

type Page struct {
	Author     std.Address
	CreatedAt  time.Time
	LastPosted time.Time
	Posts      avl.Tree // time -> Post
}

func (p *Page) String() string {
	o := ufmt.Sprintf("# %s\n\n", p.Author)
	o += ufmt.Sprintf("joined %s, last updated %s\n\n", p.CreatedAt.Format("2006-02-01"), p.LastPosted.Format("2006-02-01"))
	o += "## posts\n\n"
	for _, u := range p.GetPosts() {
		o += u.String() + "\n\n"
	}
	return o
}

func (p *Page) NewPost(text string) error {
	now := time.Now()
	p.LastPosted = now
	p.Posts.Set(now.Format(time.RFC822), &Post{
		Text:      text,
		CreatedAt: now,
	})
	return nil
}

func (p *Page) GetPosts() []*Post {
	var (
		posts = make([]*Post, p.Posts.Size())
		index = 0
	)

	p.Posts.Iterate("", "", func(post *avl.Node) bool {
		posts[index] = post.Value().(*Post)
		index++
		return false
	})

	// TODO: sort posts

	return posts
}

// Post lists the specific update

type Post struct {
	CreatedAt time.Time
	Text      string
}

func (p *Post) String() string {
	return "> " + p.Text + " **- " + p.CreatedAt.Format(time.RFC822) + "**"
}

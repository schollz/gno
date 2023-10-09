package bytebeat

import (
	"std"

	bytebeat "gno.land/p/demo/audio/bytebeat/v1"
	"gno.land/p/demo/ufmt"
)

type Comment struct {
	User    string
	Message string
}

var (
	data     string
	comments []Comment
)

func init() {
	seconds := uint32(3)
	data = bytebeat.ByteBeat(seconds, 8000, func(t int) int {
		return (t>>10^t>>11)%5*((t>>14&3^t>>15&1)+1)*t%99 + ((3 + (t >> 14 & 3) - (t >> 16 & 1)) / 3 * t % 99 & 64)
	})
}

func AddComment(s string) string {
	caller := std.GetOrigCaller() // main
	comments = append(comments, Comment{
		User:    string(caller),
		Message: s,
	})
	return "ok"
}

func Render(path string) string {
	output := ""
	output += "\n"
	output += "# my bytebeat\n"
	output += `<audio controls="controls" autobuffer="autobuffer" autoplay="autoplay">
<source src="data:audio/wav;base64,`
	output += data
	output += `" />
</audio>`
	output += "\n\n## comments\n"
	for i, comment := range comments {
		output += ufmt.Sprintf("%d. *%s* - %s\n ", i, comment.Message, comment.User)
	}
	return output
}

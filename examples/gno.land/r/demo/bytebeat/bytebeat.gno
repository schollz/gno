package bytebeat

import (
	"gno.land/p/demo/audio/bytebeat"
	evalint32 "gno.land/p/demo/eval/int32"
)

func Render(path string) string {
	exp, err := evalint32.Parse(path)
	if err != nil {
		return err.Error()
	}
	variables := make(map[string]int)
	data := bytebeat.ByteBeat(1, 8000, func(t int) int {
		variables["t"] = t
		res, _ := evalint32.Eval(exp, variables)
		return res
	})
	output := "# bytebeat\n\n"
	output += "```\n" + path + "\n```\n\n\n"
	output += `<audio controls="controls" autobuffer="autobuffer" autoplay="autoplay">
<source src="data:audio/wav;base64,`
	output += data
	output += `" />
</audio>`
	return output
}

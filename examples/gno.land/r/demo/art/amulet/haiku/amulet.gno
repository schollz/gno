// An amulet is a kind of poem that depends on language, code, and luck. To qualify, a poem must satisfy these criteria:
//
//	It is valid english words, with no puncuation.
//	The hexadecimal SHA-256 hash of the text includes four or more 8s in a row.
//
// The number of sequential 8s in the hash determines the rarity of the amulet:
//
//	8888: common
//	88888: uncommon
//	888888: rare
//	8888888: epic
//	88888888: legendary
//	888888888: mythic
//	8888888888+: ???
//
// https://archive.is/IADSf
// https://twitter.com/WildAmulet/status/1374506730575437828
package amulet

func Render(path string) string {
	return "OK"
}

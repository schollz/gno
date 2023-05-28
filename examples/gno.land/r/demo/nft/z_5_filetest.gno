// PKGPATH: gno.land/r/nft_test
package nft_test

import (
	"std"

	"gno.land/p/demo/testutils"
	"gno.land/r/demo/nft"
)

func main() {
	caller := std.GetCallerAt(1)
	addr1 := testutils.TestAddress("addr1")
	addr2 := testutils.TestAddress("addr2")
	grc721 := nft.GetToken()
	tid := grc721.Mint(addr1, "NFT#1")
	tid2 := grc721.Mint(addr2, "NFT#1")
	println(addr1)
	println(grc721.OwnerOf(tid))
	println(addr2)
	println(grc721.OwnerOf(tid2))
	s, _ := nft.GetApproved(tid)
	println(s)
}

// Output:
// g1v9jxgu33ta047h6lta047h6lta047h6l43dqc5
// g1v9jxgu33ta047h6lta047h6lta047h6l43dqc5
// g1v9jxgu3jta047h6lta047h6lta047h6la2uhll
// g1v9jxgu3jta047h6lta047h6lta047h6la2uhll

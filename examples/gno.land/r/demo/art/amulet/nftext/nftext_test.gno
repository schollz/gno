package nftext

import (
	"std"
	"testing"

	"gno.land/p/demo/grc/grc721"
	"gno.land/r/demo/users"
)

var (
	dummyNFTName   = "TextNFT"
	dummyNFTSymbol = "NFTEXT"
)

func TestTokenCount(t *testing.T) {
	dummy := grc721.NewBasicNFT(dummyNFTName, dummyNFTSymbol)
	if dummy == nil {
		t.Errorf("should not be nil")
	}

	count := dummy.TokenCount()
	if count != 0 {
		t.Errorf("expected: (%d), got: (%d)", 0, count)
	}

	err := dummy.Mint("g1var589z07ppjsjd24ukm4uguzwdt0tw7g47cgm", grc721.TokenID("1"))
	if err != nil {
		t.Errorf("err: %s", err)
	}
	err = dummy.Mint("g1var589z07ppjsjd24ukm4uguzwdt0tw7g47cgm", grc721.TokenID("2"))
	if err != nil {
		t.Errorf("err: %s", err)
	}
	err = dummy.Mint("g1var589z07ppjsjd24ukm4uguzwdt0tw7g47cgm", grc721.TokenID("2"))
	if err != nil {
		t.Errorf("err: %s", err)
	}

	// count = dummy.TokenCount()
	// if count != 2 {
	// 	t.Errorf("expected: (%d), got: (%d)", 2, count)
	// }

	// println(dummy.OwnerOf(grc721.TokenID("1")))
}

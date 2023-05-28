package haiku

import (
	"std"
	"testing"

	"gno.land/p/demo/testutils"
)

func TestAmulet(t *testing.T) {
	// 	haiku := `yes web three is here
	// 	now you can own your data
	// the future is bright`
	haiku := `a zoo a zoo a
zoo a zoo a zoo a zoo 
a zoo a zoo a`
	if err := isHaiku(haiku); err != nil {
		t.Errorf("%s", err)
	}
	if calculateRarity("88aa888aaaa8a8a8a8a88a8a") != 3 {
		t.Errorf("rarity calculations errored")
	}
	addr1 := testutils.TestAddress("addr1")
	std.TestSetOrigCaller(addr1)
	if err := Mint(haiku); err != "" {
		t.Errorf("%s", err)
	}
	if err := Mint("not a haiku"); err == "" {
		t.Errorf("not a haiku")
	}
	if err := Mint(haiku); err == "" {
		t.Errorf("token already exists")
	}

	for _, ha := range listAllNFTs() {
		println(ha.TokenID, ha.Text, ha.Rarity)
	}
}

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
	haiku = `a zoo a zoo a\nzoo a zoo a zoo a zoo \na zoo a zoo a\n`
	if err := isHaiku(haiku); err != nil {
		t.Errorf("not haiku: %s", err.Error())
	}
	if calculateRarity("88aa888aaaa8a8a8a8a88a8a") != "common" {
		t.Errorf("rarity calculations errored")
	}
	addr1 := testutils.TestAddress("addr1")
	std.TestSetOrigCaller(addr1)
	if err := Mint(haiku); err != "" {
		t.Errorf("could not mint: %s", err)
	}
	if err := Mint("not a haiku"); err == "" {
		t.Errorf("not a haiku")
	}
	if err := Mint(haiku); err == "" {
		t.Errorf("token already exists")
	}

	println(Render(""))
	println(Render("ae60a376a9be58296c4e31db658f3ea031115553169964f9c5b54f23269704ae"))
}

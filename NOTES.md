# Notes on Gno (04/10/2023)

# Packages v Realms

Package does not hold state. They are compartamentalized to make it easier for others to use. Realms hold state, they exist as the "smart contract".

# First steps.

First make sure Go and Git are installed.

Clone the repo and install everything.

```
git clone https://github.com/gnolang/gno
cd gno && make install
```

Make sure the installation worked

```
gnokey --help
```


When you import, you can import "Go" libraries using a shim called "`std`".

## VS Code

Use the "Gno" extension, but make sure gofumpt is installed:

```
go install mvdan.cc/gofumpt@latest
```


## Running tests

Run tests with `gno`, from the root directory of `gno` while working in the packages folder `examples/gno.land/p/demo`:

```
gno test --verbose examples/gno.land/p/demo/microblog
```

```
gno test --verbose examples/gno.land/p/demo/microblog 2>&1 | grep panic
```


## Debug statements


Since `fmt.Print` does not exist, use `println()` and if you need formatting use `println(ufmt.Sprintf(...))`.


## Rendering

Create an instance (a realm), that will hold state and render.

Create a new folder in `examples/gno.land/r/demo/`. Write code, with public functions that will be available.

## Make a private key

```
gnokey generate
gnokey add --recover zkey
# enter password
# enter bip39 mnemonic from gnokey generate
```

you should now have an address.

enter the addresses into `genesis_balances.txt`.

## Start gno.land locally

note: remove `gno.land/testdir` to reset local instance.

```
cd gno.land
make build
./build/gnoland
```

check if address exist

```
gnokey list
```

check if funds exist

```
/build/gnokey query --remote localhost:26657 auth/accounts/<address>
```

## Use a faucet to get funds

??


## spin up website


```
cd gno.land 
./build/gnoweb
```

## deploy a package to the website

`pkgpath` is where to deploy the package.

`pkgdir` is where the source code actually is.

```
gnokey maketx addpkg --pkgpath "gno.land/p/demo/microblog" --pkgdir "examples/gno.land/p/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 zkey
```

## deploy a realm

```
gnokey maketx addpkg --pkgpath "gno.land/r/demo/microblog" --pkgdir "examples/gno.land/r/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 zkey
```

## add a post

`--arg` lists the arguments in order.

```
gnokey maketx call --pkgpath "gno.land/r/demo/microblog" --func "NewPost" --args "hello, world" --gas-fee "1000000ugnot" --gas-wanted "2000000" --broadcast --chainid dev --remote localhost:26657 zkey
```

## URLS

You specify a URL for your realm, like `/r/demo/microblog`, but what is actually seen as a "`path`" in your realm is only part after a colon, e.g. `http://localhost:8888/r/demo/microblog:test123` has the path `test123`.

### questions

?? why doesn't ^ work??

?? how do I update an realm/package without creating a new `pkgpath`?

?? where is the data stored when I run things locally?

?? how do I setup a faucet?

?? what is the `gas-fee` and `gas-wanted`?

?? why when I make a `gnokey maketx call` with a new key does it give an `unknown address error`, is it because there are no funds for that key? 



gnokey maketx addpkg --pkgpath "gno.land/r/demo/microblog" --pkgdir "examples/gno.land/r/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 zkey 

g1qyktfeacrhcj3n3ckk5gc3neasgqvf2vwqgmtf

g1eghpfgxd4saycj0m6pwdajx3fldgg7c8z56khp
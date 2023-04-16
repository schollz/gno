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

## Debug statements


Since `fmt.Print` does not exist, use `println()` and if you need formatting use `println(ufmt.Sprintf(...))`.

# Notes on Gno (04/10/2023)

# Packages v Realms

Package does not hold state. Realms hold state, they exist as the "smart contract".

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

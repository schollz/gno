# Go -> Gno

Working with Gno is as easy as working in Go - the syntax is identical. 

The workflow, however, is slightly different. With a little setup it can be easy to work with Gno as easy as it is to work with Go.

## 1. Prepare environment

Install Visual Studio Code + Gno extension by Hariom Verma. 

After installing Gno extension, install `gofumpt`:

```bash
go install mvdan.cc/gofumpt@latest
```

Clone the `gno` project:

```bash
git clone https://github.com/gnolang/gno
cd gno
```

Build the `gno` project utilities and `gno.land`:

```bash
make install
```

```
cd gno.land && make build
``` 

Anytime you make changes to the Gno project you may have to rebuild `gno.land` or `gno` tools.

## 2. Create a key for local development

Create a new key, this will be used for local development.

```bash
gnokey generate
```

Copy down the bip39 mnemonic. Now we will actually add the key:

```bash
gnokey add --recover yourkey
```

Enter the passphrase twice and then enter the bip39 mnemonic generated earlier.

Finally, for local development, you should add the key `addr` to the `genesis_balances.txt` so that you have tokens to make transactions. 

```bash
> gnokey list
0. yourkey (local) - addr: youraddress pub: ...
```

You will see the keys you have, and just copy down the address, `youraddress`.

Now edit `gno.land/genesis/genesis_balances.txt` and add the line at the end with your address:

```
youraddress=10000000000ugnot # @yourkey 
```

This makes development easy without having to utilize a faucet.


## 4. Test out the environment

Lets spin up the `gno.land` and create a user with our address. The realm `gno.land/r/demo/users` makes it easy to add and view users.

I like to make a script to easily spinup a new `gno.land` to test out. Here is the script, `start_gno.land.sh`:

```bash
#!/bin/bash

pkill -f 'build/gnoland'
pkill -f 'build/gnoweb'
rm -rf gno.land/testdir
cd gno.land && ./build/gnoland & 
sleep 5
cd gno.land && ./build/gnoweb -bind 0.0.0.0:8888 & 
sleep 2
```

You can run that script and wait a few seconds for the `gno.land` server and `gnoweb` interface to spinup:

```bash
./start_gno.land.sh
```

Before continuing, its also easiest if you save your password to a file, e.g. `password` and use that when making transaction calls.

Then you can create a user with this transaction command:

```bash
cat password | gnokey maketx call --pkgpath "gno.land/r/demo/users" --func "Register" --args "" --args "yourname" --args "yourprofile" --gas-fee "1000000ugnot" --gas-wanted "2000000" --broadcast --chainid dev --remote localhost:26657 --send "200000000ugnot" -insecure-password-stdin=true yourkey
```

Now you will be able to see your user in the realm at http://localhost:8888/r/demo/users:yourname.


### Aside: Understanding the `maketx` call

The `gnokey maketx` allows you to call a function from a realm. In this case, the function is `Register`. One of the cool things about `gno.land` is that the source is available. We can look at the source code of this function here: http://localhost:8888/r/demo/users/users.gno

It has three arguments - `(inviter std.Address, name string, profile string)`. The arguments are fed tot he `gnokey maktex` as `--args` arguments:

```
--args "" --args "yourname" --args "yourprofile"
```

The first argument is the address of the inviter, and in this case we don't have an inviter so we leave it blank. The second argument is your name, as will be shown in the profile, and the final argument is any info you want to be shown on your page.


### Aside: Understand `gno.land` routing

The `gno.land` exists as a repository of realms that can be utilized within your own smart contracts. The route of the realm is given by its package path. In this case it is `/r/demo/users`. The rendering of the realm can take other arguments, which are designated after the colon, `:`. For example, `yourname` is an argument to the render function in this path: http://localhost:8888/r/demo/users:yourname.

If we look at the `Render()` function of this realm (this is the function that is run when you go to the site), it will pull out the username using the semicolon: http://localhost:8888/r/demo/users/users.gno.



## 5. Realm example: microblog

Microblog is a realm that lets users have feeds of time-dated posts. It lives at `/r/demo/microblog`.

Any realm/package will need to be activated using `gnokey maketx` Anytime you make a new package and realm, you will have to create a transaction to add it.

I will get into the details of the realm and package, but first lets try it.

We can activate it by first adding the package:

```
cat password | gnokey maketx addpkg --pkgpath "gno.land/p/demo/microblog" --pkgdir "examples/gno.land/p/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 --insecure-password-stdin=true yourkey
```

Then add the realm, which is the same path except its `/r/` instead of `/p/`:

```
cat password | gnokey maketx addpkg --pkgpath "gno.land/r/demo/microblog" --pkgdir "examples/gno.land/r/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 --insecure-password-stdin=true yourkey
```

We can check to see that its up by going to its source: http://localhost:8888/r/demo/microblog/microblog.gno

There is basically just one function: `NewPost(text string)` which you can call to add some post to your feed. Lets try it:

```
cat password | gnokey maketx call --pkgpath "gno.land/r/demo/microblog" --func "NewPost" --args "*hello*, **world**." --gas-fee "1000000ugnot" --gas-wanted "2000000" --broadcast --chainid dev --remote localhost:26657 --send "200000000ugnot" -insecure-password-stdin=true yourkey
```

The realm itself is very simple. It calls `Render` to render markdown that is used to generate the html of `gno.land` and it has a function for adding posts. 

The main guts of the realm is in the package, `/p/demo/microblog`.

### Aside: Realm vs package

A realm is a Gno package with state, that represents a smart contract with storage and coins.

Another way to think about it is that a package is a unit of code that may be used by many realms. However you can also import realms.

## The microblog package, Go/Gno differences

Lets look at the microblog package: http://localhost:8888/p/demo/microblog/microblog.gno

This looks just like Go code, with a few subtle differences.

### The `std` library

First, there is a special import, `std`. The `std` package is a Gno-specific package that lets you access the caller's address, using `std.GetOrigCaller()` and store addresses using the type `std.Address`. 

### Maps and `avl.Tree`

Another difference is the use of the `avl.Tree` which is imported with `gno.land/p/demo/avl`. 

This data structure is a self-balancing binary search tree. This structure is used pretty much anytime you need a map (https://github.com/gnolang/gno/issues/311). 

The built-in Go map structure does not currently work in Gno because it is non-determistic. Gno is completely determistic for complete accountability (https://github.com/gnolang/gno/issues/452) so that there is only one path between states so validators can reach consesus. 

The `avl.Tree` can be initialized using 

```go
t := avl.Tree{}
```

and then set with 

```go
t.Set(<string>,&MyStructure)
```

and then get with 

```go
v, found := t.Get(<string>)
if (found) {
    v2 := v.(*MyStructure) // cast it back
}
```

It also has an iterator


```go
t.Iterate("", "", func(key string, value interface{}) bool {
    return false
})
```

We can see examples of using this structure in `microblog`: http://localhost:8888/p/demo/microblog/microblog.gno

### Lacking reflectoin: `fmt` vs `ufmt`

Libraries like `fmt` in Go use reflection, and (as of June 2023) Gno currently does not support reflection (https://github.com/gnolang/gno/issues/750). The `ufmt` library is a micro-implementation of the `fmt` library. This is the library that you can use to do formatting with basic types, like using `ufmt.Sprintf`.

For example, in `microblog`, it is used to format the title:

```golang
ufmt.Sprintf("# %s\n\n", m.Title)
```

The lack of reflection affects some other packages, like `sort` ([#750](https://github.com/gnolang/gno/issues/750)). Currentl you cannot use `sort.Slice` because the code uses reflection, but you can use the classic method of implementing `Len()`, `Swap(i, j int)` and `Less(i, j int) bool` to do sorting.  For example in `microblog`:

```go
// byLastPosted implements sort.Interface for []Page based on
// the LastPosted field.
type byLastPosted []*Page

func (a byLastPosted) Len() int           { return len(a) }
func (a byLastPosted) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a byLastPosted) Less(i, j int) bool { return a[i].LastPosted.After(a[j].LastPosted) }
...
...
sort.Sort(byLastPosted(pages))
```

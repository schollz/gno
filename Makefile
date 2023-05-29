.PHONY: help
help:
	@echo "Available make commands:"
	@cat Makefile | grep '^[a-z][^:]*:' | cut -d: -f1 | sort | sed 's/^/  /'

rundep=go run -modfile ../misc/devdeps/go.mod

.PHONY: install
install: install_gnokey install_gno

# shortcuts to frequently used commands from sub-components.
install_gnokey:
	$(MAKE) --no-print-directory -C ./gno.land	install.gnokey
	@echo "[+] 'gnokey' is installed. more info in ./gno.land/."
install_gno:
	$(MAKE) --no-print-directory -C ./gnovm	install
	@echo "[+] 'gno' is installed. more info in ./gnovm/."

.PHONY: test
test: test.components test.docker

.PHONY: test.components
test.components:
	$(MAKE) --no-print-directory -C tm2      test
	$(MAKE) --no-print-directory -C gnovm    test
	$(MAKE) --no-print-directory -C gno.land test
	$(MAKE) --no-print-directory -C examples test

.PHONY: test.docker
test.docker:
	@if hash docker 2>/dev/null; then \
		go test --tags=docker -count=1 -v ./misc/docker-integration; \
	else \
		echo "[-] 'docker' is missing, skipping ./misc/docker-integration tests."; \
	fi

.PHONY: fmt
fmt:
	$(MAKE) --no-print-directory -C tm2      fmt
	$(MAKE) --no-print-directory -C gnovm    fmt
	$(MAKE) --no-print-directory -C gno.land fmt
	$(MAKE) --no-print-directory -C examples fmt

.PHONY: lint
lint:
	golangci-lint run --config .github/golangci.yml


rebuild:
	make install
	cd gno.land && make build 

server:
	-pkill -f 'build/gnoland'
	-pkill -f 'build/gnoweb'
	# gno test --verbose examples/gno.land/p/demo/audio
	rm -rf gno.land/testdir
	cd gno.land && ./build/gnoland & 
	sleep 3
	cd gno.land && ./build/gnoweb -bind 0.0.0.0:8888 & 
	sleep 3

r:
	cat password | gnokey maketx addpkg --pkgpath "gno.land/r/demo/art/haiku" --pkgdir "examples/gno.land/r/demo/art/haiku" --deposit 100000000ugnot --gas-fee 2000000000ugnot --gas-wanted 10000000000 --broadcast --chainid dev --remote localhost:26657 --insecure-password-stdin=true zzkey1
	sleep 2

haiku:
	# -cat password | gnokey maketx call --pkgpath "gno.land/r/demo/art/haiku" --func "Mint" --args "a zoo a zoo a\nzoo a zoo a zoo a zoo \na zoo a zoo zoo\n" --gas-fee "1000000ugnot" --gas-wanted "8000000" --broadcast --chainid dev --remote localhost:26657  --insecure-password-stdin=true zzkey1
	# -cat password | gnokey maketx call --pkgpath "gno.land/r/demo/art/haiku" --func "Mint" --args "a zoo a zoo a\nzoo a zoo a zoo a zoo \na zoo a zoo a\n" --gas-fee "1000000ugnot" --gas-wanted "8000000" --broadcast --chainid dev --remote localhost:26657  --insecure-password-stdin=true zzkey2
	-cat password | gnokey maketx call --pkgpath "gno.land/r/demo/art/haiku" --func "Mint" --args "Knock over a plant,\ncat's innocent eyes proclaim,\n'Nature needed that!'" --gas-fee "1000000ugnot" --gas-wanted "8000000" --broadcast --chainid dev --remote localhost:26657  --insecure-password-stdin=true zzkey1
	-cat password | gnokey maketx call --pkgpath "gno.land/r/demo/art/haiku" --func "Mint" --args "Box arrives, cat's joy.\nMore interested in box,\nThan the gift inside." --gas-fee "1000000ugnot" --gas-wanted "8000000" --broadcast --chainid dev --remote localhost:26657  --insecure-password-stdin=true zzkey1
	-cat password | gnokey maketx call --pkgpath "gno.land/r/demo/art/haiku" --func "Mint" --args "Cat knocked off my mug.\nSpilled coffee on my laptop.\nFeline tech support." --gas-fee "1000000ugnot" --gas-wanted "8000000" --broadcast --chainid dev --remote localhost:26657  --insecure-password-stdin=true zzkey2

rhaiku: r haiku
	-cat password | gnokey maketx call --pkgpath "gno.land/r/demo/users" --func "Register" --args "" --args "schollz" --args "https://schollz.com" --gas-fee "1000000ugnot" --gas-wanted "2000000" --broadcast --chainid dev --remote localhost:26657 --send "200000000ugnot" -insecure-password-stdin=true zzkey1
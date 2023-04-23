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


runall:
	gno test --verbose examples/gno.land/p/demo/microblog
	rm -rf gno.land/testdir
	cd gno.land && ./build/gnoland & 
	sleep 5
	cd gno.land && ./build/gnoweb & 
	sleep 2
	gnokey maketx addpkg --pkgpath "gno.land/p/demo/microblog" --pkgdir "examples/gno.land/p/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 zkey
	gnokey maketx addpkg --pkgpath "gno.land/r/demo/microblog" --pkgdir "examples/gno.land/r/demo/microblog" --deposit 100000000ugnot --gas-fee 1000000ugnot --gas-wanted 2000000 --broadcast --chainid dev --remote localhost:26657 zkey
	gnokey maketx call --pkgpath "gno.land/r/demo/microblog" --func "NewPost" --args "hello, world" --gas-fee "1000000ugnot" --gas-wanted "2000000" --broadcast --chainid dev --remote localhost:26657 zkey



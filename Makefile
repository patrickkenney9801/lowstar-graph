SHELL := /bin/bash

IMAGE_NAME := lowstar
VERSION := 0.0.1
BUILD_DIR := build
SOURCE_HOME := fstar

SOURCE_DIRS = $(SOURCE_HOME)/code $(SOURCE_HOME)/specs
INCLUDE_DIRS = \
  $(SOURCE_DIRS) \
  $(KRML_HOME)/krmllib \
  $(SOURCE_HOME)/obj
FSTAR_INCLUDES = $(addprefix --include ,$(INCLUDE_DIRS))

podman-image:
	@podman build --build-arg VERSION=${VERSION} -t ${IMAGE_NAME}:${VERSION} --file Dockerfile --target build .

podman:
	@mkdir -p build
	@podman run --rm -v $(shell pwd)/:$(shell pwd) --privileged --userns=keep-id:uid=1000,gid=1000 -u 1000 --workdir=$(shell pwd) -it ${IMAGE_NAME}:${VERSION} bash -l

docker-image:
	@docker --context rootless build --build-arg VERSION=${VERSION} -t ${IMAGE_NAME}:${VERSION} --file Dockerfile --target build .

docker:
	@mkdir -p build
	@docker --context rootless run --rm -v $(shell pwd)/:$(shell pwd) --privileged -u 1000 --workdir=$(shell pwd) -it ${IMAGE_NAME}:${VERSION} bash -l

dependencies: dependencies-asdf

dependencies-asdf:
	@echo "Updating asdf plugins..."
	@asdf plugin update --all >/dev/null 2>&1 || true
	@echo "Adding new asdf plugins..."
	@cut -d" " -f1 ./.tool-versions | xargs -I % asdf plugin-add % >/dev/null 2>&1 || true
	@echo "Installing asdf tools..."
	@cat ./.tool-versions | xargs -I{} bash -c 'asdf install {}'
	@echo "Updating local environment to use proper tool versions..."
	@cat ./.tool-versions | xargs -I{} bash -c 'asdf local {}'
	@asdf reshim
	@echo "Done!"

hooks:
	@pre-commit install --hook-type pre-commit
	@pre-commit install-hooks

pre-commit:
	@pre-commit run -a

check:
	@fstar.exe fstar/code/*.fst --hint_dir fstar/hints  --cache_checked_modules $(FSTAR_INCLUDES) --query_stats

ocaml:
	@fstar.exe fstar/code/*.fst --codegen OCaml --odir fstar/specs/ml \
		--cmi --cache_checked_modules $(FSTAR_INCLUDES) \
		--already_cached 'Prims FStar LowStar C Spec.Loops TestLib WasmSupport' --warn_error '+241@247+285' \
		--cache_dir fstar/obj --hint_dir fstar/hints

krml:
	@fstar.exe fstar/code/*.fst --codegen krml --odir fstar/obj \
		--cmi --cache_checked_modules $(FSTAR_INCLUDES) \
		--already_cached 'Prims FStar LowStar C Spec.Loops TestLib WasmSupport' --warn_error '+241@247+285' \
		--cache_dir fstar/obj --hint_dir fstar/hints

#@cp fstar/code/c/* fstar/dist/
c:
	@krml fstar/obj/*.krml -dc -verbose -tmpdir fstar/dist -verify \
	  -warn-error @4@5@18 \
		-fparentheses \
		-bundle Impl.Graph.MaxGeneral= \
	  -bundle 'LowStar.*,Prims' \
		-bundle Spec.*[rename=Graph] \
		-minimal \
	  -bundle 'FStar.*' \
	  -add-include '<stdint.h>' \
	  -add-include '"krml/internal/target.h"' \
	  -add-include '"krml/internal/types.h"' \
	  -skip-compilation -o graph.a
#		fstar/code/c/*.c \

exe:
	@make -C fstar/dist -f Makefile.basic graph.a
	
#@ocamlfind opt -package fstar.lib -linkpkg -g -I $(SOURCE_HOME)/obj -w -8-20-26 -thread -o example

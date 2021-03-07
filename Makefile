NAME?=
COMPANY?=

ROOT := https:\/\/ianstevens.ca
ANCHOR := s/\(href=\"\).*\(\#[a-z0-9_]*\)/\1\2/
IMAGES := s/\(img src=\"\)$(ROOT).*\(\/.*\"\)/\1\2/
ASSETS := s/\(href=\"\)$(ROOT)\(\/static\/.*\"\)/\1\2/

default:
	lektor build -O build

DASH := -
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
space2dash = $(shell echo $(subst $(SPACE),$(DASH),$(strip $(1))) | tr '[:upper:]' '[:lower:]')
name_company := $(call space2dash,$(NAME) $(COMPANY))
sum := $(shell echo -ne $(name_company) | md5sum | cut -c 1-10)
branch := $(name_company)-$(sum)
hire-branch:
	git branch $(branch)
	git co $(branch)

hire-deploy: hire-build
	# git branch --show-current
	# zip tree
	# curl deploy

hire-build:
	sed -i .bak "s/absolute/external/" istevens.com.lektorproject
	sed -i .bak "/^_hidden/d" content/hire/contents.lr

	lektor build -O build

	# change img, anchor links, assets to relative
	sed -i "" "$(ANCHOR);$(IMAGES);$(ASSETS)" build/hire/index.html

	# Include only assets, hire
	cp -r build/static build/hire

	# assets/_redirect?
	# robots.txt?

clean:
	rm -rf build/

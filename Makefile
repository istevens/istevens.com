AUTHORIZATION_BEARER := -H 'Authorization: Bearer $(NETLIFY_SECRET_BEARER)'
NETLIFY_SITE_API := https:\/\/api.netlify.com/api/v1/sites/
SITE_ROOT := hire.ianstevens.ca
BUILD_DIR := build

ROOT := https:\/\/ianstevens.ca
ANCHOR := s/\(href=\"\).*\(\#[a-z0-9_]*\)/\1\2/
IMAGES := /\/static\//! s/\(img src=\"\)$(ROOT).*\(\/.*\"\)/\1\2/

build:
	lektor build -O $(BUILD_DIR)

host:
	lektor serve

clean:
	rm -rf $(BUILD_DIR)

DASH := -
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
space2dash = $(shell echo $(subst $(SPACE),$(DASH),$(strip $(1))) | tr '[:upper:]' '[:lower:]')
name_company := $(call space2dash,$(NAME) $(COMPANY))
sum := $(shell echo -ne $(name_company) | md5sum | cut -c 1-6)
new_branch := $(name_company)-$(sum)
hire-branch:
	git branch $(new_branch)
	git co $(new_branch)

hire-build:
	mv istevens.com.lektorproject istevens.com.lektorproject.bak
	mv content/hire/contents.lr content/hire/contents.lr.bak
	sed "s/absolute/external/" istevens.com.lektorproject.bak > istevens.com.lektorproject
	sed "/^_hidden/d" content/hire/contents.lr.bak > content/hire/contents.lr

	lektor build -O $(BUILD_DIR)

	# change img, anchor links, assets to relative
	mv $(BUILD_DIR)/hire/index.html $(BUILD_DIR)/hire/index.html.bak
	sed "$(ANCHOR);$(IMAGES)" $(BUILD_DIR)/hire/index.html.bak > $(BUILD_DIR)/hire/index.html
	rm $(BUILD_DIR)/hire/index.html.bak

	# Include only assets, hire
	cp -r $(BUILD_DIR)/static $(BUILD_DIR)/hire/

	# assets/_redirect?
	# robots.txt?

	mv istevens.com.lektorproject.bak istevens.com.lektorproject
	mv content/hire/contents.lr.bak content/hire/contents.lr

branch := $(shell git branch --show-current)
hire-deploy: hire-build
	cd $(BUILD_DIR)/hire && zip -r $(branch).zip .

	# Create site, then deploy
	curl -H "Content-Type: application/json" \
		 $(AUTHORIZATION_BEARER) \
		 --data '{"name": "$(branch)", "custom_domain": "$(branch).$(SITE_ROOT)"}'\
		 $(NETLIFY_SITE_API)

	curl -H "Content-Type: application/zip" \
		 $(AUTHORIZATION_BEARER) \
		 --data-binary "@$(BUILD_DIR)/hire/$(branch).zip" \
		 $(NETLIFY_SITE_API)$(branch).$(SITE_ROOT)/deploys

hire-undeploy:
	curl -X DELETE $(AUTHORIZATION_BEARER) \
		 $(NETLIFY_SITE_API)$(branch).$(SITE_ROOT)

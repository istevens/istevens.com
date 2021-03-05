ROOT := https:\/\/ianstevens.ca
ANCHOR := s/\(href=\"\).*\(\#[a-z0-9_]*\)/\1\2/
IMAGES := s/\(img src=\"\)$(ROOT).*\(\/.*\"\)/\1\2/
ASSETS := s/\(href=\"\)$(ROOT)\(\/static\/.*\"\)/\1\2/

default:
	lektor build -O build

hire:
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

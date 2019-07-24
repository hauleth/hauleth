.PHONY: assets build

build: assets
	hugo

assets:
	yarn --cwd themes/terminal install
	yarn --cwd themes/terminal build

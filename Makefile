.PHONY: assets build

build: assets
	hugo

assets:
	yarn install
	yarn build

.PHONY: assets build local

build: assets
	hugo

local: assets
	hugo server -wD

assets:
	yarn install
	yarn build

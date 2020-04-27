.PHONY: assets build local

build: assets
	hugo

local: assets
	hugo server -wD

assets:
	yarn install
	yarn build

init:
	git config filter.dates.clean ./bin/dates.sh
	git config filter.dates.smudge ./bin/dates.sh

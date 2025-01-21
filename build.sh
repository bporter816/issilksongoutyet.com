#!/bin/bash
mkdir -p _data
curl 'https://store.steampowered.com/api/appdetails?appids=1030300' | python3 -c 'import json, sys; json.dump(json.load(sys.stdin)["1030300"]["data"]["release_date"], sys.stdout)' > _data/steam.json
jekyll build

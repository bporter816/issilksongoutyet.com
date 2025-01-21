#!/bin/bash
curl 'https://store.steampowered.com/api/appdetails?appids=1030300' | jq '.["1030300"].data.release_date' > _data/steam.json
jekyll build

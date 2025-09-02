import json
import os
import subprocess

import requests

os.mkdir("_data")
cookies = {"Steam_Language": "english"}
resp = requests.get("https://store.steampowered.com/api/appdetails?appids=1030300", cookies=cookies)
resp.raise_for_status()
data = resp.json()
with open("_data/steam.json", "w") as f:
    json.dump(data["1030300"]["data"]["release_date"], f)
subprocess.run(["jekyll", "build"])

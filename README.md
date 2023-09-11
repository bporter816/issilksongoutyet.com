# [issilksongoutyet.com](https://www.issilksongoutyet.com)

A website that tracks the release date of [Hollow Knight: Silksong](https://store.steampowered.com/app/1030300/Hollow_Knight_Silksong/).

To get the site to update dynamically, I looked into options for fetching data from Steam.
Their website hits an underlying API that can be queried directly:
```sh
$ curl 'https://store.steampowered.com/api/appdetails?appids=1030300' | jq '.["1030300"].data.release_date'
{
  "coming_soon": true,
  "date": "To be announced"
}
```

My first thought was to fetch the data client-side in the browser, but this didn't work due to CORS (the API doesn't return an `Access-Control-Allow-Origin` header).

Next, I tried fetching the data in a Cloudflare Worker, still processing it client-side. When I started making the request in the Worker, I began getting 403 responses back.
I suspected the Steam API was blocking Cloudflare Workers, and confirmed this by making a test request with a header that Cloudflare injects into outbound requests from Workers:
```sh
$ curl -I 'https://store.steampowered.com/api/appdetails?appids=1030300'
HTTP/1.1 200 OK
...

$ curl -I -H 'cf-worker: blah' 'https://store.steampowered.com/api/appdetails?appids=1030300'
HTTP/1.1 403 Forbidden
...
```

OK, looks like Steam doesn't want Cloudflare Workers scraping their API. Fair enough. Not wanting to give up so easily, I rewrote the Worker script in an AWS Lambda function.
This worked, but still had a couple of undesirable characteristics:
* Data fetching on page load takes time, and there is a noticable lag before the content appears.
* The Lambda function is public, so I can rack up costs from bots hitting it, etc. It's just not very elegant.

To overcome these issues, I changed the site to build hourly, producing a static site with the Steam API data injected at build time.
The finished site is built with Jekyll on GitHub Pages and updates via a scheduled GitHub Actions workflow.

https://github.com/bporter816/issilksongoutyet.com/blob/49e8054810977105b6ab0ef0c7d1518fb4c9e6f0/.github/workflows/jekyll-gh-pages.yml#L39-L40

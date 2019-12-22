# Two Days Weather

![Weather App Icon](Two%20Days%20Weather/Assets.xcassets/icon.imageset/icon.png)

## Dev notes

### UI

- Didn't use Storyboards for the app UI (just the launch screen). I've actually never done this with a UIKit app before, so that was interesting.

### Data model

- The app caches the 5-day forecast in 3-hour intervals.
	- "Today" is displayed as the temp at the next 3 hour time. "Tomorrow" is the temp at the current time of day, 24 hours from the current time.
	- The cache invalidates once per day. It should be made smarter by always defaulting to the cache and then opportunistically updating from the API.
- First time working with Couchbase. I'm probably not doing things very idiomatically.

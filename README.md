# Two Days Weather

![Weather App Icon](Two%20Days%20Weather/Assets.xcassets/icon.imageset/icon.png)

## Local development

Two Days Weather uses [Open Weather Map's forecast API](https://openweathermap.org/forecast5). Sign up for a free API key and add `Secrets.swift` with:

```swift
let openWeatherMapAPIKey = "YOUR_API_KEY"
```

## Dev notes

### UI

- Didn't use Storyboards for the app UI (just the launch screen). I've actually never done this with a UIKit app before, so that was interesting.

### Data source

- The app caches the 5-day forecast in 3-hour intervals from [OpenWeather](https://openweathermap.org/forecast5)
	- "Today" is displayed as the temp at the next 3 hour time. "Tomorrow" is the temp at the current time of day, 24 hours from the current time.
	- The cache invalidates once per day. It should be made smarter by always defaulting to the cache and then opportunistically updating from the API.
  - It listens for significant location changes and re-fetches from the API.

### Database

- All data is stored locally in Couchbase.
- First time working with it. I'm probably not doing things very idiomatically.

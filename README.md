# Open Weather

Flutter test project for Baleen Studio

## Features

- City search
- Dark mode
- Geolocation

## Architecture

- State management: Riverpod
- Network: Dio
- Modelling: Freezed
- Location: Geolocator
- Navigation: GoRouter

## Reasoning
I chose riverpod for state management in this case in part due to familiarity, but also ease of use. Using Riverpod in combination with freezed for model generation, it is possible to have  a variey
ty of variables available for use in many classes and views without the need for passing variables back and forth through navigation. Riverpod offers a very smooth asynchronous experience that allows for an extra level of abstraction between the view provider layer and the service.

Thinking about how the app should behave on startup, rather than have the user input a city name into the search field, I used geolocator to give find the user's location and give teh local weather data based on this
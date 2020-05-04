# Semestral project assignment - MI-AFP - zakjindr

This assignment describes Elmify - a front-end web application that shows user's stats about their listening tastes and habits on Spotify made using Elm. 

---

## Technology
* Elm
* Webpack

## Description

The application can fetch data from [Spotify Web API](https://developer.spotify.com/documentation/web-api/reference/) and present it to the user in a nice and clear way using chart visualisations. 

The app will let users to:
* Login via Spotify using OAuth ([Implicit Grant Flow](https://developer.spotify.com/documentation/general/guides/authorization-guide/#implicit-grant-flow))
* View user's top artists for different time ranges (long, medium, short)
* View user's top songs for different time ranges (long, medium, short)
* View user's listening tastes and preferences according to his top songs (e.g. danceability, energy, tempo)
* Search for a track and view its audio features to be able to compare these features with user's tastes and preferences
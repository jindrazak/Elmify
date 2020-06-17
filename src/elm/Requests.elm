module Requests exposing (..)

import Decoders exposing (artistsPagingObjectDecoder, audioFeaturesDecoder, audioFeaturesListDecoder, profileDecoder, searchTracksPagingObjectDecoder, tracksPagingObjectDecoder)
import Http exposing (Expect)
import List exposing (map)
import String exposing (join)
import Types exposing (Msg(..), TimeRange, TopSubject(..), Track)
import Url.Builder as Builder
import UrlHelper exposing (spotifyTopUrl)


getProfile : String -> Cmd Msg
getProfile accessToken =
    spotifyGetRequest accessToken
        (Builder.crossOrigin "https://api.spotify.com" [ "v1", "me" ] [])
    <|
        Http.expectJson GotProfile profileDecoder


getUsersTopArtists : String -> TimeRange -> Cmd Msg
getUsersTopArtists accessToken timeRange =
    spotifyGetRequest accessToken
        (spotifyTopUrl TopArtists timeRange)
    <|
        Http.expectJson GotTopArtists artistsPagingObjectDecoder


getUsersTopTracks : String -> TimeRange -> Cmd Msg
getUsersTopTracks accessToken timeRange =
    spotifyGetRequest accessToken
        (spotifyTopUrl TopTracks timeRange)
    <|
        Http.expectJson GotTopTracks tracksPagingObjectDecoder


getSearchedTrackAudioFeatures : String -> Track -> Cmd Msg
getSearchedTrackAudioFeatures accessToken track =
    spotifyGetRequest accessToken
        (Builder.crossOrigin "https://api.spotify.com" [ "v1", "audio-features", track.id ] [])
    <|
        Http.expectJson GotSearchedTrackAudioFeatures audioFeaturesDecoder


getAudioFeatures : String -> List Track -> Cmd Msg
getAudioFeatures accessToken tracks =
    spotifyGetRequest accessToken
        (Builder.crossOrigin "https://api.spotify.com"
            [ "v1", "audio-features" ]
            [ Builder.string "ids" <| join "," <| map .id tracks ]
        )
    <|
        Http.expectJson GotAudioFeatures audioFeaturesListDecoder


getTrackSearch : String -> String -> Cmd Msg
getTrackSearch accessToken q =
    spotifyGetRequest accessToken
        (Builder.crossOrigin "https://api.spotify.com"
            [ "v1", "search" ]
            [ Builder.string "q" q
            , Builder.string "type" "track"
            , Builder.string "limit" "10"
            ]
        )
    <|
        Http.expectJson GotSearchTracks searchTracksPagingObjectDecoder


spotifyGetRequest : String -> String -> Expect Msg -> Cmd Msg
spotifyGetRequest accessToken url expect =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = url
        , expect = expect
        }

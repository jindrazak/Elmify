module Requests exposing (..)

import Decoders exposing (artistsPagingObjectDecoder, audioFeaturesListDecoder, profileDecoder, tracksPagingObjectDecoder)
import Http
import List exposing (map)
import String exposing (join)
import Types exposing (Msg(..), TimeRange, TopSubject(..), Track)
import Url.Builder as Builder
import UrlHelper exposing (spotifyTopUrl)


getProfile : String -> Cmd Msg
getProfile accessToken =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = "https://api.spotify.com/v1/me"
        , expect = Http.expectJson GotProfile profileDecoder
        }


getUsersTopArtists : String -> TimeRange -> Cmd Msg
getUsersTopArtists accessToken timeRange =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = spotifyTopUrl TopArtists timeRange
        , expect = Http.expectJson GotTopArtists artistsPagingObjectDecoder
        }


getUsersTopTracks : String -> TimeRange -> Cmd Msg
getUsersTopTracks accessToken timeRange =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = spotifyTopUrl TopTracks timeRange
        , expect = Http.expectJson GotTopTracks tracksPagingObjectDecoder
        }


getAudioFeatures : String -> List Track -> Cmd Msg
getAudioFeatures accessToken tracks =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url =
            Builder.crossOrigin "https://api.spotify.com"
                [ "v1", "audio-features" ]
                [ Builder.string "ids" <| join "," <| map .id tracks ]
        , expect = Http.expectJson GotAudioFeatures audioFeaturesListDecoder
        }

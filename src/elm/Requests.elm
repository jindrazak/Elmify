module Requests exposing (..)

import Decoders exposing (pagingObjectDecoder, profileDecoder)
import Http
import Types exposing (Msg(..), TimeRange)
import UrlHelper exposing (spotifyTopArtistsUrl)


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
        , url = spotifyTopArtistsUrl timeRange
        , expect = Http.expectJson GotTopArtists pagingObjectDecoder
        }

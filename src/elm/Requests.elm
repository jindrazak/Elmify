module Requests exposing (..)

import Decoders exposing (artistsPagingObjectDecoder, profileDecoder, tracksPagingObjectDecoder)
import Http
import Types exposing (Msg(..), TimeRange, TopSubject(..))
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

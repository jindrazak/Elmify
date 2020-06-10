module Requests exposing (..)

import Decoders exposing (pagingObjectDecoder, profileDecoder)
import Http
import Types exposing (Msg(..))


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



--TODO add option to choose different query parameters


getUsersTopArtists : String -> Cmd Msg
getUsersTopArtists accessToken =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = "https://api.spotify.com/v1/me/top/artists"
        , expect = Http.expectJson GotTopArtists pagingObjectDecoder
        }

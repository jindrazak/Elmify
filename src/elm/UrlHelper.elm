module UrlHelper exposing (..)

import Maybe exposing (withDefault)
import Url exposing (Protocol(..), Url)
import Url.Builder as Builder
import Url.Parser as Parser
import Url.Parser.Query as Query


spotifyAuthLink : Url -> String
spotifyAuthLink redirectUrl =
    Builder.crossOrigin "https://accounts.spotify.com"
        [ "authorize" ]
        [ Builder.string "client_id" "6706db46b52f4ffb99a27f16a7cc2338"
        , Builder.string "response_type" "token"
        , Builder.string "redirect_uri" <| Url.toString redirectUrl
        , Builder.string "scope" "user-top-read"
        ]


spotifyRedirectUrl : Url -> Url
spotifyRedirectUrl url =
    let
        baseUrl =
            extractBaseUrl url
    in
    { baseUrl | path = "/login-redirect" }


extractBaseUrl : Url -> Url
extractBaseUrl url =
    { url | path = "", query = Nothing, fragment = Nothing }


extractFromQueryString : String -> String -> Maybe String
extractFromQueryString queryString key =
    let
        url =
            Url Https "" Nothing "" (Just queryString) Nothing
    in
    withDefault Nothing (Parser.parse (Parser.query (Query.string key)) url)

module Views exposing (..)

import Helper exposing (smallestImage)
import Html exposing (Html, a, button, div, img, li, ol, text, ul)
import Html.Attributes exposing (href, src)
import Html.Events exposing (onClick)
import List exposing (map)
import Maybe exposing (withDefault)
import Types exposing (Artist, Image, Msg(..), PagingObject, Profile, TimeRange(..), placeholderImage)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)


profileImage : List Image -> Html Msg
profileImage images =
    let
        image =
            withDefault placeholderImage <| smallestImage images
    in
    img [ src image.url ] []


artistLi : Artist -> Html Msg
artistLi artist =
    li []
        [ profileImage artist.images
        , text artist.name
        ]


topArtistsView : List Artist -> Html Msg
topArtistsView list =
    case list of
        [] ->
            div [] [ text "No artists found." ]

        artists ->
            ol [] <| map artistLi artists


profileView : Url -> Maybe Profile -> Html Msg
profileView url maybeProfile =
    case maybeProfile of
        Nothing ->
            div [] [ a [ href <| spotifyAuthLink <| spotifyRedirectUrl url ] [ text "Spotify login" ] ]

        Just profile ->
            div [] [ text profile.name, profileImage profile.images ]


topArtistsTimeRangeSelect : Html Msg
topArtistsTimeRangeSelect =
    ol []
        [ li [] [ button [ onClick <| TopArtistsTimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ] ]
        , li [] [ button [ onClick <| TopArtistsTimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ] ]
        , li [] [ button [ onClick <| TopArtistsTimeRangeSelected LongTerm ] [ text "Long term (several years)" ] ]
        ]

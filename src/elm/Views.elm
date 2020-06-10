module Views exposing (..)

import Helper exposing (smallestImage)
import Html exposing (Html, a, div, img, li, ol, text, ul)
import Html.Attributes exposing (href, src)
import List exposing (map)
import Maybe exposing (withDefault)
import Types exposing (Artist, Image, Msg, PagingObject, Profile, placeholderImage)


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

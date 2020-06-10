module Views exposing (..)

import Helper exposing (smallestImage)
import Html exposing (Html, a, button, div, img, li, ol, text, ul)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import List exposing (map)
import Maybe exposing (withDefault)
import Types exposing (Artist, AuthDetails, Image, Msg(..), PagingObject, Profile, TimeRange(..), placeholderImage)
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


profileView : Maybe Profile -> Html Msg
profileView maybeProfile =
    div []
        [ case maybeProfile of
            Nothing ->
                div [] [ text "User not logged in." ]

            Just profile ->
                div [] [ text profile.name, profileImage profile.images ]
        ]


authView : Url -> Maybe AuthDetails -> Html Msg
authView url maybeAuthDetails =
    let
        displayed =
            case maybeAuthDetails of
                Nothing ->
                    "display"

                Just _ ->
                    "hidden"
    in
    div [ class displayed ] [ a [ href <| spotifyAuthLink <| spotifyRedirectUrl url ] [ text "Spotify login" ] ]


topArtistsTimeRangeSelect : Html Msg
topArtistsTimeRangeSelect =
    ol []
        [ li [] [ button [ onClick <| TopArtistsTimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ] ]
        , li [] [ button [ onClick <| TopArtistsTimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ] ]
        , li [] [ button [ onClick <| TopArtistsTimeRangeSelected LongTerm ] [ text "Long term (several years)" ] ]
        ]

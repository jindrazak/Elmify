module Views exposing (..)

import Browser
import Helper exposing (smallestImage)
import Html exposing (Html, a, button, div, h3, img, li, ol, text, ul)
import Html.Attributes exposing (class, classList, href, src)
import Html.Events exposing (onClick)
import List exposing (map)
import Maybe exposing (withDefault)
import Types exposing (Artist, ArtistsPagingObject, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track, placeholderImage)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify"
    , body =
        [ authView model.url model.authDetails
        , profileView model.profile
        , topArtistsTimeRangeSelect model.topArtistsTimeRange
        , topArtistsView model.topArtists
        , topTracksTimeRangeSelect model.topTracksTimeRange
        , topTracksView model.topTracks
        ]
    }


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
        [ div [] [ profileImage artist.images ]
        , div [] [ text artist.name ]
        ]


trackLi : Track -> Html Msg
trackLi track =
    li []
        [ div [] [ text track.name ] ]


topArtistsView : List Artist -> Html Msg
topArtistsView list =
    case list of
        [] ->
            div [] [ text "No artists found." ]

        artists ->
            div []
                [ h3 [] [ text "Your top artists" ]
                , ol [] <| map artistLi artists
                ]


topTracksView : List Track -> Html Msg
topTracksView list =
    case list of
        [] ->
            div [] [ text "No tracks found." ]

        tracks ->
            div []
                [ h3 [] [ text "Your top tracks" ]
                , ol [] <| map trackLi tracks
                ]


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


topArtistsTimeRangeSelect : TimeRange -> Html Msg
topArtistsTimeRangeSelect timeRange =
    ol []
        [ li [] [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TopArtistsTimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TopArtistsTimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TopArtistsTimeRangeSelected LongTerm ] [ text "Long term (several years)" ] ]
        ]


topTracksTimeRangeSelect : TimeRange -> Html Msg
topTracksTimeRangeSelect timeRange =
    ol []
        [ li [] [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TopTracksTimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TopTracksTimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TopTracksTimeRangeSelected LongTerm ] [ text "Long term (several years)" ] ]
        ]

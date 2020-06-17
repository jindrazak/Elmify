module Views.Main exposing (..)

import Browser
import Html exposing (Html, a, button, div, footer, header, main_, p, text)
import Html.Attributes exposing (classList, href, id)
import Maybe
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)
import Views.Common exposing (logoView, profileView, timeRangeSelect)
import Views.TopArtists exposing (topArtistsView)
import Views.TopTracks exposing (topTracksView)
import Views.UserTastes exposing (userTastesView)


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify - stats about your listening tastes"
    , body =
        [ authView model.url model.authDetails
        , headerView model.profile model.authDetails
        , mainView model model.authDetails
        ]
            ++ (if model.authDetails /= Nothing then
                    [ footerView ]

                else
                    []
               )
    }


headerView : Maybe Profile -> Maybe AuthDetails -> Html Msg
headerView maybeProfile maybeAuthDetails =
    header [ classList [ ( "blur", maybeAuthDetails == Nothing ) ] ]
        [ logoView
        , profileView maybeProfile
        ]


mainView : Model -> Maybe AuthDetails -> Html Msg
mainView model maybeAuthDetails =
    main_ [ classList [ ( "blur", maybeAuthDetails == Nothing ) ] ]
        [ timeRangeSelect model.timeRange
        , div [ id "top-sections" ]
            [ topArtistsView model.topArtists
            , topTracksView model.topTracks
            , userTastesView model
            ]
        ]


footerView : Html Msg
footerView =
    footer []
        [ p []
            [ text "Created as a semestral project by Jindrich Zak during course MI-AFP at "
            , a [ href "https://fit.cvut.cz" ] [ text "CTU in Prague" ]
            , text ". Made using "
            , a [ href "https://elm-lang.org/" ] [ text "Elm" ]
            , text ". Source code on "
            , a [ href "https://github.com/jindrazak/elmify" ] [ text "GitHub." ]
            ]
        ]


authView : Url -> Maybe AuthDetails -> Html Msg
authView url maybeAuthDetails =
    div
        [ id "auth-container", classList [ ( "hidden", maybeAuthDetails /= Nothing ) ] ]
        [ div [ id "auth-dialogue" ]
            [ logoView
            , div [ id "auth-prompt" ]
                [ p [] [ text "First, you need to" ]
                , a [ href <| spotifyAuthLink <| spotifyRedirectUrl url ]
                    [ button [] [ text "login with Spotify" ] ]
                ]
            ]
        ]

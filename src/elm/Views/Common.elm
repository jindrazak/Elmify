module Views.Common exposing (..)

import Constants exposing (audioFeaturesConfigurations)
import Helper exposing (smallestImage)
import Html exposing (Html, a, button, div, h1, p, span, text)
import Html.Attributes exposing (class, classList, id, style)
import Html.Events exposing (onClick)
import List exposing (map)
import Maybe exposing (withDefault)
import String exposing (fromFloat)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track, placeholderImage)


profileView : Maybe Profile -> Html Msg
profileView maybeProfile =
    div [ id "profile-panel" ] <|
        case maybeProfile of
            Nothing ->
                [ div [ id "name-container" ] [ text "User not logged in." ] ]

            Just profile ->
                [ div [ id "name-container" ] [ text profile.name, a [ onClick Logout ] [ text "\u{00A0}| Logout" ] ]
                , profileImage profile.images
                ]


timeRangeSelect : TimeRange -> Html Msg
timeRangeSelect timeRange =
    div [ id "timerange-picker" ]
        [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ]
        , button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ]
        , button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TimeRangeSelected LongTerm ] [ text "Long term (several years)" ]
        ]


logoView : Html Msg
logoView =
    div [ id "logo-container" ]
        [ h1 [] [ text "elmify" ]
        , p [] [ text "Spotify stats about your listening tastes" ]
        ]


profileImage : List Image -> Html Msg
profileImage images =
    let
        image =
            withDefault placeholderImage <| smallestImage images
    in
    div [ class "image-container", style "background-image" <| "url(" ++ image.url ++ ")" ] []


simpleBarView : String -> Float -> String -> Html Msg
simpleBarView name percentage color =
    div [ class "simple-bar-container" ]
        [ p [] [ text name ]
        , div [ class "simple-bar" ]
            [ div
                [ class "simple-bar"
                , style "width" <| fromFloat percentage ++ "%"
                , style "background-color" color
                ]
                []
            ]
        ]


audioFeaturesHelpDialogue : Html Msg
audioFeaturesHelpDialogue =
    span [ class "help" ]
        [ text "?"
        , div [ class "help-container" ] <|
            map
                (\audioFeaturesConfiguration -> div [] [ p [] [ span [] [ text <| audioFeaturesConfiguration.name ++ ": " ], text audioFeaturesConfiguration.description ] ])
                audioFeaturesConfigurations
        ]

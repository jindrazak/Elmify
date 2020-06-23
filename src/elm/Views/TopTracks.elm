module Views.TopTracks exposing (..)

import Color
import Constants exposing (audioFeaturesConfigurations)
import Html exposing (Html, div, h2, li, ol, p, section, span, text)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
import List exposing (map)
import Maybe
import String exposing (join)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track)
import Views.Common exposing (audioFeaturesHelpDialogue, simpleBarView)


topTracksView : List Track -> Html Msg
topTracksView tracksList =
    section [ id "top-tracks" ]
        [ h2 [] [ text "Your top tracks", audioFeaturesHelpDialogue ]
        , case tracksList of
            [] ->
                p [] [ text "No tracks found." ]

            tracks ->
                ol [] <| map (\track -> trackLi (TrackExpanded track) trackDetails track) tracks
        ]


trackLi : Msg -> (Track -> Html Msg) -> Track -> Html Msg
trackLi clickCmd detailsContainer track =
    li []
        [ div [ class "track-container", class "li-main-container", onClick <| clickCmd ]
            [ p []
                [ text <| track.name
                , span [] [ text <| " - " ++ (join ", " <| map .name track.artists) ]
                ]
            ]
        , detailsContainer track
        ]


trackDetails : Track -> Html Msg
trackDetails track =
    div [ class "expandable", classList [ ( "expanded", track.expanded ) ] ] <|
        case track.audioFeatures of
            Nothing ->
                []

            Just audioFeatures ->
                map (audioFeatureView audioFeatures) audioFeaturesConfigurations


audioFeatureView : AudioFeatures -> AudioFeaturesConfiguration -> Html Msg
audioFeatureView audioFeature audioFeaturesConfiguration =
    let
        percentage =
            audioFeaturesConfiguration.accessor audioFeature
    in
    simpleBarView audioFeaturesConfiguration.name percentage (Color.toCssString audioFeaturesConfiguration.color)

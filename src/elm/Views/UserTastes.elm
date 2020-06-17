module Views.UserTastes exposing (..)

import Chart exposing (chartConfig, trackData, tracksAverageData)
import Chartjs.Chart as Chart
import Helper exposing (extractGenres, getMostFrequentStrings)
import Html exposing (Html, div, h2, h3, input, ol, p, section, text)
import Html.Attributes exposing (id, placeholder, value)
import Html.Events exposing (onInput)
import List exposing (any, map, take)
import Maybe
import String exposing (join)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track)
import Views.Common exposing (audioFeaturesHelpDialogue)
import Views.TopTracks exposing (trackDetails, trackLi)


userTastesView : Model -> Html Msg
userTastesView model =
    let
        maybeAudioFeatures =
            map .audioFeatures model.topTracks
    in
    section [ id "users-tastes" ] <|
        [ h2 [] [ text "Your tastes", audioFeaturesHelpDialogue ] ]
            ++ (case model.topTracks of
                    [] ->
                        [ text "No tracks found." ]

                    _ ->
                        if any (\x -> x == Nothing) maybeAudioFeatures then
                            [ p [] [ text "Loading audio features..." ] ]

                        else
                            [ Chart.chart [] (chartConfig <| tracksAverageData model.topTracks)
                            , topGenresView model
                            , h2 [] [ text "Search" ]
                            , input [ placeholder "Search for a track", value model.searchQuery, onInput SearchInputChanged ] []
                            , case model.searchTracks of
                                [] ->
                                    chartTrackView model

                                searchTracks ->
                                    ol [] <| map (\track -> trackLi (SelectedSearchedTrack track) trackDetails track) searchTracks
                            ]
               )


topGenresView : Model -> Html Msg
topGenresView model =
    div [ id "top-genres" ]
        [ h3 [] [ text "Most favourite genres: " ]
        , p [] [ text (join ", " <| getMostFrequentStrings <| take 10 <| extractGenres model.topArtists) ]
        ]


chartTrackView : Model -> Html Msg
chartTrackView model =
    case model.searchedTrack of
        Nothing ->
            div [] [ p [] [ text "No results." ] ]

        Just track ->
            case track.audioFeatures of
                Nothing ->
                    text "Loading audio features"

                Just audioFeatures ->
                    Chart.chart [] (chartConfig <| trackData audioFeatures)

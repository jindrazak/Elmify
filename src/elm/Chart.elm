module Chart exposing (..)

import Chartjs.Chart as Chart
import Chartjs.Common exposing (PointProperty(..), Position(..))
import Chartjs.Data as Data exposing (Data, DataSet(..), addDataset)
import Chartjs.DataSets.Polar exposing (defaultPolarFromData, setBorderColor, setHoverBackgroundColor)
import Chartjs.Options as Options
import Chartjs.Options.Legend as Legend exposing (defaultLegend)
import Color
import Constants exposing (audioFeaturesConfigurations)
import Helper exposing (averageAudioFeatureValue)
import List exposing (map)
import Maybe exposing (withDefault)
import Types exposing (AudioFeatures, Track)


tracksAverageData : List Track -> Data
tracksAverageData tracks =
    let
        labels =
            map .name audioFeaturesConfigurations

        values =
            map (\audioFeaturesConfiguration -> withDefault 0 <| averageAudioFeatureValue audioFeaturesConfiguration.accessor tracks) audioFeaturesConfigurations
    in
    addDataset
        (PolarData
            (defaultPolarFromData "User tastes" values
                |> setBorderColor (PerPoint <| map .color audioFeaturesConfigurations)
                |> setHoverBackgroundColor (PerPoint <| map .color audioFeaturesConfigurations)
            )
        )
        (Data.dataFromLabels labels)


trackData : AudioFeatures -> Data
trackData audioFeatures =
    let
        labels =
            map .name audioFeaturesConfigurations

        values =
            map (\audioFeaturesConfiguration -> audioFeaturesConfiguration.accessor audioFeatures) audioFeaturesConfigurations
    in
    addDataset
        (PolarData
            (defaultPolarFromData "User tastes" values
                |> setBorderColor (PerPoint <| map .color audioFeaturesConfigurations)
                |> setHoverBackgroundColor (PerPoint <| map .color audioFeaturesConfigurations)
            )
        )
        (Data.dataFromLabels labels)


chartConfig : Data -> Chart.Chart
chartConfig data =
    Chart.defaultChart Chart.Polar
        |> Chart.setData data
        |> Chart.setOptions
            (Options.defaultOptions
                |> Options.setResponsive True
                |> Options.setMaintainAspectRatio False
                |> Options.setLegend
                    (defaultLegend
                        |> Legend.setPosition Bottom
                    )
            )

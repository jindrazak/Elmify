module Chart exposing (..)

import Chartjs.Chart as Chart
import Chartjs.Data as Data exposing (DataSet(..))
import Chartjs.DataSets.Polar exposing (defaultPolarFromData)
import Constants exposing (audioFeaturesConfigurations)
import Helper exposing (averageAudioFeatureValue)
import List exposing (map)
import Maybe exposing (withDefault)
import Types exposing (Track)


data : List Track -> Data.Data
data tracks =
    let
        labels =
            map .name audioFeaturesConfigurations

        values =
            map (\audioFeaturesConfiguration -> withDefault 0 <| averageAudioFeatureValue audioFeaturesConfiguration.accessor tracks) audioFeaturesConfigurations
    in
    Data.addDataset (PolarData <| defaultPolarFromData "asdf" values) (Data.dataFromLabels labels)


chartConfig : List Track -> Chart.Chart
chartConfig tracks =
    Chart.defaultChart Chart.Polar
        |> Chart.setData (data tracks)

module Helper exposing (..)

import Dict exposing (Dict, get, insert, toList)
import List exposing (any, concatMap, foldl, foldr, length, map, reverse, sortBy)
import Maybe exposing (withDefault)
import Tuple exposing (first, second)
import Types exposing (Artist, AudioFeatures, Image, Track)


smallestImage : List Image -> Maybe Image
smallestImage list =
    case list of
        [] ->
            Nothing

        images ->
            Just <| foldl compareImageSizes (Image (Just 99999) (Just 99999) "") images


compareImageSizes : Image -> Image -> Image
compareImageSizes a b =
    let
        aArea =
            withDefault 1 a.width * withDefault 1 a.height

        bArea =
            withDefault 1 b.width * withDefault 1 b.height
    in
    if aArea < bArea then
        a

    else
        b


audioFeatureValue : (AudioFeatures -> Float) -> Track -> Maybe Float
audioFeatureValue audioFeatureAccessor track =
    case track.audioFeatures of
        Nothing ->
            Nothing

        Just audioFeatures ->
            Just <| audioFeatureAccessor <| audioFeatures


averageAudioFeatureValue : (AudioFeatures -> Float) -> List Track -> Maybe Float
averageAudioFeatureValue audioFeatureAccessor trackList =
    let
        maybeValues =
            map (audioFeatureValue audioFeatureAccessor) trackList

        values =
            map (\x -> withDefault 0 x) maybeValues
    in
    case trackList of
        [] ->
            Nothing

        _ ->
            if any (\x -> x == Nothing) maybeValues then
                Nothing

            else
                Just <| roundToOneDecimal <| foldl (+) 0 values / toFloat (length values)


normalizePercentage : AudioFeatures -> AudioFeatures
normalizePercentage audioFeatures =
    AudioFeatures
        (audioFeatures.acousticness * 100 |> roundToOneDecimal)
        (audioFeatures.danceability * 100 |> roundToOneDecimal)
        (audioFeatures.energy * 100 |> roundToOneDecimal)
        (audioFeatures.instrumentalness * 100 |> roundToOneDecimal)
        (audioFeatures.liveness * 100 |> roundToOneDecimal)
        (audioFeatures.speechiness * 100 |> roundToOneDecimal)
        (audioFeatures.valence * 100 |> roundToOneDecimal)
        -- Tempo normalization according to this diagram https://developer.spotify.com/assets/audio/tempo.png
        ((audioFeatures.tempo - 50) / 1.5 |> roundToOneDecimal)


roundToOneDecimal : Float -> Float
roundToOneDecimal n =
    (n * 10 |> round |> toFloat) / 10


extractGenres : List Artist -> List String
extractGenres artists =
    concatMap (\artist -> artist.genres) artists


getMostFrequentStrings : List String -> List String
getMostFrequentStrings strings =
    let
        counts =
            toList <| countOccurences strings

        sortedCounts =
            reverse <| sortBy second counts
    in
    map first sortedCounts


countOccurences : List String -> Dict String Int
countOccurences strings =
    foldr incrementDictValue Dict.empty strings


incrementDictValue : String -> Dict String Int -> Dict String Int
incrementDictValue key dict =
    let
        currentValue =
            get key dict
    in
    case currentValue of
        Nothing ->
            insert key 1 dict

        Just value ->
            insert key (value + 1) dict

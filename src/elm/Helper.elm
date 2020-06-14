module Helper exposing (..)

import List exposing (any, foldl, length, map)
import Maybe exposing (withDefault)
import Types exposing (AudioFeatures, Image, Track)


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
averageAudioFeatureValue audioFeatureAccessor tracks =
    let
        maybeValues =
            map (audioFeatureValue audioFeatureAccessor) tracks

        values =
            map (\x -> withDefault 0 x) maybeValues
    in
    if any (\x -> x == Nothing) maybeValues then
        Nothing

    else
        Just <| foldl (+) 0 values / toFloat (length values)


normalizePercentage : AudioFeatures -> AudioFeatures
normalizePercentage audioFeatures =
    AudioFeatures
        (audioFeatures.acousticness * 100)
        (audioFeatures.danceability * 100)
        (audioFeatures.energy * 100)
        (audioFeatures.instrumentalness * 100)
        (audioFeatures.liveness * 100)
        (audioFeatures.speechiness * 100)
        (audioFeatures.valence * 100)
        -- Tempo normalization according to this diagram https://developer.spotify.com/assets/audio/tempo.png
        ((audioFeatures.tempo - 50) / 1.5)

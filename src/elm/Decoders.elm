module Decoders exposing (..)

import Json.Decode as Decoder exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesList, Image, Profile, SimplifiedArtist, Track, TracksPagingObject)


profileDecoder : Decoder Profile
profileDecoder =
    Decoder.succeed Profile
        |> required "display_name" Decoder.string
        |> required "images" (Decoder.list imageDecoder)



-- Decodes Spotify paging object https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object


artistsPagingObjectDecoder : Decoder ArtistsPagingObject
artistsPagingObjectDecoder =
    Decoder.succeed ArtistsPagingObject
        |> required "items" (Decoder.list artistDecoder)


tracksPagingObjectDecoder : Decoder TracksPagingObject
tracksPagingObjectDecoder =
    Decoder.succeed TracksPagingObject
        |> required "items" (Decoder.list trackDecoder)


audioFeaturesListDecoder : Decoder AudioFeaturesList
audioFeaturesListDecoder =
    Decoder.succeed AudioFeaturesList
        |> required "audio_features" (Decoder.list audioFeaturesDecoder)



-- Decodes Spotify artist object https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full


artistDecoder : Decoder Artist
artistDecoder =
    Decoder.succeed Artist
        |> required "name" Decoder.string
        |> required "genres" (Decoder.list Decoder.string)
        |> required "images" (Decoder.list imageDecoder)
        |> required "popularity" Decoder.int
        |> hardcoded False


simplifiedArtistDecoder : Decoder SimplifiedArtist
simplifiedArtistDecoder =
    Decoder.succeed SimplifiedArtist
        |> required "name" Decoder.string


trackDecoder : Decoder Track
trackDecoder =
    Decoder.succeed Track
        |> required "id" Decoder.string
        |> required "name" Decoder.string
        |> required "artists" (Decoder.list simplifiedArtistDecoder)
        |> hardcoded Nothing
        |> hardcoded False


imageDecoder : Decoder Image
imageDecoder =
    Decoder.succeed Image
        |> required "width" (Decoder.nullable Decoder.int)
        |> required "height" (Decoder.nullable Decoder.int)
        |> required "url" Decoder.string


audioFeaturesDecoder : Decoder AudioFeatures
audioFeaturesDecoder =
    Decoder.succeed AudioFeatures
        |> required "acousticness" Decoder.float
        |> required "danceability" Decoder.float
        |> required "energy" Decoder.float
        |> required "instrumentalness" Decoder.float
        |> required "liveness" Decoder.float
        |> required "loudness" Decoder.float
        |> required "speechiness" Decoder.float
        |> required "valence" Decoder.float
        |> required "tempo" Decoder.float

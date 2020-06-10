module Decoders exposing (..)

import Json.Decode as Decoder exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Types exposing (Artist, ArtistsPagingObject, Image, Profile, Track, TracksPagingObject)


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



-- Decodes Spotify artist object https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full


artistDecoder : Decoder Artist
artistDecoder =
    Decoder.succeed Artist
        |> required "name" Decoder.string
        |> required "genres" (Decoder.list Decoder.string)
        |> required "images" (Decoder.list imageDecoder)
        |> required "popularity" Decoder.int


trackDecoder : Decoder Track
trackDecoder =
    Decoder.succeed Track
        |> required "name" Decoder.string


imageDecoder : Decoder Image
imageDecoder =
    Decoder.succeed Image
        |> required "width" (Decoder.nullable Decoder.int)
        |> required "height" (Decoder.nullable Decoder.int)
        |> required "url" Decoder.string

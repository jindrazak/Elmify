module Decoders exposing (..)

import Json.Decode as Decoder exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Types exposing (Artist, Image, PagingObject, Profile)


profileDecoder : Decoder Profile
profileDecoder =
    Decoder.succeed Profile
        |> required "display_name" Decoder.string
        |> required "images" (Decoder.list imageDecoder)



-- Decodes Spotify paging object https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object


pagingObjectDecoder : Decoder PagingObject
pagingObjectDecoder =
    Decoder.succeed PagingObject
        |> required "items" (Decoder.list artistDecoder)



-- Decodes Spotify artist object https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full


artistDecoder : Decoder Artist
artistDecoder =
    Decoder.succeed Artist
        |> required "name" Decoder.string
        |> required "genres" (Decoder.list Decoder.string)
        |> required "images" (Decoder.list imageDecoder)
        |> required "popularity" Decoder.int


imageDecoder : Decoder Image
imageDecoder =
    Decoder.succeed Image
        |> required "width" (Decoder.nullable Decoder.int)
        |> required "height" (Decoder.nullable Decoder.int)
        |> required "url" Decoder.string

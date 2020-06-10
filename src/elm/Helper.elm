module Helper exposing (..)

import List exposing (foldl, head)
import Maybe exposing (withDefault)
import Types exposing (Image, placeholderImage)


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

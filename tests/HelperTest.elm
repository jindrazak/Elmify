module HelperTest exposing (..)

import Dict exposing (get)
import Expect exposing (Expectation, FloatingPointTolerance(..), within)
import Helper exposing (countOccurences, getMostFrequentStrings, incrementDictValue, roundToOneDecimal)
import Test exposing (..)


suite : Test
suite =
    let
        counts =
            countOccurences [ "hello", "hello", "hi", "hello", "ahoj", "ahoj" ]
    in
    describe "Helper"
        [ describe "countOccurences"
            [ test "counts occurences of hello" <| \_ -> Expect.equal (Just 3) <| get "hello" counts
            , test "counts occurences of ahoj" <| \_ -> Expect.equal (Just 2) <| get "ahoj" counts
            , test "counts occurences of hi" <| \_ -> Expect.equal (Just 1) <| get "hi" counts
            , test "does not count strings which are not present" <| \_ -> Expect.equal Nothing <| get "hola" counts
            ]
        , describe "incrementDictValue"
            [ test "increments new key to 1" <|
                \_ -> Expect.equal (Just 1) <| get "hello" <| incrementDictValue "hello" Dict.empty
            , test "increments known key to 2" <|
                \_ -> Expect.equal (Just 2) <| get "hello" <| incrementDictValue "hello" <| incrementDictValue "hello" Dict.empty
            ]
        , describe "getMostFrequentStrings"
            [ test "works with empty lists" <|
                \_ -> Expect.equal [] <| getMostFrequentStrings []
            , test "works with nonempty lists" <|
                \_ -> Expect.equal [ "hello", "hi", "ahoj" ] <| getMostFrequentStrings [ "hi", "hello", "hello", "hi", "hello", "ahoj" ]
            ]
        , describe "roundToOneDecimal"
            [ test "works with zero" <|
                \_ -> within (Absolute 0.05) 0 <| roundToOneDecimal 0
            , test "works with integers" <|
                \_ -> within (Absolute 0.05) 42 <| roundToOneDecimal 42
            , test "works with decimal numbers" <|
                \_ -> within (Absolute 0.05) 42.2 <| roundToOneDecimal 42.17
            ]
        ]

module Views exposing (..)

import Browser
import Helper exposing (audioFeatureValue, averageAudioFeatureValue, smallestImage)
import Html exposing (Html, a, button, div, h3, img, li, ol, text)
import Html.Attributes exposing (class, classList, href, src)
import Html.Events exposing (onClick)
import List exposing (any, foldl, map, map2)
import Maybe exposing (withDefault)
import String exposing (fromFloat)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track, placeholderImage)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify"
    , body =
        [ authView model.url model.authDetails
        , profileView model.profile
        , topArtistsTimeRangeSelect model.topArtistsTimeRange
        , topArtistsView model.topArtists
        , topTracksTimeRangeSelect model.topTracksTimeRange
        , topTracksView model.topTracks
        , userTastesView model.topTracks
        ]
    }


profileImage : List Image -> Html Msg
profileImage images =
    let
        image =
            withDefault placeholderImage <| smallestImage images
    in
    img [ src image.url ] []


artistLi : Artist -> Html Msg
artistLi artist =
    li []
        [ div [] [ profileImage artist.images ]
        , div [] [ text artist.name ]
        ]


trackLi : Track -> Html Msg
trackLi track =
    li []
        [ div []
            [ text track.name
            , audioFeaturesView track.audioFeatures
            ]
        ]


audioFeaturesView : Maybe AudioFeatures -> Html Msg
audioFeaturesView maybeAudioFeatures =
    case maybeAudioFeatures of
        Nothing ->
            div [] []

        Just audioFeatures ->
            div []
                [ div [] [ text <| "Acousticness" ++ fromFloat audioFeatures.acousticness ]
                , div [] [ text <| "Danceability" ++ fromFloat audioFeatures.danceability ]
                , div [] [ text <| "Energy" ++ fromFloat audioFeatures.energy ]
                , div [] [ text <| "Instrumentalness" ++ fromFloat audioFeatures.instrumentalness ]
                , div [] [ text <| "Liveness" ++ fromFloat audioFeatures.liveness ]
                , div [] [ text <| "Loudness" ++ fromFloat audioFeatures.loudness ]
                , div [] [ text <| "Speechiness" ++ fromFloat audioFeatures.speechiness ]
                , div [] [ text <| "Valence" ++ fromFloat audioFeatures.valence ]
                , div [] [ text <| "Tempo" ++ fromFloat audioFeatures.tempo ]
                ]


topArtistsView : List Artist -> Html Msg
topArtistsView list =
    case list of
        [] ->
            div [] [ text "No artists found." ]

        artists ->
            div []
                [ h3 [] [ text "Your top artists" ]
                , ol [] <| map artistLi artists
                ]


topTracksView : List Track -> Html Msg
topTracksView tracksList =
    case tracksList of
        [] ->
            div [] [ text "No tracks found." ]

        tracks ->
            div []
                [ h3 [] [ text "Your top tracks" ]
                , ol [] <| map trackLi tracks
                ]


userTastesView : List Track -> Html Msg
userTastesView tracksList =
    let
        maybeAudioFeatures =
            map .audioFeatures tracksList
    in
    case tracksList of
        [] ->
            div [] [ text "No tracks found." ]

        _ ->
            if any (\x -> x == Nothing) maybeAudioFeatures then
                text "Loading audio features..."

            else
                div []
                    [ h3 [] [ text "Your tastes" ]
                    , text <| "Acousticness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .acousticness tracksList)
                    , text <| "Danceability " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .danceability tracksList)
                    , text <| "Energy " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .energy tracksList)
                    , text <| "Instrumentalness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .instrumentalness tracksList)
                    , text <| "Liveness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .liveness tracksList)
                    , text <| "Loudness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .loudness tracksList)
                    , text <| "Speechiness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .speechiness tracksList)
                    , text <| "Valence " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .valence tracksList)
                    , text <| "Tempo " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .tempo tracksList)
                    ]


profileView : Maybe Profile -> Html Msg
profileView maybeProfile =
    div []
        [ case maybeProfile of
            Nothing ->
                div [] [ text "User not logged in." ]

            Just profile ->
                div [] [ text profile.name, profileImage profile.images ]
        ]


authView : Url -> Maybe AuthDetails -> Html Msg
authView url maybeAuthDetails =
    let
        displayed =
            case maybeAuthDetails of
                Nothing ->
                    "display"

                Just _ ->
                    "hidden"
    in
    div [ class displayed ] [ a [ href <| spotifyAuthLink <| spotifyRedirectUrl url ] [ text "Spotify login" ] ]


topArtistsTimeRangeSelect : TimeRange -> Html Msg
topArtistsTimeRangeSelect timeRange =
    ol []
        [ li [] [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TopArtistsTimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TopArtistsTimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TopArtistsTimeRangeSelected LongTerm ] [ text "Long term (several years)" ] ]
        ]


topTracksTimeRangeSelect : TimeRange -> Html Msg
topTracksTimeRangeSelect timeRange =
    ol []
        [ li [] [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TopTracksTimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TopTracksTimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ] ]
        , li [] [ button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TopTracksTimeRangeSelected LongTerm ] [ text "Long term (several years)" ] ]
        ]

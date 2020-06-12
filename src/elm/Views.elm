module Views exposing (..)

import Browser
import Helper exposing (averageAudioFeatureValue, smallestImage)
import Html exposing (Html, a, button, div, h1, h3, header, img, li, main_, ol, p, section, text, ul)
import Html.Attributes exposing (class, classList, href, id, src, style)
import Html.Events exposing (onClick)
import List exposing (any, map)
import Maybe exposing (withDefault)
import String exposing (fromFloat)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track, placeholderImage)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify"
    , body =
        [ headerView model.url model.authDetails model.profile
        , mainView model.timeRange model.topArtists model.topTracks
        ]
    }


profileImage : List Image -> Html Msg
profileImage images =
    let
        image =
            withDefault placeholderImage <| smallestImage images
    in
    div [ class "image-container", style "background-image" <| "url(" ++ image.url ++ ")" ] []


artistLi : Artist -> Html Msg
artistLi artist =
    li []
        [ div [] [ profileImage artist.images ]
        , div [ class "artist-name-container" ] [ text artist.name ]
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
    section [ id "top-artists" ] <|
        case list of
            [] ->
                [ text "No artists found." ]

            artists ->
                [ h3 [] [ text "Your top artists" ]
                , ol [] <| map artistLi artists
                ]


topTracksView : List Track -> Html Msg
topTracksView tracksList =
    section [ id "top-tracks" ] <|
        case tracksList of
            [] ->
                [ text "No tracks found." ]

            tracks ->
                [ h3 [] [ text "Your top tracks" ]
                , ol [] <| map trackLi tracks
                ]


userTastesView : List Track -> Html Msg
userTastesView tracksList =
    let
        maybeAudioFeatures =
            map .audioFeatures tracksList
    in
    section [ id "users-tastes" ] <|
        case tracksList of
            [] ->
                [ text "No tracks found." ]

            _ ->
                if any (\x -> x == Nothing) maybeAudioFeatures then
                    [ p [] [ text "Loading audio features..." ] ]

                else
                    [ h3 [] [ text "Your tastes" ]
                    , ul []
                        [ li [] [ text <| "Acousticness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .acousticness tracksList) ]
                        , li [] [ text <| "Danceability " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .danceability tracksList) ]
                        , li [] [ text <| "Energy " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .energy tracksList) ]
                        , li [] [ text <| "Instrumentalness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .instrumentalness tracksList) ]
                        , li [] [ text <| "Liveness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .liveness tracksList) ]
                        , li [] [ text <| "Loudness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .loudness tracksList) ]
                        , li [] [ text <| "Speechiness " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .speechiness tracksList) ]
                        , li [] [ text <| "Valence " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .valence tracksList) ]
                        , li [] [ text <| "Tempo " ++ fromFloat (withDefault 0 <| averageAudioFeatureValue .tempo tracksList) ]
                        ]
                    ]


profileView : Maybe Profile -> Html Msg
profileView maybeProfile =
    div [ id "profile-panel" ]
        [ case maybeProfile of
            Nothing ->
                div [] [ text "User not logged in." ]

            Just profile ->
                div [] [ text profile.name, profileImage profile.images ]
        ]


headerView : Url -> Maybe AuthDetails -> Maybe Profile -> Html Msg
headerView url maybeAuthDetails maybeProfile =
    header []
        [ h1 [] [ text "Elmify" ]
        , authView url maybeAuthDetails
        , profileView maybeProfile
        ]


mainView : TimeRange -> List Artist -> List Track -> Html Msg
mainView timeRange topArtists topTracks =
    main_ []
        [ timeRangeSelect timeRange
        , div [ id "top-sections" ]
            [ topArtistsView topArtists
            , topTracksView topTracks
            , userTastesView topTracks
            ]
        ]


authView : Url -> Maybe AuthDetails -> Html Msg
authView url maybeAuthDetails =
    div [ classList [ ( "hidden", maybeAuthDetails /= Nothing ) ] ] [ a [ href <| spotifyAuthLink <| spotifyRedirectUrl url ] [ text "Spotify login" ] ]


timeRangeSelect : TimeRange -> Html Msg
timeRangeSelect timeRange =
    div [ id "timerange-picker" ]
        [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ]
        , button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ]
        , button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TimeRangeSelected LongTerm ] [ text "Long term (several years)" ]
        ]

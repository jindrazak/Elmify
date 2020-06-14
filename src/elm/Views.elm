module Views exposing (..)

import Browser
import Constants exposing (audioFeaturesConfigurations)
import Helper exposing (averageAudioFeatureValue, smallestImage)
import Html exposing (Html, a, button, div, h1, h2, header, li, main_, ol, p, section, span, text, ul)
import Html.Attributes exposing (class, classList, href, id, style)
import Html.Events exposing (onClick)
import List exposing (any, map, map2)
import Maybe exposing (withDefault)
import String exposing (fromFloat, join)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track, placeholderImage)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify - Spotify stats"
    , body =
        [ authView model.url model.authDetails
        , headerView model.profile
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
    li [ onClick <| ArtistExpanded artist ]
        [ div [ class "artist-container" ]
            [ profileImage artist.images
            , p [] [ text <| artist.name ]
            ]
        , artistDetails artist
        ]


artistDetails : Artist -> Html Msg
artistDetails artist =
    div [ class "expandable", classList [ ( "expanded", artist.expanded ) ] ]
        [ popularityView artist
        , p []
            [ p []
                [ text "Genres: "
                , span [ class "genres" ] [ text <| join ", " artist.genres ]
                ]
            ]
        ]


trackLi : Track -> Html Msg
trackLi track =
    li [ onClick <| TrackExpanded track ]
        [ div [ class "track-container" ]
            [ p []
                [ text <| track.name
                , span [] [ text <| " - " ++ (join ", " <| map .name track.artists) ]
                ]
            ]
        , trackDetails track
        ]


trackDetails : Track -> Html Msg
trackDetails track =
    div [ class "expandable", classList [ ( "expanded", track.expanded ) ] ] <|
        case track.audioFeatures of
            Nothing ->
                []

            Just audioFeatures ->
                map (audioFeatureView audioFeatures) audioFeaturesConfigurations


audioFeatureView : AudioFeatures -> AudioFeaturesConfiguration -> Html Msg
audioFeatureView audioFeature audioFeaturesConfiguration =
    let
        percentage =
            case audioFeaturesConfiguration.name of
                "Tempo" ->
                    audioFeaturesConfiguration.accessor audioFeature / 2

                _ ->
                    audioFeaturesConfiguration.accessor audioFeature * 100
    in
    simpleBarView audioFeaturesConfiguration.name percentage audioFeaturesConfiguration.color


popularityView : Artist -> Html Msg
popularityView artist =
    simpleBarView "Popularity" (toFloat artist.popularity) "#ff1493"


simpleBarView : String -> Float -> String -> Html Msg
simpleBarView name percentage color =
    div [ class "simple-bar-container" ]
        [ p [] [ text name ]
        , div [ class "simple-bar" ]
            [ div
                [ class "simple-bar"
                , style "width" <| fromFloat percentage ++ "%"
                , style "background-color" color
                ]
                []
            ]
        ]


topArtistsView : List Artist -> Html Msg
topArtistsView list =
    section [ id "top-artists" ] <|
        case list of
            [] ->
                [ text "No artists found." ]

            artists ->
                [ h2 [] [ text "Your top artists" ]
                , ol [] <| map artistLi artists
                ]


topTracksView : List Track -> Html Msg
topTracksView tracksList =
    section [ id "top-tracks" ] <|
        case tracksList of
            [] ->
                [ text "No tracks found." ]

            tracks ->
                [ h2 [] [ text "Your top tracks" ]
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
                    [ h2 [] [ text "Your tastes" ]
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
    div [ id "profile-panel" ] <|
        case maybeProfile of
            Nothing ->
                [ div [ id "name-container" ] [ text "User not logged in." ] ]

            Just profile ->
                [ div [ id "name-container" ] [ text profile.name, a [] [ text "\u{00A0}| Logout" ] ]
                , profileImage profile.images
                ]


headerView : Maybe Profile -> Html Msg
headerView maybeProfile =
    header []
        [ logoView
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


logoView : Html Msg
logoView =
    div [ id "logo-container" ]
        [ h1 [] [ text "elmify" ]
        , p [] [ text "Spotify stats about your listening tastes" ]
        ]


authView : Url -> Maybe AuthDetails -> Html Msg
authView url maybeAuthDetails =
    div
        [ id "auth-container", classList [ ( "hidden", maybeAuthDetails /= Nothing ) ] ]
        [ div [ id "auth-dialogue" ]
            [ logoView
            , div [ id "auth-prompt" ]
                [ p [] [ text "First, you need to" ]
                , a [ href <| spotifyAuthLink <| spotifyRedirectUrl url ]
                    [ button [] [ text "login with Spotify" ] ]
                , p [] [ text "." ]
                ]
            ]
        ]


timeRangeSelect : TimeRange -> Html Msg
timeRangeSelect timeRange =
    div [ id "timerange-picker" ]
        [ button [ classList [ ( "active", timeRange == ShortTerm ) ], onClick <| TimeRangeSelected ShortTerm ] [ text "Short term (4 weeks)" ]
        , button [ classList [ ( "active", timeRange == MediumTerm ) ], onClick <| TimeRangeSelected MediumTerm ] [ text "Medium term (6 months)" ]
        , button [ classList [ ( "active", timeRange == LongTerm ) ], onClick <| TimeRangeSelected LongTerm ] [ text "Long term (several years)" ]
        ]

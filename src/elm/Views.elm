module Views exposing (..)

import Browser
import Chart exposing (chartConfig, trackData, tracksAverageData)
import Chartjs.Chart as Chart
import Constants exposing (audioFeaturesConfigurations)
import Helper exposing (smallestImage)
import Html exposing (Html, a, button, div, footer, h1, h2, header, input, li, main_, ol, p, section, span, text)
import Html.Attributes exposing (class, classList, href, id, placeholder, style, value)
import Html.Events exposing (onClick, onInput, onMouseDown)
import List exposing (any, map)
import Maybe exposing (withDefault)
import String exposing (fromFloat, join)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track, placeholderImage)
import Url exposing (Url)
import UrlHelper exposing (spotifyAuthLink, spotifyRedirectUrl)


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify - stats about your listening tastes"
    , body =
        [ authView model.url model.authDetails
        , headerView model.profile
        , mainView model
        , if model.authDetails /= Nothing then
            footerView

          else
            text ""
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
    li [ onMouseDown <| ArtistExpanded artist ]
        [ div [ class "artist-container", class "li-main-container" ]
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


trackLi : Msg -> (Track -> Html Msg) -> Track -> Html Msg
trackLi clickCmd detailsContainer track =
    li []
        [ div [ class "track-container", class "li-main-container", onClick <| clickCmd ]
            [ p []
                [ text <| track.name
                , span [] [ text <| " - " ++ (join ", " <| map .name track.artists) ]
                ]
            ]
        , detailsContainer track
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
            audioFeaturesConfiguration.accessor audioFeature
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
    section [ id "top-artists" ]
        [ h2 [] [ text "Your top artists" ]
        , case list of
            [] ->
                p [] [ text "No artists found." ]

            artists ->
                ol [] <| map artistLi artists
        ]


topTracksView : List Track -> Html Msg
topTracksView tracksList =
    section [ id "top-tracks" ]
        [ h2 [] [ text "Your top tracks", audioFeaturesHelpDalogue ]
        , case tracksList of
            [] ->
                p [] [ text "No tracks found." ]

            tracks ->
                ol [] <| map (\track -> trackLi (TrackExpanded track) trackDetails track) tracks
        ]


audioFeaturesHelpDalogue : Html Msg
audioFeaturesHelpDalogue =
    span [ class "help" ]
        [ text "?"
        , div [ class "help-container" ] <|
            map
                (\audioFeaturesConfiguration -> div [] [ p [] [ span [] [ text <| audioFeaturesConfiguration.name ++ ": " ], text audioFeaturesConfiguration.description ] ])
                audioFeaturesConfigurations
        ]


userTastesView : Model -> Html Msg
userTastesView model =
    let
        maybeAudioFeatures =
            map .audioFeatures model.topTracks
    in
    section [ id "users-tastes" ] <|
        [ h2 [] [ text "Your tastes", audioFeaturesHelpDalogue ] ]
            ++ (case model.topTracks of
                    [] ->
                        [ text "No tracks found." ]

                    _ ->
                        if any (\x -> x == Nothing) maybeAudioFeatures then
                            [ p [] [ text "Loading audio features..." ] ]

                        else
                            [ Chart.chart [] (chartConfig <| tracksAverageData model.topTracks)
                            , h2 [] [ text "Search" ]
                            , input [ placeholder "Search for a track", value model.searchQuery, onInput SearchInputChanged ] []
                            , case model.searchTracks of
                                [] ->
                                    chartTrackView model

                                searchTracks ->
                                    ol [] <| map (\track -> trackLi (SelectedSearchedTrack track) trackDetails track) searchTracks
                            ]
               )


chartTrackView : Model -> Html Msg
chartTrackView model =
    case model.searchedTrack of
        Nothing ->
            div [] [ p [] [ text "No results." ] ]

        Just track ->
            case track.audioFeatures of
                Nothing ->
                    text "Loading audio features"

                Just audioFeatures ->
                    Chart.chart [] (chartConfig <| trackData audioFeatures)


profileView : Maybe Profile -> Html Msg
profileView maybeProfile =
    div [ id "profile-panel" ] <|
        case maybeProfile of
            Nothing ->
                [ div [ id "name-container" ] [ text "User not logged in." ] ]

            Just profile ->
                [ div [ id "name-container" ] [ text profile.name, a [ onClick Logout ] [ text "\u{00A0}| Logout" ] ]
                , profileImage profile.images
                ]


headerView : Maybe Profile -> Html Msg
headerView maybeProfile =
    header []
        [ logoView
        , profileView maybeProfile
        ]


mainView : Model -> Html Msg
mainView model =
    main_ []
        [ timeRangeSelect model.timeRange
        , div [ id "top-sections" ]
            [ topArtistsView model.topArtists
            , topTracksView model.topTracks
            , userTastesView model
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


footerView : Html Msg
footerView =
    footer []
        [ p []
            [ text "Created as a semestral project by Jindrich Zak during course MI-AFP at "
            , a [ href "https://fit.cvut.cz" ] [ text "CTU in Prague" ]
            , text ". Made using "
            , a [ href "https://elm-lang.org/" ] [ text "Elm" ]
            , text ". Source code on "
            , a [ href "https://github.com/jindrazak/elmify" ] [ text "GitHub." ]
            ]
        ]

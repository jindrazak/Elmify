module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (pushUrl, replaceUrl)
import Constants exposing (defaultModel)
import Helper exposing (normalizePercentage)
import Http exposing (Error(..))
import List exposing (map, map2)
import Maybe exposing (withDefault)
import Platform.Cmd exposing (batch)
import Requests exposing (getAudioFeatures, getProfile, getSearchedTrackAudioFeatures, getTrackSearch, getUsersTopArtists, getUsersTopTracks)
import String exposing (length)
import Types exposing (Artist, Docs, Model, Msg(..), Profile, TimeRange(..))
import Url exposing (Protocol(..), Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, fragment, string)
import UrlHelper exposing (extractFromQueryString)
import Views exposing (view)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


routeParser : Parser (Docs -> a) a
routeParser =
    Parser.map Tuple.pair (string </> fragment identity)



-- MODEL


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            defaultModel key url
    in
    case Parser.parse routeParser url of
        Just ( "login-redirect", fragment ) ->
            let
                maybeAccessToken =
                    extractFromQueryString (withDefault "" fragment) "access_token"
            in
            case maybeAccessToken of
                Just accessToken ->
                    ( { model | route = Parser.parse routeParser url, authDetails = Just { accessToken = accessToken } }
                    , Cmd.batch [ getProfile accessToken, getUsersTopArtists accessToken ShortTerm, getUsersTopTracks accessToken ShortTerm, pushUrl key "/" ]
                    )

                Maybe.Nothing ->
                    ( { model | route = Parser.parse routeParser url }, Cmd.none )

        _ ->
            ( { model | route = Parser.parse routeParser url }, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | route = Parser.parse routeParser url }, Cmd.none )

        GotProfile result ->
            case result of
                Ok profile ->
                    ( { model | profile = Just profile }, Cmd.none )

                Err error ->
                    handleError error model

        GotTopArtists result ->
            case result of
                Ok pagingObject ->
                    ( { model | topArtists = pagingObject.artists }, Cmd.none )

                Err error ->
                    handleError error model

        GotTopTracks result ->
            case result of
                Ok pagingObject ->
                    ( { model | topTracks = pagingObject.tracks }
                    , case model.authDetails of
                        Nothing ->
                            Cmd.none

                        Maybe.Just authDetails ->
                            getAudioFeatures authDetails.accessToken pagingObject.tracks
                    )

                Err error ->
                    handleError error model

        GotAudioFeatures result ->
            case result of
                Ok audioFeaturesList ->
                    let
                        topTracks =
                            map2 (\track audioFeatures -> { track | audioFeatures = Just <| normalizePercentage audioFeatures }) model.topTracks audioFeaturesList.audioFeatures
                    in
                    ( { model | topTracks = topTracks }, Cmd.none )

                Err error ->
                    handleError error model

        TimeRangeSelected timeRange ->
            let
                cmd =
                    case model.authDetails of
                        Nothing ->
                            Cmd.none

                        Maybe.Just authDetails ->
                            batch [ getUsersTopArtists authDetails.accessToken timeRange, getUsersTopTracks authDetails.accessToken timeRange ]
            in
            ( { model | timeRange = timeRange }, cmd )

        TrackExpanded track ->
            let
                topTracks =
                    map
                        (\topTrack ->
                            if topTrack == track then
                                { topTrack | expanded = not topTrack.expanded }

                            else
                                topTrack
                        )
                        model.topTracks
            in
            ( { model | topTracks = topTracks }, Cmd.none )

        ArtistExpanded artist ->
            let
                topArtists =
                    map
                        (\topArtist ->
                            if topArtist == artist then
                                { topArtist | expanded = not topArtist.expanded }

                            else
                                topArtist
                        )
                        model.topArtists
            in
            ( { model | topArtists = topArtists }, Cmd.none )

        GotSearchTracks result ->
            case result of
                Ok pagingObject ->
                    ( { model | searchTracks = pagingObject.tracksPo.tracks }, Cmd.none )

                Err error ->
                    handleError error model

        SearchInputChanged searchQuery ->
            let
                cmd =
                    case model.authDetails of
                        Nothing ->
                            Cmd.none

                        Maybe.Just authDetails ->
                            if length searchQuery > 0 then
                                getTrackSearch authDetails.accessToken searchQuery

                            else
                                Cmd.none
            in
            ( { model | searchQuery = searchQuery, searchedTrack = Nothing }, cmd )

        SelectedSearchedTrack searchedTrack ->
            let
                cmd =
                    case model.authDetails of
                        Nothing ->
                            Cmd.none

                        Maybe.Just authDetails ->
                            getSearchedTrackAudioFeatures authDetails.accessToken searchedTrack
            in
            ( { model | searchedTrack = Just searchedTrack, searchTracks = [], searchQuery = searchedTrack.name }, cmd )

        GotSearchedTrackAudioFeatures result ->
            case result of
                Ok audioFeatures ->
                    let
                        updatedSearchedTrack =
                            case model.searchedTrack of
                                Nothing ->
                                    Nothing

                                Just searchedTrack ->
                                    Just { searchedTrack | audioFeatures = Just (normalizePercentage audioFeatures) }
                    in
                    ( { model | searchedTrack = updatedSearchedTrack }, Cmd.none )

                Err error ->
                    handleError error model

        Logout ->
            let
                cleanModel =
                    defaultModel model.key model.url
            in
            ( { cleanModel | route = model.route }, pushUrl model.key "/logout" )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


handleError : Error -> Model -> ( Model, Cmd Msg )
handleError error model =
    case error of
        BadStatus 401 ->
            ( { model | authDetails = Nothing }, Cmd.none )

        _ ->
            ( model, Cmd.none )

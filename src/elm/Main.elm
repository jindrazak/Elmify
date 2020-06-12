module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Http exposing (Error(..))
import List exposing (map2)
import Maybe exposing (withDefault)
import Platform.Cmd exposing (batch)
import Requests exposing (getAudioFeatures, getProfile, getUsersTopArtists, getUsersTopTracks)
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
    case Parser.parse routeParser url of
        Just ( "login-redirect", fragment ) ->
            let
                maybeAccessToken =
                    extractFromQueryString (withDefault "" fragment) "access_token"
            in
            case maybeAccessToken of
                Just accessToken ->
                    ( Model key url (Parser.parse routeParser url) (Just { accessToken = accessToken }) Nothing [] ShortTerm [], Cmd.batch [ getProfile accessToken, getUsersTopArtists accessToken ShortTerm, getUsersTopTracks accessToken ShortTerm ] )

                Maybe.Nothing ->
                    ( Model key url (Parser.parse routeParser url) Nothing Nothing [] ShortTerm [], Cmd.none )

        _ ->
            ( Model key url (Parser.parse routeParser url) Nothing Nothing [] ShortTerm [], Cmd.none )



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
                            map2 (\track audioFeatures -> { track | audioFeatures = Just audioFeatures }) model.topTracks audioFeaturesList.audioFeatures
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

module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href)
import Http exposing (Error(..))
import Maybe exposing (withDefault)
import Requests exposing (getProfile, getUsersTopArtists)
import Types exposing (Artist, Docs, Model, Msg(..), Profile)
import Url exposing (Protocol(..), Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, fragment, string)
import UrlHelper exposing (extractFromQueryString, spotifyAuthLink, spotifyRedirectUrl)
import Views exposing (profileImage, topArtistsView)



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
                    ( Model key url (Parser.parse routeParser url) (Just { accessToken = accessToken }) Nothing [], loadData accessToken )

                Maybe.Nothing ->
                    ( Model key url (Parser.parse routeParser url) Nothing Nothing [], Cmd.none )

        _ ->
            ( Model key url (Parser.parse routeParser url) Nothing Nothing [], Cmd.none )



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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify"
    , body =
        [ case model.authDetails of
            Nothing ->
                div [] [ a [ href <| spotifyAuthLink <| spotifyRedirectUrl model.url ] [ text "Spotify login" ] ]

            Just _ ->
                div [] [ text "Succesfully logged in." ]
        , case model.profile of
            Nothing ->
                div [] []

            Just profile ->
                div [] [ text profile.name, profileImage profile.images ]
        , topArtistsView model.topArtists
        ]
    }


loadData : String -> Cmd Msg
loadData accessToken =
    Cmd.batch [ getProfile accessToken, getUsersTopArtists accessToken ]


handleError : Error -> Model -> ( Model, Cmd Msg )
handleError error model =
    case error of
        BadStatus 401 ->
            ( { model | authDetails = Nothing }, Cmd.none )

        _ ->
            ( model, Cmd.none )

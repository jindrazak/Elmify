module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decoder exposing (Decoder)
import Maybe exposing (withDefault)
import Tuple exposing (first, second)
import Url exposing (Protocol(..), Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, fragment, map, oneOf, s, string)
import Url.Parser.Query as Query


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


type alias Docs =
    ( String, Maybe String )


routeParser : Parser (Docs -> a) a
routeParser =
    Parser.map Tuple.pair (string </> fragment identity)



-- MODEL


type alias AuthDetails =
    { accessToken : String }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Maybe Docs
    , authDetails : Maybe AuthDetails
    , displayName : Maybe String
    }


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
                    ( Model key url (Parser.parse routeParser url) (Just { accessToken = accessToken }) Nothing, getProfileDetails accessToken )

                Maybe.Nothing ->
                    ( Model key url (Parser.parse routeParser url) Nothing Nothing, Cmd.none )

        _ ->
            ( Model key url (Parser.parse routeParser url) Nothing Nothing, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotProfileDetails (Result Http.Error String)


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

        GotProfileDetails result ->
            case result of
                Ok displayName ->
                    ( { model | displayName = Just displayName }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Elmify"
    , body =
        [
        case model.authDetails of
            Nothing ->
                div [] [ a [ href <| spotifyAuthLink <| spotifyRedirectUrl model.url ] [ text "Spotify login" ] ]
            Just authDetails ->
                div [] [ text "Succesfully logged in." ]
        , case model.displayName of
            Nothing ->
                div [] []

            Just displayName ->
                div [] [ text displayName ]
        ]
    }


spotifyAuthLink : Url -> String
spotifyAuthLink redirectUrl =
    Builder.crossOrigin "https://accounts.spotify.com" [ "authorize" ] [ Builder.string "client_id" "6706db46b52f4ffb99a27f16a7cc2338", Builder.string "response_type" "token", Builder.string "redirect_uri" <| Url.toString redirectUrl ]


spotifyRedirectUrl : Url -> Url
spotifyRedirectUrl url =
    let
        baseUrl =
            extractBaseUrl url
    in
    { baseUrl | path = "/login-redirect" }


extractBaseUrl : Url -> Url
extractBaseUrl url =
    { url | path = "", query = Nothing, fragment = Nothing }


extractFromQueryString : String -> String -> Maybe String
extractFromQueryString queryString key =
    let
        url =
            Url Https "" Nothing "" (Just queryString) Nothing
    in
    withDefault Nothing (Parser.parse (Parser.query (Query.string key)) url)


getProfileDetails : String -> Cmd Msg
getProfileDetails accessToken =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = "https://api.spotify.com/v1/me"
        , expect = Http.expectJson GotProfileDetails profileDetailsDecoder
        }


profileDetailsDecoder : Decoder String
profileDetailsDecoder =
    Decoder.field "display_name" Decoder.string

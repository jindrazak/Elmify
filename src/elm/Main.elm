module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (href, src)
import Http
import Json.Decode as Decoder exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import List exposing (head)
import Maybe exposing (withDefault)
import Url exposing (Protocol(..), Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, fragment, string)
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

type alias Profile =
    { name : String, images : List Image }

type alias Image =
    { width : Maybe Int, height : Maybe Int, url : String }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Maybe Docs
    , authDetails : Maybe AuthDetails
    , profile : Maybe Profile
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
                    ( Model key url (Parser.parse routeParser url) (Just { accessToken = accessToken }) Nothing, getProfile accessToken )

                Maybe.Nothing ->
                    ( Model key url (Parser.parse routeParser url) Nothing Nothing, Cmd.none )

        _ ->
            ( Model key url (Parser.parse routeParser url) Nothing Nothing, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotProfile (Result Http.Error Profile)


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
            Just _ ->
                div [] [ text "Succesfully logged in." ]
        , case model.profile of
            Nothing ->
                div [] []

            Just profile ->
                div [] [ text profile.name, profilePicture profile ]
        ]
    }

profilePicture : Profile -> Html msg
profilePicture profile =
    let
        firstImage = head profile.images
        url = case firstImage of
            Nothing -> "https://picsum.photos/128"
            Just image -> image.url
    in
        img [src url] []



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


getProfile : String -> Cmd Msg
getProfile accessToken =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , url = "https://api.spotify.com/v1/me"
        , expect = Http.expectJson GotProfile profileDecoder
        }


profileDecoder : Decoder Profile
profileDecoder =
    Decoder.succeed Profile
        |> required "display_name" Decoder.string
        |> required "images" (Decoder.list imageDecoder)


imageDecoder : Decoder Image
imageDecoder =
    Decoder.succeed Image
        |> required "width" (Decoder.nullable Decoder.int)
        |> required "height" (Decoder.nullable Decoder.int)
        |> required "url" Decoder.string

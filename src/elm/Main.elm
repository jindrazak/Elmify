port module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (load, pushUrl)
import Constants exposing (defaultModel)
import Helper exposing (normalizePercentage)
import Http exposing (Error(..))
import List exposing (map, map2)
import Maybe exposing (withDefault)
import Platform.Cmd exposing (batch)
import Requests exposing (exchangeCodeForToken, getAudioFeatures, getProfile, getSearchedTrackAudioFeatures, getTrackSearch, getUsersTopArtists, getUsersTopTracks)
import String exposing (length)
import Types exposing (Artist, Docs, Model, Msg(..), Profile, TimeRange(..))
import Url exposing (Protocol(..), Url)
import Url.Parser as Parser exposing ((</>), Parser, fragment, string)
import UrlHelper exposing (extractFromQueryString, spotifyAuthUrl, spotifyRedirectUrl)
import Views.Main exposing (view)


-- PORTS for PKCE Authentication


{-| Request JavaScript to generate PKCE code verifier and challenge.
-}
port requestPkceChallenge : () -> Cmd msg


{-| Request JavaScript to retrieve the stored code verifier.
-}
port requestCodeVerifier : () -> Cmd msg


{-| Receive the code challenge from JavaScript (for building auth URL).
-}
port receiveCodeChallenge : (String -> msg) -> Sub msg


{-| Receive the code verifier from JavaScript (for token exchange).
-}
port receiveCodeVerifier : (String -> msg) -> Sub msg


{-| Receive authentication errors from JavaScript.
-}
port receiveAuthError : (String -> msg) -> Sub msg



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
init _ url key =
    let
        model =
            defaultModel key url
    in
    case url.path of
        "/login-redirect" ->
            -- PKCE flow: extract authorization code from query params
            case url.query of
                Just queryString ->
                    case extractFromQueryString queryString "code" of
                        Just code ->
                            -- Store code and request verifier from JS
                            ( { model | route = Parser.parse routeParser url, pendingAuthCode = Just code }
                            , requestCodeVerifier ()
                            )

                        Nothing ->
                            ( { model | route = Parser.parse routeParser url }, Cmd.none )

                Nothing ->
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
                        Just authDetails ->
                            getAudioFeatures authDetails.accessToken pagingObject.tracks

                        Nothing ->
                            Cmd.none
                    )

                Err error ->
                    handleError error model

        GotAudioFeatures result ->
            case result of
                Ok audioFeaturesList ->
                    let
                        topTracks =
                            map2 (\track audioFeatures -> { track | audioFeatures = Just <| normalizePercentage audioFeatures })
                                model.topTracks
                                audioFeaturesList.audioFeatures
                    in
                    ( { model | topTracks = topTracks }, Cmd.none )

                Err error ->
                    handleError error model

        TimeRangeSelected timeRange ->
            let
                cmd =
                    case model.authDetails of
                        Just authDetails ->
                            batch
                                [ getUsersTopArtists authDetails.accessToken timeRange
                                , getUsersTopTracks authDetails.accessToken timeRange
                                ]

                        Nothing ->
                            Cmd.none
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
                        Maybe.Just authDetails ->
                            if length searchQuery > 0 then
                                getTrackSearch authDetails.accessToken searchQuery

                            else
                                Cmd.none

                        Nothing ->
                            Cmd.none
            in
            ( { model | searchQuery = searchQuery, searchedTrack = Nothing }, cmd )

        SelectedSearchedTrack searchedTrack ->
            let
                cmd =
                    case model.authDetails of
                        Maybe.Just authDetails ->
                            getSearchedTrackAudioFeatures authDetails.accessToken searchedTrack

                        Nothing ->
                            Cmd.none
            in
            ( { model | searchedTrack = Just searchedTrack, searchTracks = [], searchQuery = searchedTrack.name }, cmd )

        GotSearchedTrackAudioFeatures result ->
            case result of
                Ok audioFeatures ->
                    let
                        updatedSearchedTrack =
                            case model.searchedTrack of
                                Just searchedTrack ->
                                    Just { searchedTrack | audioFeatures = Just (normalizePercentage audioFeatures) }

                                Nothing ->
                                    Nothing
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

        -- PKCE Authentication handlers
        InitiateLogin ->
            ( model, requestPkceChallenge () )

        ReceivedCodeChallenge codeChallenge ->
            let
                redirectUri =
                    spotifyRedirectUrl model.url

                authUrl =
                    spotifyAuthUrl redirectUri codeChallenge
            in
            ( model, load authUrl )

        ReceivedCodeVerifier codeVerifier ->
            case model.pendingAuthCode of
                Just code ->
                    let
                        redirectUri =
                            Url.toString (spotifyRedirectUrl model.url)
                    in
                    ( { model | pendingAuthCode = Nothing }
                    , exchangeCodeForToken code redirectUri codeVerifier
                    )

                Nothing ->
                    ( model, Cmd.none )

        GotTokenResponse result ->
            case result of
                Ok tokenResponse ->
                    ( { model | authDetails = Just { accessToken = tokenResponse.accessToken } }
                    , Cmd.batch
                        [ getProfile tokenResponse.accessToken
                        , getUsersTopArtists tokenResponse.accessToken ShortTerm
                        , getUsersTopTracks tokenResponse.accessToken ShortTerm
                        , pushUrl model.key "/"
                        ]
                    )

                Err _ ->
                    ( { model | authDetails = Nothing }, Cmd.none )

        ReceivedAuthError _ ->
            -- Handle auth error - clear auth details
            ( { model | authDetails = Nothing, pendingAuthCode = Nothing }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveCodeChallenge ReceivedCodeChallenge
        , receiveCodeVerifier ReceivedCodeVerifier
        , receiveAuthError ReceivedAuthError
        ]


handleError : Error -> Model -> ( Model, Cmd Msg )
handleError error model =
    case error of
        BadStatus 401 ->
            ( { model | authDetails = Nothing }, Cmd.none )

        _ ->
            ( model, Cmd.none )

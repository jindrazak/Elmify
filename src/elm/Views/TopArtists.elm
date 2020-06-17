module Views.TopArtists exposing (..)

import Html exposing (Html, div, h2, li, ol, p, section, span, text)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onMouseDown)
import List exposing (map)
import String exposing (join)
import Types exposing (Artist, ArtistsPagingObject, AudioFeatures, AudioFeaturesConfiguration, AuthDetails, Image, Model, Msg(..), Profile, TimeRange(..), Track)
import Views.Common exposing (profileImage, simpleBarView)


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


popularityView : Artist -> Html Msg
popularityView artist =
    simpleBarView "Popularity" (toFloat artist.popularity) "#ff1493"

module Types exposing (..)

import Browser
import Browser.Navigation as Nav
import Http
import Url


type alias AuthDetails =
    { accessToken : String }


type alias Docs =
    ( String, Maybe String )


type alias Profile =
    { name : String, images : List Image }


type alias Image =
    { width : Maybe Int, height : Maybe Int, url : String }


type alias ArtistsPagingObject =
    { artists : List Artist }


type alias TracksPagingObject =
    { tracks : List Track }



--Returned from https://api.spotify.com/v1/search


type alias SearchTracksPagingObject =
    { tracksPo : TracksPagingObject }


type alias Artist =
    { name : String
    , genres : List String
    , images : List Image
    , popularity : Int
    , expanded : Bool
    }



--https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-simplified


type alias SimplifiedArtist =
    { name : String }


type alias Track =
    { id : String
    , name : String
    , artists : List SimplifiedArtist
    , audioFeatures : Maybe AudioFeatures
    , expanded : Bool
    }


type alias AudioFeaturesList =
    { audioFeatures : List AudioFeatures
    }


type alias AudioFeaturesConfiguration =
    { name : String
    , accessor : AudioFeatures -> Float
    , color : String
    , description : String
    }


type alias AudioFeatures =
    { acousticness : Float
    , danceability : Float
    , energy : Float
    , instrumentalness : Float
    , liveness : Float
    , speechiness : Float
    , valence : Float
    , tempo : Float
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Maybe Docs
    , authDetails : Maybe AuthDetails
    , profile : Maybe Profile
    , topArtists : List Artist
    , timeRange : TimeRange
    , topTracks : List Track
    , searchTracks : List Track
    , searchQuery : String
    , searchedTrack : Maybe Track
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotProfile (Result Http.Error Profile)
    | GotTopArtists (Result Http.Error ArtistsPagingObject)
    | GotTopTracks (Result Http.Error TracksPagingObject)
    | GotSearchTracks (Result Http.Error SearchTracksPagingObject)
    | GotAudioFeatures (Result Http.Error AudioFeaturesList)
    | GotSearchedTrackAudioFeatures (Result Http.Error AudioFeatures)
    | TimeRangeSelected TimeRange
    | TrackExpanded Track
    | ArtistExpanded Artist
    | SearchInputChanged String
    | SelectedSearchedTrack Track
    | Logout


type TimeRange
    = ShortTerm
    | MediumTerm
    | LongTerm


type TopSubject
    = TopArtists
    | TopTracks


placeholderImage =
    Image (Just 128) (Just 128) "https://picsum.photos/128"

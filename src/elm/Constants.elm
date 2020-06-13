module Constants exposing (..)

import Types exposing (AudioFeaturesConfiguration)


audioFeaturesConfigurations : List AudioFeaturesConfiguration
audioFeaturesConfigurations =
    [ AudioFeaturesConfiguration "Acousticness" .acousticness "#ff1493"
    , AudioFeaturesConfiguration "Danceability" .danceability "#ff1493"
    , AudioFeaturesConfiguration "Energy" .energy "#ff1493"

    --, AudioFeaturesConfiguration "Liveness" .liveness "#ff1493"
    --, AudioFeaturesConfiguration "Loudness" .loudness "#ff1493"
    --, AudioFeaturesConfiguration "Speechiness" .speechiness "#ff1493"
    , AudioFeaturesConfiguration "Valence" .valence "#ff1493"
    , AudioFeaturesConfiguration "Tempo" .tempo "#ff1493"
    ]

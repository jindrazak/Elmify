module Constants exposing (..)

import Browser.Navigation as Nav
import Types exposing (AudioFeaturesConfiguration, Model, TimeRange(..))
import Url exposing (Url)


audioFeaturesConfigurations : List AudioFeaturesConfiguration
audioFeaturesConfigurations =
    [ AudioFeaturesConfiguration "Acousticness" .acousticness "#ff1493" "A confidence measure of whether the track is acoustic."
    , AudioFeaturesConfiguration "Danceability" .danceability "#ff1493" "How suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity."
    , AudioFeaturesConfiguration "Energy" .energy "#ff1493" "Represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy."
    , AudioFeaturesConfiguration "Valence" .valence "#ff1493" "Describes the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric)."
    , AudioFeaturesConfiguration "Tempo" .tempo "#ff1493" "The overall estimated tempo of a track"
    ]


defaultModel : Nav.Key -> Url -> Model
defaultModel key url =
    Model key url Nothing Nothing Nothing [] ShortTerm [] [] "" Nothing

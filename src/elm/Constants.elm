module Constants exposing (..)

import Browser.Navigation as Nav
import Types exposing (AudioFeaturesConfiguration, Model, TimeRange(..))
import Url exposing (Url)


audioFeaturesConfigurations : List AudioFeaturesConfiguration
audioFeaturesConfigurations =
    [ AudioFeaturesConfiguration "Acousticness" .acousticness "#111abd" "A confidence measure of whether the track is acoustic."
    , AudioFeaturesConfiguration "Danceability" .danceability "#eb0707" "How suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity."
    , AudioFeaturesConfiguration "Energy" .energy "#f2820a" "Represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy."
    , AudioFeaturesConfiguration "Valence" .valence "#f7e305" "Describes the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric)."
    , AudioFeaturesConfiguration "Tempo" .tempo "#17c217" "The overall estimated tempo of a track"
    ]


defaultModel : Nav.Key -> Url -> Model
defaultModel key url =
    Model key url Nothing Nothing Nothing [] ShortTerm [] [] "" Nothing

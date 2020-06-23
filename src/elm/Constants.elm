module Constants exposing (..)

import Browser.Navigation as Nav
import Color
import Types exposing (AudioFeaturesConfiguration, Model, TimeRange(..))
import Url exposing (Url)


audioFeaturesConfigurations : List AudioFeaturesConfiguration
audioFeaturesConfigurations =
    [ AudioFeaturesConfiguration "Acousticness" .acousticness (Color.rgb255 17 26 189) "A confidence measure of whether the track is acoustic."
    , AudioFeaturesConfiguration "Danceability" .danceability (Color.rgb255 235 7 7) "How suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity."
    , AudioFeaturesConfiguration "Energy" .energy (Color.rgb255 242 130 10) "Represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy."
    , AudioFeaturesConfiguration "Valence" .valence (Color.rgb255 247 227 5) "Describes the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric)."
    , AudioFeaturesConfiguration "Tempo" .tempo (Color.rgb255 23 194 23) "The overall estimated tempo of a track"
    ]


defaultModel : Nav.Key -> Url -> Model
defaultModel key url =
    Model key url Nothing Nothing Nothing [] ShortTerm [] [] "" Nothing

module View.RouteLive exposing (view)

import Dict exposing (Dict)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Material.Icon as Icon
import Material.Options as Options exposing (css)
import Material.Textfield as Textfield
import Material.Typography as Typography
import Material.List as Lists

import Model exposing (Model, currentTime, getReplayTime)
import Msg exposing (Msg(..))

import Decode

view : Model -> Html Msg
view model =
        grid []
            [ cell
                [ size All 12
                , Elevation.e2
                , Options.css "align-itmes" "center"
                , Options.cs "mdl-grid"
                ]
                [ Textfield.render Mdl [0] model.mdl
                    [ Textfield.label "Time"
                    , Textfield.floatingLabel
                    , Textfield.value (currentTime model.liveLog)
                    , Textfield.disabled
                    ]
                    []
                , Button.render Mdl [ 0 ] model.mdl
                    [ Button.ripple
                    , Button.accent
                    , Button.icon
                    , Options.onClick ReplayPause
                    -- , Options.onClick (NewUrl (Route.urlFor Route.Replay))
                    ]
                    [ Icon.i "pause" ]
                ]
            , cell
                [ size All 12
                , Elevation.e2
                , Options.css "align-itmes" "center"
                , Options.cs "mdl-grid"
                ]
                [ viewPt model
                ]
            ]

viewPt : Model -> Html Msg
viewPt model =
    case model.liveLog of
        Err msg ->
            grid [ Color.background <| Color.color Color.Grey Color.S900 ]
                [ textCell Color.Grey msg ]
        Ok pt  ->
            Lists.ul [] [logItem pt]

textCell : Color.Hue -> String -> Grid.Cell msg
textCell bgColor str =
    cell
        [ size All 12
        , Elevation.e2
        , Options.css "align-items" "center"
        , Options.cs "mdl-grid"
        , Color.background <| Color.color bgColor Color.S300
        ]
        [
            text str
        ]

logItem : Decode.PlainText -> Html msg
logItem pt =
    let
        msg = pt.timestamp ++ ": " ++ pt.log.text

        bgColor = Color.BlueGrey

        icon = "check_circle_outline"
    in
        Lists.li
            [ Lists.withBody
            , Color.background <| Color.color bgColor Color.S50
            ]
            [ Lists.content []
                [ Lists.avatarIcon icon [ Color.background <| Color.color bgColor Color.S300 ]
                , text msg
                ]
            ]

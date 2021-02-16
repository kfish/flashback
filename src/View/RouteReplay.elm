module View.RouteReplay exposing (view)

import Model exposing (Model, currentTime, getReplayPercent)
import Msg exposing (Msg(..))

import Dict exposing (Dict)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Material.Elevation as Elevation
import Material.Icon as Icon
import Material.Options as Options exposing (css)
import Material.Slider as Slider
import Material.Textfield as Textfield
import Material.Typography as Typography
import Material.List as Lists

import Model exposing (Model)
import Msg exposing (Msg(..))

import Decode
import Timestamp

view : Model -> Html Msg
view model =
    let nanos =
        case Timestamp.fromString model.replayTime of
            Ok n -> Timestamp.epochNanos n
            Err e -> e
        ppn =
        case Timestamp.fromString model.replayTime of
            Ok n -> Timestamp.toString n
            Err e -> e
    in
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
                    -- , Textfield.value (currentTime model.replayLog)
                    , Textfield.value model.replayTime
                    , Options.onInput ReplayTime
                    ]
                    []
                , Textfield.render Mdl [0] model.mdl
                    [ Textfield.label "Nanos"
                    , Textfield.floatingLabel
                    , Textfield.value nanos
                    , Textfield.disabled
                    ]
                    []
                , Textfield.render Mdl [0] model.mdl
                    [ Textfield.label "Parsed"
                    , Textfield.floatingLabel
                    , Textfield.value ppn
                    , Textfield.disabled
                    ]
                    []
                , Button.render Mdl [ 0 ] model.mdl
                    [ Button.ripple
                    , Button.primary
                    , Options.onClick ReplayGet
                    ]
                    [ text "Go" ]
                , Button.render Mdl [ 0 ] model.mdl
                    [ Button.ripple
                    , Button.accent
                    , Button.icon
                    , Options.onClick ReplayPrev
                    ]
                    [ Icon.i "skip_previous" ]
                , Button.render Mdl [ 0 ] model.mdl
                    [ Button.ripple
                    , Button.accent
                    , Button.icon
                    , Options.onClick ReplayNext
                    ]
                    [ Icon.i "skip_next" ]
                ]
            , cell
                [ size All 12
                ]
                [ Slider.view
                    [ Slider.min 0
                    , Slider.max 100
                    , Slider.value (getReplayPercent model)
                    , Slider.step 1
                    , Slider.onChange ReplayPercent
                    ]
                ]
            , cell
                [ size All 12
                , Elevation.e2
                , Options.css "align-itmes" "center"
                , Options.cs "mdl-grid"
                ]
                [ ptView model
                ]
            ]

ptView : Model -> Html Msg
ptView model =
    case model.replayLog of
        Err msg ->
            grid [ Color.background <| Color.color Color.Grey Color.S900 ]
                [ textCell Color.Grey msg ]
        Ok pt  ->
            Lists.ul [] [statusItem pt]

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

statusItem : Decode.PlainText -> Html msg
statusItem pt =
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

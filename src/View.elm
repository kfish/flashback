module View exposing (view)

import Html exposing (Html, text, div, span, form)
import Html.Attributes exposing (href, src)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Material.Icon as Icon
import Material.Color as Color
import Material.Menu as Menu
import Material.Dialog as Dialog
import Material.Button as Button
import Material.Options as Options exposing (css, cs, when)
import Material.Tabs as Tabs
import Material.Tooltip as Tooltip
import Material.Typography as Typography
import Route exposing (Route(..))
import View.RouteLive
import View.RouteReplay
import Charts
import Material.Scheme


view : Model -> Html Msg
view model =
    Material.Scheme.top <|
        Layout.render Mdl
                model.mdl
                [ Layout.fixedHeader
                , Layout.fixedDrawer
                , Layout.onSelectTab SelectTab
                , Options.css "display" "flex !important"
                , Options.css "flex-direction" "row"
                , Options.css "align-items" "center"
                ]
                { header = [ viewHeader model ]
                , drawer = []
                , tabs = ( List.map Html.text Route.routeNames, [] )
                , main =
                    [ viewBody model
                    , Snackbar.view model.snackbar |> Html.map Snackbar
                    ]
                }


viewHeader : Model -> Html Msg
viewHeader model =
    let
        clock = case model.logReceivedDate of
            Nothing -> "Connecting ..."
            Just d -> toString d
                |> String.dropLeft 1 |> String.dropRight 1 -- remove angle brackets
    in
        Layout.row
            [ Color.background <| Color.color Color.Grey Color.S100
            , Color.text <| Color.color Color.Grey Color.S900
            , css "padding-left" "4px"
            ]
            [ Layout.title []
                [ Options.styled Html.img
                    [ Options.attribute <| src "images/the-flash-sign.png"
                    , css "width" "64px"
                    , css "height" "64px"
                    , css "border-radius" "64px"
                    ] []
                ]
            , Layout.title
                [ css "padding-left" "12"
                , css "margin" "8px"
                ]
                [ text "Flashback" ]
            , Layout.spacer
            , Layout.spacer
            , Layout.navigation
                [ css "margin" "8px"
                , Color.text <| Color.color Color.Grey Color.S600
                , Typography.body2
                ]
                [ text clock ]
            , Layout.title []
                [ Options.styled Html.img
                    [ Options.attribute <| src "images/GitHub-Mark-Light-64px.png"
                    , Options.onClick (ViewSourceClick "https://github.com/lhftio/flashback")
                    , Tooltip.attach Mdl [0]
                    , css "width" "64px"
                    , css "height" "64px"
                    ] []
                , Tooltip.render Mdl [0] model.mdl
                    []
                    [ text "View source, report issues with flashback on GitHub" ]
                ]
            ]

type alias MenuItem =
    { text : String
    , iconName : String
    , route : Maybe Route
    }

menuItems : List MenuItem
menuItems =
    [ { text = "LIVE", iconName = "play_circle_outline", route = Just Live }
    , { text = "Replay", iconName = "replay", route = Just Replay }
    ]


viewDrawerMenuItem : Model -> MenuItem -> Html Msg
viewDrawerMenuItem model menuItem =
    let
        isCurrentLocation =
            case model.history of
                currentLocation :: _ ->
                    currentLocation == menuItem.route

                _ ->
                    False

        onClickCmd =
            case ( isCurrentLocation, menuItem.route ) of
                ( False, Just route ) ->
                    route |> Route.urlFor |> NewUrl |> Options.onClick

                _ ->
                    Options.nop
    in
        Layout.link
            [ onClickCmd
            , when isCurrentLocation (Color.background <| Color.color Color.BlueGrey Color.S600)
            , Options.css "color" "rgba(255, 255, 255, 0.56)"
            , Options.css "font-weight" "500"
            ]
            [ Icon.view menuItem.iconName
                [ Color.text <| Color.color Color.BlueGrey Color.S500
                , Options.css "margin-right" "32px"
                ]
            , text menuItem.text
            ]


viewDrawer : Model -> Html Msg
viewDrawer model =
    Layout.navigation
        [ Color.background <| Color.color Color.BlueGrey Color.S800
        , Color.text <| Color.color Color.BlueGrey Color.S50
        , Options.css "flex-grow" "1"
        ]
    <|
        (List.map (viewDrawerMenuItem model) menuItems)
            ++ [ Layout.spacer
               , Layout.link
                    [ Dialog.openOn "click"
                    ]
                    [ Icon.view "help"
                        [ Color.text <| Color.color Color.BlueGrey Color.S500
                        ]
                    ]
               ]

viewBody : Model -> Html Msg
viewBody model =
    case model.history |> List.head |> Maybe.withDefault Nothing of
        Just (Route.Live) ->
            View.RouteLive.view model

        Just (Route.Replay) ->
            View.RouteReplay.view model

        Nothing ->
            text "404"

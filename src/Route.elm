module Route exposing (..)

import Navigation
import UrlParser exposing (parsePath, oneOf, map, top, s, (</>), string)


type Route
    = Live
    | Replay

type alias Model =
    Maybe Route

routes : List Route
routes = [ Live, Replay ]

routeNames : List String
routeNames = [ "LIVE", "Replay" ]

pathParser : UrlParser.Parser (Route -> a) a
pathParser =
    oneOf
        [ map Live top
        , map Replay (s "replay")
        ]

init : Maybe Route -> List (Maybe Route)
init location =
    case location of
        Nothing ->
            [ Just Live ]

        something ->
            [ something ]

urlFor : Route -> String
urlFor loc =
    case loc of
        Live ->
            "/"

        Replay ->
            "/replay"

locFor : Navigation.Location -> Maybe Route
locFor path =
    parsePath pathParser path

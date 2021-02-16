module Model exposing (Model, init, initialModel, currentTime, getReplayTime, getReplayPercent, fromReplayPercent)

import Dict exposing (Dict)
import Date exposing (..)
import Http
import WebSocket

import Material
import Material.Snackbar as Snackbar

import Decode
import Msg exposing (Msg(Mdl))
import Route exposing (Route)
import Types exposing (User)
import Navigation
import Timestamp exposing (Timestamp)

type alias Model =
    { mdl : Material.Model
    , snackbar : Snackbar.Model (Maybe Msg)
    , history : List (Maybe Route)
    , toggles : Dict (List Int) Bool
    , streamURL : String
    , archiveURL : String
    , liveLog : Result String Decode.PlainText
    , replayLog : Result String Decode.PlainText
    , replayTime : String
    , minTime : Maybe Timestamp
    , maxTime : Maybe Timestamp
    , logReceivedDate : Maybe Date
    , topic : String
    }


initialModel : Navigation.Location -> Model
initialModel location =
    { mdl = Material.model
    , snackbar = Snackbar.model
    , history = Route.init (Route.locFor location)
    , toggles = Dict.empty
    , streamURL = "ws://" ++ location.host ++ "/ws"
    , archiveURL = "http://" ++ location.host ++ "/"
    , liveLog = Err "Loading ..."
    , replayLog = Err "Loading ..."
    , replayTime = ""
    , minTime = Nothing
    , maxTime = Nothing
    , logReceivedDate = Nothing
    , topic = "fortune100-2.slip"
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let model = initialModel location
    in model !
        [ Material.init Mdl
        , WebSocket.send model.streamURL "HELO"
        ]

currentTime : Result String Decode.PlainText -> String
currentTime result =
    case result of
        Ok pt -> pt.timestamp
        Err _ -> "foo"

getReplayTime : Model -> String -> Http.Request Decode.PlainText
getReplayTime model t =
    Http.get (model.archiveURL ++ model.topic ++ "?t=" ++ t) Decode.plainText

getReplayPercent : Model -> Float
getReplayPercent model =
    case (model.minTime, model.maxTime, Timestamp.fromString model.replayTime) of
        (Just ts1, Just ts2, Ok rt) ->
            let
                duration = Timestamp.diffNanos ts1 ts2
                offset = Timestamp.diffNanos ts1 rt
            in (toFloat offset * 100.0) / toFloat duration
        _ -> 0.0

fromReplayPercent : Model -> Float -> String
fromReplayPercent model percent =
    case (model.minTime, model.maxTime) of
        (Just ts1, Just ts2) ->
            let
                duration = Timestamp.diffNanos ts1 ts2
                ts = Timestamp.addNanos (floor (percent * toFloat duration / 100.0)) ts1
            in
                Timestamp.toString ts
        _ -> ""

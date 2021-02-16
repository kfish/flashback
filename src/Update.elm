module Update exposing (update)

import Array
import Date
import Dict
import List
import Material
import Material.Snackbar as Snackbar
import Maybe.Extra as Maybe
import Navigation
import Task

import Model exposing (Model, currentTime, getReplayTime, fromReplayPercent)
import Msg exposing (Msg(..))
import Types exposing (User)
import Route exposing (Route)
import Ports
import Timestamp

import Http
import Json.Decode exposing (..)
import Decode

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        SelectTab n ->
            let routes = Array.fromList Route.routes
                route = Maybe.withDefault Route.Live (Array.get n routes)
            in
            model ! [ Navigation.newUrl (Route.urlFor route) ]

        Snackbar msg_ ->
            let
                ( snackbar, snackCmd ) =
                    Snackbar.update msg_ model.snackbar
            in
                { model | snackbar = snackbar } ! [ Cmd.map Snackbar snackCmd ]

        NavigateTo location ->
            location
                |> Route.locFor
                |> urlUpdate model

        NewMessage str ->
            let
                newLog = decodeString Decode.plainText str
                newMinTime =
                    case (model.minTime, newLog) of
                        (Nothing, Ok pt) ->
                            case Timestamp.fromString pt.timestamp of
                                Ok ts -> Just ts
                                Err _ -> model.minTime
                        _ -> model.minTime

                newMaxTime =
                    case newLog of
                        Ok pt ->
                            case Timestamp.fromString pt.timestamp of
                                Ok ts -> Just ts
                                Err _ -> model.maxTime
                        Err _ -> model.maxTime

                newModel = { model | liveLog = newLog
                                   , minTime = newMinTime
                                   , maxTime = newMaxTime
                           }
            in
                newModel !
                    [ Task.perform LogReceived Date.now
                    , Ports.title (titleUpdate newLog)
                    ]

        NewUrl url ->
            model ! [ Navigation.newUrl url ]

        Toggle index ->
            let
                toggles =
                    case (Dict.get index model.toggles) of
                        Just v ->
                            Dict.insert index (not v) model.toggles

                        Nothing ->
                            Dict.insert index True model.toggles
            in
                { model | toggles = toggles } ! []

        ViewSourceClick url ->
            model ! [ Ports.windowOpen url ]

        LogReceived date ->
            { model | logReceivedDate = Just date } ! []

        ReplayLoaded (Ok log) ->
            { model | replayLog = Ok log } ! []

        ReplayLoaded (Err e) ->
            { model | replayLog = Err ("HTTP Error"  ++ toString e)} ! []

        ReplayPause ->
            let newTime = currentTime model.liveLog
            in
                { model | replayTime = newTime } !
                [ getReplayTime model newTime |> Http.send Msg.ReplayLoaded
                , Navigation.newUrl (Route.urlFor Route.Replay) ]

        ReplayGet ->
            model !
            [ getReplayTime model model.replayTime |> Http.send Msg.ReplayLoaded ]

        ReplayTime str ->
            { model | replayTime = str } ! -- []
            [ getReplayTime model model.replayTime |> Http.send Msg.ReplayLoaded ]

        ReplayPrev ->
            case Timestamp.fromString model.replayTime of
                Ok n ->
                    let
                        t = Timestamp.toString (Timestamp.addNanos (-100000000) n)
                    in
                        { model | replayTime = t } !
                        [ getReplayTime model t |> Http.send Msg.ReplayLoaded ]
                Err e -> model ! []

        ReplayNext ->
            case Timestamp.fromString model.replayTime of
                Ok n ->
                    let
                        t = Timestamp.toString (Timestamp.addNanos (100000000) n)
                    in
                        { model | replayTime = t } !
                        [ getReplayTime model t |> Http.send Msg.ReplayLoaded ]
                Err e -> model ! []

        ReplayPercent f ->
            let
                t = fromReplayPercent model f
            in
                if t == "" then
                    model ! []
                else
                    { model | replayTime = t } !
                    [ getReplayTime model t |> Http.send Msg.ReplayLoaded ]

urlUpdate : Model -> Maybe Route -> ( Model, Cmd Msg )
urlUpdate model route =
    { model | history = route :: model.history } ! []

titleUpdate : Result String Decode.PlainText -> String
titleUpdate result =
    case result of
        Ok _ ->
                "Flashback ⚡"
        Err e ->
            "! " ++ e ++ " | Flashback ⚡"

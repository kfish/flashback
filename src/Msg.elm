module Msg exposing (Msg(..))

import Date exposing (Date)
import Http
import Material
import Material.Snackbar as Snackbar
import Navigation
import Types exposing (User)

import Decode

type Msg
    = Mdl (Material.Msg Msg)
    | SelectTab Int
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | NavigateTo Navigation.Location
    | NewMessage String
    | NewUrl String
    | Toggle (List Int)
    | ViewSourceClick String
    | LogReceived Date
    | ReplayPause
    | ReplayTime String
    | ReplayGet
    | ReplayPrev
    | ReplayNext
    | ReplayPercent Float
    | ReplayLoaded (Result Http.Error Decode.PlainText)

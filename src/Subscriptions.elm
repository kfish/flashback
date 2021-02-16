module Subscriptions exposing (subscriptions)

import Material
import WebSocket

import Model exposing (Model)
import Msg exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Material.subscriptions Mdl model
        , WebSocket.listen model.streamURL NewMessage
        ]

module Decode exposing (..)

import Dict exposing (Dict)
import Json.Decode exposing (..)

type alias PlainText =
    { timestamp : String
    , log : TextRecord
    }

type alias TextRecord =
    { text : String
    }

plainText : Decoder PlainText
plainText =
    map2 PlainText
      (field "timestamp" string)
      (field "log" textRecord)

textRecord : Decoder TextRecord
textRecord =
    map TextRecord
        (field "text" string)

module Timestamp exposing (Timestamp, fromString, toString, epochNanos, addNanos, diffNanos)

import Date
import Date.Extra.Config.Config_en_au exposing (config)
import Date.Extra.Format as Format exposing (format, formatUtc, isoMsecFormat)
import Time

type alias Timestamp =
    { seconds : Int
    , nanos : Int
    }

addNanos : Int -> Timestamp -> Timestamp
addNanos ns ts =
    if ns > 0 then
        Timestamp (ts.seconds + ns // 1000000000) (ts.nanos + ns % 1000000000)
    else if ns < 0 then
        let p = negate ns
            p_s = p // 1000000000
            p_ns = p % 1000000000
        in
            if p_ns < ts.nanos then
                Timestamp (ts.seconds - p_s) (ts.nanos - p_ns)
            else
                Timestamp (ts.seconds - p_s - 1) (1000000000 + ts.nanos - p_ns)
    else
        ts

-- | diffNanos ts1 ts2 = ts2 - ts1
diffNanos : Timestamp -> Timestamp -> Int
diffNanos ts1 ts2 =
    ((ts2.seconds - ts1.seconds) * 1000000000) + ts2.nanos - ts1.nanos

fromString : String -> Result String Timestamp
fromString s =
    case Date.fromString s of
        Ok d ->
            let
                t = Date.toTime d
                ms = floor (Time.inMilliseconds t) % 1000
                ss = floor (Time.inSeconds t)

                ns = String.toInt (String.dropLeft 23 s)
                     |> Result.withDefault 0
            in
                Ok (Timestamp ss (ns + ms * 1000000))
        Err e -> Err e

toString : Timestamp -> String
toString ts =
    let
        d = Date.fromTime ((toFloat ts.seconds * 1000.0) + (toFloat ts.nanos / 1000000.0))
        ns = String.dropLeft 1 (Basics.toString (1000000 + (ts.nanos % 1000000)))
    in
        format config isoMsecFormat d ++ ns

epochNanos : Timestamp -> String
epochNanos ts = Basics.toString ts.seconds ++ "." ++ Basics.toString ts.nanos


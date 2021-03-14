module Keys exposing (..)

import Json.Decode as Decode



-- import Types exposing (..)
-- Тут из аппаратных кнопок пока только три.
-- Еще сюда должно транслироваться открытие дверцы ShowVending (сейчас это делается кнопкой)
-- Еще где-то стоит добавить диагностическую кнопку DebugClick


type KeyCmd
    = KeyLeft
    | KeyRight
    | KeyOk
    | DebugClick
    | ShowVending
    | ShowCalibration
    | Undefined



-- | CharacterPressed Char
-- | KeyLeft
-- | KeyRight
-- | KeyOk


toKey : String -> KeyCmd
toKey string =
    case string of
        "ArrowRight" ->
            toKey "d"

        "ArrowLeft" ->
            toKey "a"

        "ArrowDown" ->
            toKey "s"

        "Enter" ->
            toKey "s"

        "A" ->
            toKey "a"

        "D" ->
            toKey "d"

        "ф" ->
            toKey "a"

        "в" ->
            toKey "d"

        "Ф" ->
            toKey "a"

        "В" ->
            toKey "d"

        "V" ->
            toKey "v"

        "м" ->
            toKey "v"

        "р" ->
            toKey "h"

        "H" ->
            toKey "h"

        "Р" ->
            toKey "h"

        "ё" ->
            toKey "`"

        "Ё" ->
            toKey "`"

        _ ->
            case String.uncons string of
                Just ( char, "" ) ->
                    charToKey char

                _ ->
                    Undefined


charToKey : Char -> KeyCmd
charToKey ch =
    case ch of
        'd' ->
            KeyRight

        'a' ->
            KeyLeft

        's' ->
            KeyOk

        ' ' ->
            KeyOk

        '`' ->
            DebugClick

        'v' ->
            ShowVending

        'h' ->
            ShowCalibration

        _ ->
            Undefined


keyDecoder : Decode.Decoder KeyCmd
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)

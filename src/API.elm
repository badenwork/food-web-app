module API exposing (..)

import Json.Encode as Encode
import Json.Decode as JD exposing (Decoder, Value, string, value)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Http


type APIContent
    = Key KeyInfo
    | Error String


type KeyInfo
    = Key1
    | Key2
    | Key3
    | KeyUnknown


type PayMethod
    = PayMethod1
    | PayMethod2
    | PayMethod3


parsePayload : String -> Maybe APIContent
parsePayload payload =
    case JD.decodeString payloadDecoder payload of
        Ok content ->
            Just content

        Err error ->
            Nothing


payloadDecoder : JD.Decoder APIContent
payloadDecoder =
    (JD.field "cmd" JD.string)
        |> JD.andThen
            (\t ->
                JD.field "data" <|
                    case t of
                        "key" ->
                            JD.map Key keyDecoder

                        _ ->
                            JD.fail ("unexpected message " ++ t)
            )


keyDecoder : JD.Decoder KeyInfo
keyDecoder =
    JD.int
        |> JD.andThen
            (\t ->
                case t of
                    1 ->
                        JD.succeed Key1

                    2 ->
                        JD.succeed Key2

                    3 ->
                        JD.succeed Key3

                    other ->
                        JD.succeed KeyUnknown
            )


acao =
    Http.header "Access-Control-Allow-Origin" "*"

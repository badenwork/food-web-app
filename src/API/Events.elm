module API.Events exposing (..)

import API
import API.Products exposing (FakeProduct, encodeProduct)
import API.Vending exposing (Vending, encodeVending)
import Http
import Json.Encode as Encode


url : String -> String
url ev =
    API.url ++ "/events/" ++ ev


type Event
    = EventInit Vending
    | EventConfirm EventConfirm_
    | EventCooking FakeProduct


type ProcessEvent
    = EventWaitPay API.PayMethod
    | EventTakeOut Int


encodeEvent : Event -> Encode.Value
encodeEvent e =
    let
        ( etype, edoc ) =
            case e of
                EventInit v ->
                    ( "init", encodeVending v )

                EventConfirm p ->
                    ( "confirm", encodeConfirm p )

                EventCooking p ->
                    ( "cooking", encodeProduct p )
    in
    Encode.object
        [ ( "etype", Encode.string etype )
        , ( "doc", edoc )
        ]


encodeProcessEvent : ProcessEvent -> Encode.Value
encodeProcessEvent e =
    let
        ( etype, edoc ) =
            case e of
                EventWaitPay payMethod ->
                    ( "waitPay", API.encodePayMethod payMethod )

                EventTakeOut position ->
                    ( "takeout", Encode.int position )
    in
    Encode.object
        [ ( "etype", Encode.string etype )
        , ( "doc", edoc )
        ]


type alias EventConfirm_ =
    { product : FakeProduct
    , payMethod : API.PayMethod
    , price : String
    }


encodeConfirm : EventConfirm_ -> Encode.Value
encodeConfirm ec =
    Encode.object
        [ ( "product", ec.product |> encodeProduct )
        , ( "payMethod", ec.payMethod |> API.encodePayMethod )
        ]


send : Event -> (Result Http.Error () -> msg) -> Cmd msg
send event msg =
    Http.request
        { method = "POST"
        , headers = [ API.acao ]
        , url = url "confirm"
        , body = encodeEvent event |> Http.jsonBody
        , expect = Http.expectWhatever msg
        , timeout = Nothing
        , tracker = Nothing
        }


process : ProcessEvent -> (Result Http.Error () -> msg) -> Cmd msg
process event msg =
    Http.request
        { method = "POST"
        , headers = [ API.acao ]
        , url = url "process"
        , body = encodeProcessEvent event |> Http.jsonBody
        , expect = Http.expectWhatever msg
        , timeout = Nothing
        , tracker = Nothing
        }

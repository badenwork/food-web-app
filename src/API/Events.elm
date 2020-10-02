module API.Events exposing (..)

import Json.Encode as Encode
import API
import API.Products exposing (ProductId)


url : String -> String
url ev =
    "http://localhost:8081/events/" ++ ev


type alias Confirm =
    { product : ProductId
    , payMethod : API.PayMethod
    }


encodeConfirm : Confirm -> Encode.Value
encodeConfirm ec =
    Encode.object
        [ ( "product", ec.product |> Encode.string )
        , ( "payMethod", ec.payMethod |> API.encodePayMethod )
        ]

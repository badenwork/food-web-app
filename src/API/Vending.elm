module API.Vending exposing (..)

import API
import API.Products exposing (ProductId, decodeProductId, encodeProductId)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode


type alias Vending =
    { id : VendingId
    , title : String
    , logo : String
    , header : String
    , footer1 : String
    , footer2 : String
    , products : List ProductId

    -- , info : VendingInfo
    }


type alias VendingId =
    String


url : String
url =
    API.url ++ "/db/vending"


decodeVendingId : Decode.Decoder VendingId
decodeVendingId =
    Decode.string


encodeVendingId : VendingId -> Encode.Value
encodeVendingId =
    Encode.string


decodeVending : Decode.Decoder Vending
decodeVending =
    Decode.succeed Vending
        |> required "id" decodeVendingId
        |> required "title" Decode.string
        |> required "logo" Decode.string
        |> required "header" Decode.string
        |> required "footer1" Decode.string
        |> required "footer2" Decode.string
        |> required "products" (Decode.list decodeProductId)


encodeVending : Vending -> Encode.Value
encodeVending p =
    Encode.object
        [ ( "id", encodeVendingId p.id )
        , ( "title", Encode.string p.title )
        , ( "logo", Encode.string p.logo )
        , ( "header", Encode.string p.header )
        , ( "footer1", Encode.string p.footer1 )
        , ( "footer2", Encode.string p.footer2 )
        , ( "products", Encode.list encodeProductId p.products )
        ]

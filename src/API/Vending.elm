module API.Vending exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import API.Products exposing (ProductId, decoderProductId)


type alias Vending =
    { id : VendingId
    , title : String
    , logo : String
    , header : String
    , footer : List String
    , products : List ProductId

    -- , info : VendingInfo
    }


type alias VendingId =
    String


url =
    "http://localhost:8081/db/vending"


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
        |> required "header1" Decode.string
        |> required "footer" (Decode.list Decode.string)
        |> required "products" (Decode.list decoderProductId)

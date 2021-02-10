module API.Vending exposing (..)

import API
import API.Products exposing (ProductId, decodeProductId, encodeProductId)
import Json.Decode as Decode exposing (field)
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
    , hwType : VendingHWType

    -- , info : VendingInfo
    }


type VendingHWType
    = VHWT_Array Int Int


encodeVendingHWType : VendingHWType -> Encode.Value
encodeVendingHWType (VHWT_Array rows cols) =
    Encode.object
        [ ( "type", Encode.string "array" )
        , ( "rows", Encode.int rows )
        , ( "cols", Encode.int cols )
        ]


decodeVendingHWType : Decode.Decoder VendingHWType
decodeVendingHWType =
    field "type" Decode.string
        |> Decode.andThen decodeVendingHWType1


decodeVendingHWType1 : String -> Decode.Decoder VendingHWType
decodeVendingHWType1 type_ =
    case type_ of
        "array" ->
            Decode.map2 (\rows cols -> VHWT_Array rows cols)
                (Decode.field "rows" Decode.int)
                (Decode.field "cols" Decode.int)

        -- field "rows" Decode.int
        --     |> Decode.andThen
        --         (\rows ->
        --             field "cols" Decode.int
        --                 |> Decode.andThen
        --                     (\cols ->
        --                         Decode.succeed (VHWT_Array rows cols)
        --                     )
        --         )
        _ ->
            Decode.fail "Only array is supported now"



-- Decode.succeed
-- VendingHWType


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
        -- Decode.oneOf [Decode.succeed (VHWT_Array 8 8)]
        -- |> required "hwtype" decodeVendingHWType
        |> optional "hwtype" decodeVendingHWType (VHWT_Array 6 7)


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

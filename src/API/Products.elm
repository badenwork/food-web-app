module API.Products exposing (..)

import API
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Url


type alias ProductId =
    String


decodeProductId : Decode.Decoder ProductId
decodeProductId =
    Decode.string


encodeProductId : ProductId -> Encode.Value
encodeProductId pid =
    Encode.string pid


type alias FakeProduct =
    { id : ProductId
    , titleUA : String
    , titleEN : String
    , image : String
    , descriptionUA : String
    , descriptionEN : String
    , price : String
    }


unknowFakeProduct : FakeProduct
unknowFakeProduct =
    FakeProduct "product_fake" "Нiчого ще нема!" "Nothing here!" "img/no_product.png" "Ошибка загрузки данных о продукте." "Error loading description." "10000"


decodeProduct : Decode.Decoder FakeProduct
decodeProduct =
    Decode.succeed FakeProduct
        |> required "id" decodeProductId
        |> required "titleUA" Decode.string
        |> required "titleEN" Decode.string
        |> required "image" Decode.string
        |> required "descriptionUA" Decode.string
        |> required "descriptionEN" Decode.string
        |> optional "price" Decode.string "30"


encodeProduct : FakeProduct -> Encode.Value
encodeProduct p =
    Encode.object
        [ ( "id", encodeProductId p.id )
        , ( "titleUA", Encode.string p.titleUA )
        , ( "titleEN", Encode.string p.titleEN )
        , ( "image", Encode.string p.image )
        , ( "descriptionUA", Encode.string p.descriptionUA )
        , ( "descriptionEN", Encode.string p.descriptionEN )
        , ( "price", Encode.string p.price )
        ]


url : ProductId -> String
url pid =
    API.url ++ "/db/product/" ++ Url.percentEncode pid

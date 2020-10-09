module API.Products exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional)
import Url
import API


type alias ProductId =
    String


decodeProductId : Decode.Decoder ProductId
decodeProductId =
    Decode.string


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
    FakeProduct "product_fake" "От халепа!" "Oops!" "img/ovsanka.png" "Ошибка загрузки данных о продукте." "Error loading description." "10000"


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


url : ProductId -> String
url pid =
    API.url ++ "/db/product/" ++ (Url.percentEncode pid)

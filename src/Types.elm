module Types exposing (..)

import API
import API.Products exposing (..)
import API.Vending exposing (Vending)
import Dict exposing (Dict)
import Time
import Json.Decode as Decode
import Http


type alias Model =
    { vending : Maybe Vending
    , id : String
    , activeProduct : Int
    , connectionState : ConnectionState
    , activePage : Page
    , activePayMethod : API.PayMethod
    , cookTimer : Int
    , images : Dict String String
    , error : Maybe (List String)
    }


type Msg
    = NoOp
    | CharacterPressed Char
    | WebsocketIn String
    | OpenWebsocket String
    | WebsocketOpened Bool
    | KeyLeft
    | KeyRight
    | KeyOk
    | Tick Time.Posix
    | SelectPayMethod API.PayMethod
    | ReadFileDone (Result Decode.Error ReadFile)
    | ReadVendingDone (Response API.Vending.Vending)
    | ReadProductDone (Response API.Products.FakeProduct)
    | EventConfirmDone (Response ())


type Page
    = Products
    | Order
    | OrderIngenica
    | OrderPrivat
    | OrderFondi
    | OrderConfirm
    | CookAsk1
    | CookAsk2
    | Cooking
    | CookingDone


type ConnectionState
    = NotConnected
    | Connected


type alias ReadFile =
    { name : String
    , data : String
    }


type alias Response a =
    Result Http.Error a

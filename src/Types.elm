module Types exposing (..)

import API
import API.Products exposing (..)
import API.Vending exposing (Vending)
import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Time


type alias Flags =
    { hostname : String
    , name : String
    }


type alias Model =
    { vending : Maybe Vending
    , flags : Flags
    , id : String
    , activeProduct : Int
    , connectionState : ConnectionState
    , activePage : Page
    , activePayMethod : API.PayMethod
    , cookTimer : Int
    , images : Dict String String
    , error : Maybe (List String)
    , products : Dict ProductId FakeProduct
    , debugEvents : List String
    , showDebugEvents : Bool
    , vendingState : VendingPageState
    }


type VendingPageState
    = VPS_SelectRow Int
    | VPS_SelectCol Int Int


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
    | EventProcessDone (Response ())
    | DebugClick
    | DebugMessage String
    | ShowVending


type Page
    = Products
    | Order
    | OrderIngenica
    | OrderPrivat
    | OrderFondi
    | TakingOut
    | OrderConfirm
    | CookAsk1
    | CookAsk2
    | Cooking
    | CookingDone
    | VendingConfig


type ConnectionState
    = NotConnected
    | Connected


type alias ReadFile =
    { name : String
    , data : String
    }


type alias Response a =
    Result Http.Error a

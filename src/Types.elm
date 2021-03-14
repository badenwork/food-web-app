module Types exposing (..)

import API
import API.Loads exposing (Loads)
import API.Products exposing (..)
import API.Vending exposing (Vending)
import Array2D exposing (Array2D)
import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Keys
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

    -- , products_a : Array2D ProductId
    -- , product_array : Dict ( Int, Int ) ProductId
    , product_array : Loads
    , debugEvents : List String
    , showDebugEvents : Bool

    -- , vendingState : VendingPageState
    }


type Msg
    = NoOp
    | WebsocketIn String
    | OpenWebsocket String
    | WebsocketOpened Bool
    | Tick Time.Posix
    | SelectPayMethod API.PayMethod
    | ReadFileDone (Result Decode.Error ReadFile)
    | ReadVendingDone (Response API.Vending.Vending)
    | ReadProductDone (Response API.Products.FakeProduct)
    | EventConfirmDone (Response ())
    | EventProcessDone (Response ())
    | DebugMessage String
    | KeyPress Keys.KeyCmd


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
    | VendingConfig VendingPageState
    | Calibration CalibrationPageState


type ConnectionState
    = NotConnected
    | Connected


type alias ReadFile =
    { name : String
    , data : String
    }


type alias Response a =
    Result Http.Error a


type VendingPageState
    = VPS_SelectRow Int Int
    | VPS_SelectCol Int Int
    | VPS_SetProduct Int Int Int
    | VPS_SetCount Int Int Int Int


type CalibrationPageState
    = CPS_SelectParam API.Vending.VHWT_Array_Config Int
    | CPS_EditParam API.Vending.VHWT_Array_Config Int Int

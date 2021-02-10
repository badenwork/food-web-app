module API.Loads exposing (..)

-- Состояние загрузки аппарата продуктом

import API.Products exposing (ProductId)
import Dict exposing (Dict)


type alias Load =
    { pid : ProductId
    , count : Int
    }


type alias Loads =
    Dict ( Int, Int ) Load

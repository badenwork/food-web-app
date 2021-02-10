module API.Loads exposing (..)

-- Состояние загрузки аппарата продуктом

import API.Products exposing (ProductId)
import Dict exposing (Dict)


type alias Loads =
    Dict ( Int, Int ) ProductId

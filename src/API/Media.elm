module API.Media exposing (..)

import API
import Url


imgUrl : String -> String
imgUrl filename =
    API.url ++ "/img/" ++ (Url.percentEncode filename)

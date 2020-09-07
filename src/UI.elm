module UI exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt)


header : Html msg
header =
    div []
        [ div [ class "header1" ] [ img [ src "img/logo.png", alt "INFINITY FOODS" ] [] ]
        , div [ class "header2" ] [ text "Для питань та пропозицій: infinitifoods.com.ua  +38 063 351 49 56  infinityfoodsua@gmail.com" ]
        ]


footer : Html msg
footer =
    div []
        [ div [ class "footer11" ] [ text "#Супомат" ]
        , div [ class "footer12" ] [ text "@infinityfoods" ]
        ]

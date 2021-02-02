module Page.TakingOut exposing (..)

-- import UI.KeyHelper exposing (key_left, key_ok)

import API
import API.Media exposing (imgUrl)
import API.Products exposing (FakeProduct)
import Html exposing (Html, div, img, p, span, text)
import Html.Attributes exposing (alt, class, src)
import Html.Events exposing (onClick)


view : FakeProduct -> List (Html msg)
view p =
    [ div [ class "cook_frame" ]
        [ img [ class "vending", src "img/cook/vending.png" ] []

        -- , img [ class "arrow", src "img/cook/arrow.png" ] []
        , img [ class "product", src <| imgUrl p.image ] []
        , div [ class "ua" ] [ text "Триваэ видача продукту, зачекайте..." ]
        , div [ class "en" ] [ text "Wait...." ]

        -- , key_left "key_1" "Відміна " "Cancel cooking" k1
        -- , key_ok "key_2" "Помістив!" "Placed!" k2
        ]
    ]

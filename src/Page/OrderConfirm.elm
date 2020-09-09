module Page.OrderConfirm exposing (..)

import Html exposing (Html, div, text, img, span, p)
import Html.Attributes exposing (class, src, alt)
import Html.Events exposing (onClick)
import API
import UI.KeyHelper exposing (key_left, key_ok)


view : ( msg, msg ) -> List (Html msg)
view ( k1, k2 ) =
    [ div [ class "confirm_panel1" ]
        [ div [ class "ua" ] [ p [] [ text "Оплата здійснена!" ], p [] [ text "Заберіть продукт з відсіку видачі." ] ]
        , div [ class "en gray3" ] [ p [] [ text "Payment made!" ], p [] [ text "Select a product from the dispensing compartment." ] ]
        , img [ class "vending", src "img/order_confirm/vending.png" ] []
        , img [ class "arrow", src "img/order_confirm/arrow.png" ] []
        ]
    , div [ class "confirm_panel2" ]
        [ div [ class "ua" ] [ text "Приготувати страву?" ]
        , div [ class "en gray3" ] [ text "Cook a meal?" ]
        , key_left "key_1" "До головного меню" "Cancel cooking" k1
        , key_ok "key_2" "Приготувати страву!" "Cooking!" k2
        ]
    ]

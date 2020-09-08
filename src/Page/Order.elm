module Page.Order exposing (..)

import Html exposing (Html, div, text, img, span)
import Html.Attributes exposing (class, src, alt)
import Html.Events exposing (onClick)


view : Int -> List (Html msg)
view selected_index =
    [ div [ class "order_header_title" ]
        [ div [] [ text "Замовлення" ]
        , div [] [ text "Order" ]
        ]
    , div [ class "order_header_img" ] [ img [ src "img/sochevitsa.png" ] [] ]
    , div [ class "order_header_content" ] [ text "Замовлення:" ]
    , div [ class "order_header_content_value" ] [ text "Сочевичний суп пюре" ]
    , div [ class "order_header_content_en" ] [ text "Order:" ]
    , div [ class "order_header_content_en_value" ] [ text "Lentil puree soup" ]
    , div [ class "order_header_pay" ] [ text "До сплати:" ]
    , div [ class "order_header_pay_value" ] [ text "30 грн" ]
    , div [ class "order_header_pay_en" ] [ text "Paid:" ]
    , div [ class "order_header_pay_en_value" ] [ text "30 UAH" ]
    , div [ class "order_header_split" ] [ text "" ]
    , div [ class "order_pay_method_label" ]
        [ div [] [ text "Оберіть спосіб оплати" ]
        , div [] [ text "Choose a payment method" ]
        ]
    , div [ class "order order_m1" ]
        [ div [ class "order_m1_card" ] []
        , div [ class "order_m1_card1" ] []
        , img [ src "img/card.png" ] []
        , div [ class "title" ] [ text "Банківська картка" ]
        , div [ class "title_en" ] [ text "Bank card" ]
        ]
    , div [ class "order order_m2" ]
        [ div [ class "title" ] [ text "Через приложения Приват 24" ]
        , div [ class "title_en" ] [ text "Via Privat 24 applications" ]
        , img [ src "img/privatBank.png" ] []
        ]
    , div [ class "order order_m3" ]
        [ div [ class "title" ] [ text "Онлайн з мобільного" ]
        , div [ class "title_en" ] [ text "Online from mobile" ]
        , img [ src "img/pay_qr.png" ] []
        ]
    , div [ class "" ] [ text "" ]
    ]

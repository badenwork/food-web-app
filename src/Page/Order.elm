module Page.Order exposing (..)

import Html exposing (Html, div, text, img, span)
import Html.Attributes exposing (class, src, alt)
import Html.Events exposing (onClick)
import API
import API.Media exposing (imgUrl)
import API.Products exposing (FakeProduct)
import UI.KeyHelper exposing (key_left, key_right, key_ok)


header : FakeProduct -> List (Html msg)
header p =
    [ div [ class "order_header_title" ]
        [ div [] [ text "Замовлення" ]
        , div [] [ text "Order" ]
        ]
    , div [ class "order_header_img" ] [ img [ src <| imgUrl p.image ] [] ]
    , div [ class "order_header_content" ] [ text "Замовлення:" ]
    , div [ class "order_header_content_value" ] [ text p.titleUA ]
    , div [ class "order_header_content_en" ] [ text "Order:" ]
    , div [ class "order_header_content_en_value" ] [ text p.titleEN ]
    , div [ class "order_header_pay" ] [ text "До сплати:" ]
    , div [ class "order_header_pay_value" ] [ text <| p.price ++ " грн" ]
    , div [ class "order_header_pay_en" ] [ text "Paid:" ]
    , div [ class "order_header_pay_en_value" ] [ text <| p.price ++ " UAH" ]
    , div [ class "order_header_split" ] [ text "" ]
    ]


view : FakeProduct -> API.PayMethod -> ( ( msg, msg, msg ), ( msg, msg, msg ) ) -> List (Html msg)
view p pm ( ( s1, s2, s3 ), ( k1, k2, k3 ) ) =
    (header p)
        ++ [ div [ class "order_pay_method_label" ]
                [ div [] [ text "Оберіть спосіб оплати" ]
                , div [] [ text "Choose a payment method" ]
                ]
           , div [ class <| "order order_m1" ++ activeIfTrue (pm == API.PayMethod1), onClick s1 ]
                [ div [ class "order_m1_card" ] []
                , div [ class "order_m1_card1" ] []
                , img [ src "img/card.png" ] []
                , div [ class "title" ] [ text "Банківська картка" ]
                , div [ class "title_en" ] [ text "Bank card" ]
                ]
           , div [ class <| "order order_m2" ++ activeIfTrue (pm == API.PayMethod2), onClick s2 ]
                [ div [ class "title" ] [ text "Через приложения Приват 24" ]
                , div [ class "title_en" ] [ text "Via Privat 24 applications" ]
                , img [ src "img/privatBank.png" ] []
                ]
           , div [ class <| "order order_m3" ++ activeIfTrue (pm == API.PayMethod3), onClick s3 ]
                [ div [ class "title" ] [ text "Онлайн з мобільного" ]
                , div [ class "title_en" ] [ text "Online from mobile" ]
                , img [ src "img/pay_qr.png" ] []
                ]
           , div [ class "order_keys" ]
                [ key_left "key_1" "Вибір вліво" "Select left" k1
                , key_right "key_2" "Вибір вправо" "Select right" k2
                , key_ok "key_3" "Зробити замовлення" "Make an order" k3
                ]
           ]


activeIfTrue : Bool -> String
activeIfTrue true =
    if true then
        " active"
    else
        ""


viewIngenica : FakeProduct -> List (Html msg)
viewIngenica p =
    (header p)
        ++ [ div [ class "order_label" ]
                [ div [] [ text "Піднесіть карту до считувального пристрою" ]
                , div [] [ text "Lift the card to the reader" ]
                ]
           , img [ src "img/order_ingenica.png", class "order_ingenica_image" ] []
           ]


viewPrivat : FakeProduct -> List (Html msg)
viewPrivat p =
    (header p)
        ++ [ div [ class "order_label" ]
                [ div [] [ text "Відкрийте додаток Приват24 та натісніть на считування кьюар коду" ]
                , div [] [ text "Open the Privat24 application and click on reading the cuar code" ]
                ]
           , div [ class "order_pb_1" ]
                [ img [ src "img/order_pb/logo.png", class "logo" ] []
                , img [ src "img/order_pb/QR.png", class "qr" ] []
                , img [ src "img/order_pb/key.png", class "key" ] []
                , img [ src "img/order_pb/arrow.png", class "arrow" ] []
                ]
           ]


viewFondi : FakeProduct -> List (Html msg)
viewFondi p =
    (header p)
        ++ [ div [ class "order_label" ]
                [ div [] [ text "Відкрийте фотокамеру на смартфони та зчитайте кьюар код. Слідуй інструкціі в браузері." ]
                , div [] [ text "Open the camera on smartphones and read the cuar code. Follow the instructions in the browser." ]
                ]
           , div [ class "order_fondi" ]
                [ img [ src "img/order_fondi/QR.png" ] []
                , div [ class "frame" ] []
                , div [ class "line1" ] []
                , div [ class "line2" ] []
                , img [ src "img/order_fondi/QR.png", class "small_qr" ] []
                , div [ class "key" ] []
                ]
           ]

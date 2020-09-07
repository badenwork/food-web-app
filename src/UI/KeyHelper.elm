module UI.KeyHelper exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt)


title =
    div []
        [ div [ class "keyhelper_title" ] [ text "Для вибору користуйтесь кнопками на аппараті" ]
        , div [ class "keyhelper_title2" ] [ text "To select, use the buttons on the device" ]

        -- , div [ class "key1" ] [ img [ class "arrow41", src "svg/key1.svg" ] [] ]
        , div [ class "ellipse10" ] [ img [ src "svg/Ellipse 10.svg" ] [] ]

        --
        -- , div [ class "arrow4" ] [ img [ src "svg/Arrow 4.svg" ] [] ]
        , img [ class "arrow4", src "svg/Arrow 4.svg" ] []
        , div [ class "keyEmptyEllipse ellipse11" ] []
        , div [ class "keyFilledEllipse ellipse3" ] []
        , img [ class "arrow3", src "svg/arrow_right.svg" ] []
        , div [ class "key3_ok" ] [ text "OK" ]
        , div [ class "key1_label" ] [ div [] [ text "Вибір вліво" ], div [ class "gray3" ] [ text "Select left" ] ]
        , div [ class "key2_label" ] [ div [] [ text "Вибір вправо" ], div [ class "gray3" ] [ text "Select right" ] ]
        , div [ class "key3_label" ] [ div [] [ text "Зробити замовлення" ], div [ class "gray3" ] [ text "Make an order" ] ]
        ]

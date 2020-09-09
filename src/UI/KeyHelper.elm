module UI.KeyHelper exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt, attribute)
import Html.Events exposing (onClick)


title : ( msg, msg, msg ) -> Html msg
title ( keyLeft, keyRight, keyOk ) =
    div []
        [ div [ class "keyhelper_title" ] [ text "Для вибору користуйтесь кнопками на аппараті" ]
        , div [ class "keyhelper_title2" ] [ text "To select, use the buttons on the device" ]

        -- , div [ class "key 1" ] [ img [ class "arrow41", src "svg/key1.svg" ] [] ]
        , div [ class "keyEmptyEllipse ellipse10", onClick keyLeft ] [ img [ src "img/arrow-left.png" ] [] ]

        --
        -- , div [ class "arrow4" ] [ img [ src "svg/Arrow 4.svg" ] [] ]
        -- , img [ class "arrow4", src "svg/Arrow 4.svg" ] []
        , div [ class "keyEmptyEllipse ellipse11", onClick keyRight ] [ img [ src "img/arrow-right.png" ] [] ]
        , div [ class "keyFilledEllipse ellipse3", onClick keyOk ] [ text "OK" ]

        -- , img [ class "arrow3", src "svg/arrow_right.svg" ] []
        -- , div [ class "key3_ok" ] [ text "OK" ]
        , div [ class "key1_label" ] [ div [] [ text "Вибір вліво" ], div [ class "gray3" ] [ text "Select left" ] ]
        , div [ class "key2_label" ] [ div [] [ text "Вибір вправо" ], div [ class "gray3" ] [ text "Select right" ] ]
        , div [ class "key3_label" ] [ div [] [ text "Зробити замовлення" ], div [ class "gray3" ] [ text "Make an order" ] ]
        ]


key_left : String -> String -> String -> Html msg
key_left className ua en =
    div [ class ("key_panel " ++ className) ]
        [ div [ class "keyEmptyEllipse" ] [ img [ src "img/arrow-left.png" ] [] ]
        , div [ class "ua" ] [ text ua ]
        , div [ class "en" ] [ text en ]
        ]


key_ok : String -> String -> String -> Html msg
key_ok className ua en =
    div [ class ("key_panel " ++ className) ]
        [ div [ class "keyFilledEllipse" ] [ text "OK" ]
        , div [ class "ua" ] [ text ua ]
        , div [ class "en" ] [ text en ]
        ]

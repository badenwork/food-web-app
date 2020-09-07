module Page.Products exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt, style)


products : List String
products =
    [ "img/ovsanka.png", "img/pure.png", "img/sochevitsa.png", "img/goroh.png", "img/grechka.png", "img/pure.png" ]


view : Int -> Html msg
view selected_index =
    div []
        [ div [ class "product_selector" ]
            [ div [ class "product_headerUA" ] [ text "Сочевичний суп пюре" ]
            , div [ class "product_headerEN" ] [ text "Lentil puree soup" ]
            , div [ class "product_price" ] [ text "30 грн" ]

            -- , div [ class "product_image" ] [ img [ src "img/sochevitsa.png" ] [] ]
            , div [ class "product_description" ]
                [ Html.h1 [] [ text "Склад" ]
                ]
            ]

        -- , div [ class "product_image_m2" ] [ img [ src "img/ovsanka.png" ] [] ]
        -- , div [ class "product_image_m1" ] [ img [ src "img/pure.png" ] [] ]
        -- , div [ class "product_image_p1" ] [ img [ src "img/goroh.png" ] [] ]
        -- , div [ class "product_image_p2" ] [ img [ src "img/grechka.png" ] [] ]
        , div [ class "product_image_row", style "left" (offsetInPixels selected_index) ]
            (products |> List.indexedMap (viewImage selected_index))

        -- [ img [ src "img/ovsanka.png" ] []
        -- , img [ src "img/pure.png" ] []
        -- , img [ class "active", src "img/sochevitsa.png" ] []
        -- , img [ src "img/goroh.png" ] []
        -- , img [ src "img/grechka.png" ] []
        -- ]
        ]


scale =
    326


offsetInPixels : Int -> String
offsetInPixels o =
    -- ((760 - o * 380) |> String.fromInt) ++ "px"
    ((scale * 2 - o * scale - 2) |> String.fromInt) ++ "px"


viewImage : Int -> Int -> String -> Html msg
viewImage active index url =
    if index == active then
        img [ class "active", src url ] []
    else
        img [ src url ] []

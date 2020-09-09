module Page.Products exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt, style)
import List.Extra exposing (getAt)
import Maybe exposing (withDefault)
import API.Products exposing (..)


view : Int -> List (Html msg)
view selected_index =
    let
        p =
            products |> getAt selected_index |> withDefault unknowproduct
    in
        [ div [ class "product_selector" ]
            [ div [ class "product_headerUA" ] [ text p.titleUA ]
            , div [ class "product_headerEN" ] [ text p.titleEN ]
            , div [ class "product_price" ] [ text "30 грн" ]

            -- , div [ class "product_image" ] [ img [ src "img/sochevitsa.png" ] [] ]
            , div [ class "product_descriptionUA" ] <| (p.descriptionUA |> List.map viewDescriptions)
            , div [ class "product_descriptionEN" ] <| (p.descriptionEN |> List.map viewDescriptions)
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


viewDescriptions : ProdDescr -> Html msg
viewDescriptions { title, content } =
    div [] <|
        [ Html.h1 [] [ text title ] ]
            ++ (content
                    |> List.map viewDescriptionLine
               )


viewDescriptionLine : ProcDescrContent -> Html msg
viewDescriptionLine { t1, t2 } =
    div [] [ div [ class "desc_t1" ] [ text t1 ], div [ class "desc_t2" ] [ text t2 ] ]


scale =
    326


offsetInPixels : Int -> String
offsetInPixels o =
    -- ((760 - o * 380) |> String.fromInt) ++ "px"
    ((scale * 2 - o * scale - 2) |> String.fromInt) ++ "px"


viewImage : Int -> Int -> Product -> Html msg
viewImage active index { image } =
    if index == active then
        img [ class "active", src image ] []
    else
        img [ src image ] []

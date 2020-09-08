module Page.Products exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt, style)
import List.Extra exposing (getAt)
import Maybe exposing (withDefault)


type alias Product =
    { title : String
    , image : String
    , description : List ProdDescr
    }


products : List Product
products =
    [ Product "Вiвсянка з малиною" "img/ovsanka.png" product1_descriptions
    , Product "Картопляне пюре з грибами" "img/pure.png" product2_descriptions
    , Product "Сочевичний суп пюре" "img/sochevitsa.png" product1_descriptions
    , Product "Гороховий суп з куркою" "img/goroh.png" product2_descriptions
    , Product "Каша гречана з м'ясом" "img/grechka.png" product1_descriptions
    , Product "Кус-кус з овочами" "img/kuskus.png" product2_descriptions
    ]


unknowproduct : Product
unknowproduct =
    Product "От халепа!" "img/ovsanka.png" product1_descriptions


type alias ProdDescr =
    { title : String

    -- , width : Int
    , content : List ProcDescrContent
    }


type alias ProcDescrContent =
    { t1 : String
    , t2 : String
    }


product1_descriptions : List ProdDescr
product1_descriptions =
    [ ProdDescr "Склад"
        [ ProcDescrContent "83%" "сочевиця"
        , ProcDescrContent "8%" "грінки хлібні"
        , ProcDescrContent "4%" "морква, цибуля"
        , ProcDescrContent "3%" "суміш перців"
        , ProcDescrContent "1%" "зелень та сіль"
        ]
    , ProdDescr "Енергетична цінність на 100г продукту:"
        [ ProcDescrContent "1448.0 ккал" "346.09 кДж"
        ]
    , ProdDescr ""
        [ ProcDescrContent "Білки" "21.61 г"
        , ProcDescrContent "Жири" "4.59 г"
        , ProcDescrContent "Вуглеводи" "44.98 г"
        , ProcDescrContent "Волокно" "0.25 г"
        , ProcDescrContent "Сіль" "1.16 г"
        ]
    ]


product2_descriptions : List ProdDescr
product2_descriptions =
    [ ProdDescr "Склад"
        [ ProcDescrContent "90%" "картофан"
        , ProcDescrContent "8%" "мастило"
        , ProcDescrContent "4%" "морква, цибуля"
        , ProcDescrContent "3%" "суміш перців"
        , ProcDescrContent "1%" "зелень та сіль"
        ]
    , ProdDescr "Енергетична цінність на 100г продукту:"
        [ ProcDescrContent "1448.0 ккал" "346.09 кДж"
        ]
    , ProdDescr ""
        [ ProcDescrContent "Білки" "41.61 г"
        , ProcDescrContent "Жири" "14.59 г"
        , ProcDescrContent "Вуглеводи" "4.98 г"
        , ProcDescrContent "Волокно" "1.25 г"
        , ProcDescrContent "Сіль" "0.16 г"
        ]
    ]


view : Int -> List (Html msg)
view selected_index =
    let
        p =
            products |> getAt selected_index |> withDefault unknowproduct
    in
        [ div [ class "product_selector" ]
            [ div [ class "product_headerUA" ] [ text p.title ]
            , div [ class "product_headerEN" ] [ text "Lentil puree soup (TBD)" ]
            , div [ class "product_price" ] [ text "30 грн" ]

            -- , div [ class "product_image" ] [ img [ src "img/sochevitsa.png" ] [] ]
            , div [ class "product_description" ] <| (p.description |> List.map viewDescriptions)
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

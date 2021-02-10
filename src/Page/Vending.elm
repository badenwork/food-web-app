module Page.Vending exposing (..)

import API.Products exposing (ProductId)
import Array
import Array2D exposing (Array2D)
import Html exposing (Html)
import Html.Attributes as HA
import Types exposing (..)


type alias ProductRec =
    { pid : ProductId
    , count : Int
    }


test_product_array : Array2D ProductRec
test_product_array =
    -- Array2D.fromList
    --     [ [ ProductRec "p1" 5, ProductRec "p2" 0, ProductRec "p3" 0, ProductRec "p4" 0, ProductRec "p5" 6 ]
    --     , [ ProductRec "p6" 5, ProductRec "p7" 0, ProductRec "p8" 0, ProductRec "p9" 0, ProductRec "p10" 6 ]
    --     ]
    Array2D.repeat 8 8 (ProductRec "p1" 5)


viewProductCell : ProductRec -> Html Msg
viewProductCell { pid, count } =
    Html.div []
        [ Html.img [ HA.src "http://vending.local:8081/api/img/sochevitsa.png" ] []
        , Html.h1 [] [ Html.text "Сочевичный суп" ]
        , Html.div [] [ Html.text "0" ]
        ]


view : List (Html Msg)
view =
    let
        ar =
            test_product_array

        columns =
            Array2D.columns ar

        rows =
            Array2D.rows ar

        -- Array.
        asList =
            ar.data
                |> Array.foldr
                    (\row acc ->
                        (row |> Array.foldr (::) []) ++ acc
                    )
                    []

        gr_columns =
            "0"
    in
    [ Html.div [ HA.class "vending_config" ]
        [ Html.div
            [ HA.class "vending_config_grid"
            , HA.style "grid-template-columns" ("repeat(" ++ String.fromInt columns ++ ", 1fr)")
            , HA.style "grid-template-rows" ("repeat(" ++ String.fromInt rows ++ ", 1fr)")
            ]
            (asList |> List.map viewProductCell)
        ]
    ]

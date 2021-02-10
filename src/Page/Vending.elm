module Page.Vending exposing (..)

import API.Products exposing (ProductId)
import Array
import Array2D exposing (Array2D)
import Html exposing (Html)
import Html.Attributes as HA
import Keys exposing (KeyCmd(..))
import Types exposing (..)
import UI.KeyHelper exposing (key_left, key_ok, key_right)


type alias ProductRec =
    { pid : ProductId
    , count : Int
    }


type alias CellRec =
    { pid : ProductId
    , count : Int
    , row : Int
    , col : Int
    }


test_product_array : Array2D ProductRec
test_product_array =
    -- Array2D.fromList
    --     [ [ ProductRec "p1" 5, ProductRec "p2" 0, ProductRec "p3" 0, ProductRec "p4" 0, ProductRec "p5" 6 ]
    --     , [ ProductRec "p6" 5, ProductRec "p7" 0, ProductRec "p8" 0, ProductRec "p9" 0, ProductRec "p10" 6 ]
    --     ]
    Array2D.repeat 8 8 (ProductRec "p1" 5)


max_cnt =
    10


update : KeyCmd -> VendingPageState -> Model -> ( Model, Cmd Msg )
update key ps model =
    let
        max_row =
            Array2D.rows test_product_array - 1

        max_col =
            Array2D.columns test_product_array - 1
    in
    case ps of
        VPS_SelectRow row ->
            case key of
                KeyLeft ->
                    if row > 0 then
                        ( { model | activePage = VendingConfig <| VPS_SelectRow (row - 1) }, Cmd.none )

                    else
                        ( { model | activePage = VendingConfig <| VPS_SelectRow max_row }, Cmd.none )

                KeyRight ->
                    if row < max_row then
                        ( { model | activePage = VendingConfig <| VPS_SelectRow (row + 1) }, Cmd.none )

                    else
                        ( { model | activePage = VendingConfig <| VPS_SelectRow 0 }, Cmd.none )

                KeyOk ->
                    ( { model | activePage = VendingConfig <| VPS_SelectCol row 0 }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        VPS_SelectCol row col ->
            case key of
                KeyLeft ->
                    if col > 0 then
                        ( { model | activePage = VendingConfig <| VPS_SelectCol row (col - 1) }, Cmd.none )

                    else
                        ( { model | activePage = VendingConfig <| VPS_SelectCol row max_col }, Cmd.none )

                KeyRight ->
                    if col < max_col then
                        ( { model | activePage = VendingConfig <| VPS_SelectCol row (col + 1) }, Cmd.none )

                    else
                        ( { model | activePage = VendingConfig <| VPS_SelectCol row 0 }, Cmd.none )

                KeyOk ->
                    ( { model | activePage = VendingConfig <| VPS_SetCount row col 0 }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        VPS_SetCount row col cnt ->
            case key of
                KeyLeft ->
                    if cnt > 0 then
                        ( { model | activePage = VendingConfig <| VPS_SetCount row col (cnt - 1) }, Cmd.none )

                    else
                        ( { model | activePage = VendingConfig <| VPS_SetCount row col 0 }, Cmd.none )

                KeyRight ->
                    if cnt < max_cnt then
                        ( { model | activePage = VendingConfig <| VPS_SetCount row col (cnt + 1) }, Cmd.none )

                    else
                        ( { model | activePage = VendingConfig <| VPS_SetCount row col max_cnt }, Cmd.none )

                KeyOk ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


activeRow : VendingPageState -> Int
activeRow ps =
    case ps of
        VPS_SelectRow row ->
            row

        VPS_SelectCol row _ ->
            row

        VPS_SetCount row _ _ ->
            row


activeCol : VendingPageState -> Int
activeCol ps =
    case ps of
        VPS_SelectRow row ->
            0

        VPS_SelectCol _ col ->
            col

        VPS_SetCount _ col _ ->
            col


viewProductCell : Int -> Int -> CellRec -> Html Msg
viewProductCell arow acol { pid, count, row, col } =
    Html.div
        (if arow == row && acol == col then
            [ HA.class "active" ]

         else
            []
        )
        [ Html.img [ HA.src "http://vending.local:8081/api/img/sochevitsa.png" ] []
        , Html.h1 []
            [ Html.text "Сочевичный суп"
            , Html.text "["
            , Html.text <| String.fromInt row
            , Html.text ","
            , Html.text <| String.fromInt col
            , Html.text "]"
            ]
        , Html.div [] [ Html.text "0" ]
        ]


view : VendingPageState -> ( Msg, Msg, Msg ) -> List (Html Msg)
view ps ( k1, k2, k3 ) =
    let
        f : Int -> Int -> ProductRec -> CellRec
        f row col p =
            CellRec p.pid p.count row col

        ar =
            test_product_array |> Array2D.indexedMap f

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
            (asList |> List.map (viewProductCell (activeRow ps) (activeCol ps)))
        ]
    , Html.div [ HA.class "order_keys" ]
        [ key_left "key_1" "Вибір вліво/догори" "Select left" k1
        , key_right "key_2" "Вибір вправо/донизу" "Select right" k2
        , key_ok "key_3" "Зробити вибiр" "Make an order" k3
        ]
    , Html.div [ HA.class "vending_cfg_label" ]
        [ Html.text <| keys_label ps
        , Html.text " ["
        , Html.text <| String.fromInt (activeRow ps)
        , Html.text ","
        , Html.text <| String.fromInt (activeCol ps)
        , Html.text "]"
        ]
    ]


keys_label : VendingPageState -> String
keys_label ps =
    case ps of
        VPS_SelectRow row ->
            "Выберите ряд: " ++ String.fromInt row

        VPS_SelectCol _ col ->
            "Выберите столбец: " ++ String.fromInt col

        VPS_SetCount _ _ cnt ->
            "Кол-во продукта в ячейке: " ++ String.fromInt cnt

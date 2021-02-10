module Page.Vending exposing (..)

-- import Array2D exposing (Array2D)

import API.Loads exposing (Loads)
import API.Media exposing (imgUrl)
import API.Products exposing (FakeProduct, ProductId)
import API.Vending exposing (Vending)
import Array
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HA
import Keys exposing (KeyCmd(..))
import List.Extra
import Maybe exposing (withDefault)
import Types exposing (..)
import UI.KeyHelper exposing (key_left, key_ok, key_right)



-- type alias ProductRec =
--     { pid : ProductId
--     , count : Int
--     }


type alias CellRec =
    { product : FakeProduct
    , count : Int
    , row : Int
    , col : Int
    }



-- test_product_array : Array2D ProductRec
-- test_product_array =
--     -- Array2D.fromList
--     --     [ [ ProductRec "p1" 5, ProductRec "p2" 0, ProductRec "p3" 0, ProductRec "p4" 0, ProductRec "p5" 6 ]
--     --     , [ ProductRec "p6" 5, ProductRec "p7" 0, ProductRec "p8" 0, ProductRec "p9" 0, ProductRec "p10" 6 ]
--     --     ]
--     Array2D.repeat 8 8 (ProductRec "p1" 5)


max_cnt =
    10


update : KeyCmd -> VendingPageState -> Model -> ( Model, Cmd Msg )
update key ps model =
    let
        new_products =
            case model.vending of
                Nothing ->
                    []

                Just v ->
                    let
                        getProduct pid =
                            Dict.get pid model.products
                                |> Maybe.withDefault API.Products.unknowFakeProduct
                    in
                    v.products
                        |> List.map getProduct

        get_product_id index =
            new_products |> List.Extra.getAt index |> withDefault API.Products.unknowFakeProduct |> .id

        ( max_row, max_col, prlist ) =
            case model.vending of
                Nothing ->
                    ( 0, 0, 0 )

                Just v ->
                    case v.hwType of
                        API.Vending.VHWT_Array rows cols ->
                            ( rows - 1, cols - 1, List.length new_products - 1 )
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
                    ( { model | activePage = VendingConfig <| VPS_SetProduct row col -1 }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        VPS_SetProduct row col pid ->
            let
                update_pid new_pid =
                    ( { model
                        | activePage = VendingConfig <| VPS_SetProduct row col new_pid
                        , product_array = Dict.insert ( row, col ) (API.Loads.Load (get_product_id new_pid) 0) model.product_array
                      }
                    , Cmd.none
                    )
            in
            case key of
                KeyLeft ->
                    if pid > -1 then
                        update_pid (pid - 1)

                    else
                        ( model, Cmd.none )

                KeyRight ->
                    if pid < prlist then
                        update_pid (pid + 1)

                    else
                        update_pid prlist

                KeyOk ->
                    ( { model | activePage = VendingConfig <| VPS_SetCount row col pid 0 }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        VPS_SetCount row col pid cnt ->
            let
                update_cnt new_cnt =
                    ( { model
                        | activePage = VendingConfig <| VPS_SetCount row col pid new_cnt
                        , product_array = Dict.insert ( row, col ) (API.Loads.Load (get_product_id pid) new_cnt) model.product_array
                      }
                    , Cmd.none
                    )
            in
            case key of
                KeyLeft ->
                    if cnt > 0 then
                        update_cnt (cnt - 1)
                        -- ( { model | activePage = VendingConfig <| VPS_SetCount row col pid (cnt - 1) }, Cmd.none )

                    else
                        update_cnt 0

                -- ( { model | activePage = VendingConfig <| VPS_SetCount row col pid 0 }, Cmd.none )
                KeyRight ->
                    if cnt < max_cnt then
                        update_cnt (cnt + 1)
                        -- ( { model | activePage = VendingConfig <| VPS_SetCount row col pid (cnt + 1) }, Cmd.none )

                    else
                        update_cnt max_cnt

                -- ( { model | activePage = VendingConfig <| VPS_SetCount row col pid max_cnt }, Cmd.none )
                KeyOk ->
                    ( { model | activePage = VendingConfig <| VPS_SelectRow row }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


activeRow : VendingPageState -> Int
activeRow ps =
    case ps of
        VPS_SelectRow row ->
            row

        VPS_SelectCol row _ ->
            row

        VPS_SetProduct row _ _ ->
            row

        VPS_SetCount row _ _ _ ->
            row


activeCol : VendingPageState -> Int
activeCol ps =
    case ps of
        VPS_SelectRow row ->
            0

        VPS_SelectCol _ col ->
            col

        VPS_SetProduct _ col _ ->
            col

        VPS_SetCount _ col _ _ ->
            col


viewProductCell : Int -> Int -> Dict String String -> CellRec -> Html Msg
viewProductCell arow acol images { product, count, row, col } =
    Html.div
        (if arow == row && acol == col then
            [ HA.class "active" ]

         else
            []
        )
        [ Html.img [ HA.src <| imgUrl product.image ] []
        , Html.h1 []
            [ Html.text product.titleUA
            , Html.text "["
            , Html.text <| String.fromInt row
            , Html.text ","
            , Html.text <| String.fromInt col
            , Html.text "]"
            ]
        , Html.div [] [ Html.text <| String.fromInt count ]
        ]


viewAsArray : VendingPageState -> ( Msg, Msg, Msg ) -> Vending -> List FakeProduct -> Dict String String -> ( Int, Int ) -> Loads -> Dict ProductId FakeProduct -> List (Html Msg)
viewAsArray ps ( k1, k2, k3 ) vending products images ( rows, cols ) loads products_dict =
    -- TODO: Use just needed data from model
    let
        asList =
            List.Extra.initialize rows
                (\row ->
                    List.Extra.initialize cols
                        (\col ->
                            let
                                activeProduct =
                                    case Dict.get ( row, col ) loads of
                                        Nothing ->
                                            API.Loads.Load "" 0

                                        Just load ->
                                            load

                                product =
                                    -- products |> List.Extra.getAt activeProduct |> withDefault API.Products.unknowFakeProduct
                                    Dict.get activeProduct.pid products_dict
                                        |> Maybe.withDefault API.Products.unknowFakeProduct
                            in
                            CellRec product activeProduct.count row col
                        )
                )
                |> List.concat

        -- List.range 0 (rows - 1)
        -- ar.data
        -- |> Array.foldr
        --     (\row acc ->
        --         (row |> Array.foldr (::) []) ++ acc
        --     )
        --     []
        -- gr_columns =
        --     "0"
    in
    [ Html.div [ HA.class "vending_config" ]
        [ Html.div
            [ HA.class "vending_config_grid"
            , HA.style "grid-template-columns" ("repeat(" ++ String.fromInt cols ++ ", 1fr)")
            , HA.style "grid-template-rows" ("repeat(" ++ String.fromInt rows ++ ", 1fr)")
            ]
            (asList |> List.map (viewProductCell (activeRow ps) (activeCol ps) images))
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


view : VendingPageState -> ( Msg, Msg, Msg ) -> Vending -> List FakeProduct -> Dict String String -> Loads -> Dict ProductId FakeProduct -> List (Html Msg)
view ps ( k1, k2, k3 ) vending products images loads products_dict =
    case vending.hwType of
        API.Vending.VHWT_Array rows cols ->
            viewAsArray ps ( k1, k2, k3 ) vending products images ( rows, cols ) loads products_dict


keys_label : VendingPageState -> String
keys_label ps =
    case ps of
        VPS_SelectRow row ->
            "Выберите ряд: " ++ String.fromInt row

        VPS_SelectCol _ col ->
            "Выберите столбец: " ++ String.fromInt col

        VPS_SetProduct _ _ pid ->
            "Выберите продукт в ячейке: " ++ String.fromInt pid

        VPS_SetCount _ _ _ cnt ->
            "Кол-во продукта в ячейке: " ++ String.fromInt cnt

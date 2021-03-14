module Page.Calibration exposing (..)

import API.Products exposing (ProductId)
import API.Vending exposing (VHWT_Array_Config)
import Array
import Array2D exposing (Array2D)
import Html exposing (Html, div, li, span, text, ul)
import Html.Attributes as HA exposing (class, classList)
import Keys exposing (KeyCmd(..))
import List.Extra
import Types exposing (..)
import UI.KeyHelper exposing (key_left, key_ok, key_right)


initCalibrationState : CalibrationPageState
initCalibrationState =
    CPS_SelectParam API.Vending.initVHWT_Array_Config 0


update : KeyCmd -> CalibrationPageState -> Model -> ( Model, Cmd Msg )
update key ps model =
    case ps of
        CPS_SelectParam hw selector ->
            case key of
                KeyLeft ->
                    if selector > 0 then
                        ( { model | activePage = Calibration (CPS_SelectParam hw (selector - 1)) }, Cmd.none )

                    else
                        ( { model | activePage = Calibration (CPS_SelectParam hw (List.length params - 1)) }, Cmd.none )

                KeyRight ->
                    if selector < List.length params - 1 then
                        ( { model | activePage = Calibration (CPS_SelectParam hw (selector + 1)) }, Cmd.none )

                    else
                        ( { model | activePage = Calibration (CPS_SelectParam hw 0) }, Cmd.none )

                KeyOk ->
                    ( { model | activePage = Calibration (CPS_EditParam hw selector 0) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CPS_EditParam hw selector value ->
            case List.Extra.getAt selector params of
                Nothing ->
                    ( model, Cmd.none )

                Just { title, getter, setter } ->
                    case key of
                        KeyLeft ->
                            let
                                newHw =
                                    setter (getter hw - 1) hw
                            in
                            ( { model | activePage = Calibration (CPS_EditParam newHw selector 0) }, Cmd.none )

                        KeyRight ->
                            let
                                newHw =
                                    setter (getter hw + 1) hw
                            in
                            ( { model | activePage = Calibration (CPS_EditParam newHw selector 0) }, Cmd.none )

                        KeyOk ->
                            ( { model | activePage = Calibration (CPS_SelectParam hw selector) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )


type alias Param =
    { title : String
    , getter : VHWT_Array_Config -> Int
    , setter : Int -> VHWT_Array_Config -> VHWT_Array_Config
    }


view : CalibrationPageState -> ( Msg, Msg, Msg ) -> List (Html Msg)
view ps ( k1, k2, k3 ) =
    let
        ( keysclass, t1, t2 ) =
            case ps of
                CPS_SelectParam _ _ ->
                    ( " rotated", "Вибір догори", "Вибір донизу" )

                CPS_EditParam _ _ _ ->
                    ( "", "Менше", "Більше" )

        ( body, key_title ) =
            case ps of
                CPS_SelectParam hw selector ->
                    ( params
                        |> List.indexedMap
                            (\i { title, getter, setter } ->
                                li [ classList [ ( "selected", i == selector ) ] ] [ span [] [ text title ], span [] [ text <| String.fromInt (getter hw) ] ]
                            )
                        |> ul []
                    , "Оберiть параметр"
                    )

                CPS_EditParam hw selector value ->
                    ( params
                        |> List.indexedMap
                            (\i { title, getter, setter } ->
                                li [ classList [ ( "edited", i == selector ) ] ] [ span [] [ text title ], span [] [ text <| String.fromInt (getter hw) ] ]
                            )
                        |> ul []
                    , "Встановiть значення"
                    )
    in
    [ div [ class "calibration" ]
        [ Html.h1 [] [ text "Налаштування автомата" ]
        , body
        , div [ HA.class <| "vending_keys" ++ keysclass ]
            [ key_left "key_1" t1 "" k1
            , key_right "key_2" t2 "" k2
            , key_ok "key_3" "Зробити вибiр" "" k3
            ]
        , Html.div [ HA.class "vending_cfg_label" ] [ Html.text key_title ]
        ]
    ]


params =
    [ Param "Мотор переміщення по рядах:" .motorRow (\v m -> { m | motorRow = v })
    , Param "Мотор переміщення по стовпцях:" .motorCol (\v m -> { m | motorCol = v })
    , Param "Робочий напрямок обертання по рядах:" .motorRowDirection (\v m -> { m | motorRowDirection = v })
    , Param "Робочий напрямок обертання по стовпцях:" .motorColDirection (\v m -> { m | motorColDirection = v })
    , Param "Кількість кроків між рядами:" .rowSteps (\v m -> { m | rowSteps = v })
    , Param "Кількість кроків між стовпцями:" .colSteps (\v m -> { m | colSteps = v })
    , Param "Початкове зміщення до першого ряду:" .rowOffset (\v m -> { m | rowOffset = v })
    , Param "Початкове зміщення до першого стовпця:" .colOffset (\v m -> { m | colOffset = v })
    , Param "Кількість кроків для викидання" .pullSteps (\v m -> { m | pullSteps = v })
    , Param "Швидкість розгону (імп / с^2)" .accelStart (\v m -> { m | accelStart = v })
    , Param "Швидкість гальмування (імп / с^2)" .accelStop (\v m -> { m | accelStop = v })
    , Param "Початкова швидкість (Гц * 2)" .speedStart (\v m -> { m | speedStart = v })
    , Param "Номінальна швидкість (Гц * 2)" .speedNominal (\v m -> { m | speedNominal = v })
    , Param "Максимальний час руху (мс)" .timeout (\v m -> { m | timeout = v })
    ]

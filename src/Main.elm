port module Main exposing (..)

-- import Html.Lazy exposing (lazy)

import API
import API.Events as Events
import API.Loads exposing (Loads)
import API.Products exposing (ProductId)
import API.Vending exposing (Vending)
import Browser
import Browser.Events
import DebugFrame
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, h4, img, input, label, li, span, text, ul, video)
import Html.Attributes as HA exposing (checked, class, controls, height, href, id, name, src, type_, width)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Keys exposing (KeyCmd(..))
import List.Extra exposing (getAt)
import MD5
import Maybe exposing (withDefault)
import Page.Cook
import Page.Order
import Page.OrderConfirm
import Page.Products
import Page.TakingOut
import Page.Vending
import Time
import Types exposing (..)
import UI
import UI.KeyHelper



---- MODEL ----


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { vending = Nothing
      , flags = flags
      , id = "unknown"
      , activeProduct = 0
      , connectionState = NotConnected
      , activePage = Products
      , activePayMethod = API.PayMethod1
      , cookTimer = 0
      , images = Dict.empty
      , error = Nothing
      , products = Dict.empty
      , product_array = Dict.empty
      , debugEvents = []
      , showDebugEvents = False

      -- , vendingState = VPS_SelectRow 0
      }
    , Cmd.batch <|
        -- [ websocketOpen (api_url flags.hostname)
        [ websocketOpen (api_url "vending.local")
        , readVending
        , debugMessage "Init"
        ]
    )


readVending =
    Http.request
        { method = "GET"
        , headers = [ API.acao ]
        , url = API.Vending.url
        , body = Http.emptyBody
        , expect = Http.expectJson ReadVendingDone API.Vending.decodeVending
        , timeout = Nothing
        , tracker = Nothing
        }


readProduct pid =
    Http.request
        { method = "GET"
        , headers = [ API.acao ]
        , url = API.Products.url pid
        , body = Http.emptyBody
        , expect = Http.expectJson ReadProductDone API.Products.decodeProduct
        , timeout = Nothing
        , tracker = Nothing
        }


cookTimerInit =
    20



---- UPDATE ----
-- type alias Product =
--     { title : String
--     , image_src : String
--     , description : List ( String, String )
--     }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ activeProduct } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Tick newTime ->
            -- TODO: Может условие стоит перенести в subscriptions ?
            case model.activePage of
                Cooking ->
                    if model.cookTimer > 0 then
                        ( { model | cookTimer = model.cookTimer - 1 }, Cmd.none )

                    else
                        ( { model | activePage = CookingDone }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        KeyPress KeyLeft ->
            case model.activePage of
                Products ->
                    if activeProduct <= 0 then
                        ( { model | activeProduct = productsCnt model.vending - 1 }, Cmd.none )

                    else
                        ( { model | activeProduct = model.activeProduct - 1 }, Cmd.none )

                Order ->
                    ( { model | activePayMethod = prevPayMethod model.activePayMethod }, Cmd.none )

                OrderConfirm ->
                    ( { model | activePage = Products }, Cmd.none )

                CookAsk1 ->
                    ( { model | activePage = Products }, Cmd.none )

                CookAsk2 ->
                    ( { model | activePage = Products }, Cmd.none )

                VendingConfig ps ->
                    -- TODO: Вынести это и остальное в глобал
                    Page.Vending.update KeyLeft ps model

                -- ( model, Cmd.none )
                _ ->
                    ( model, Cmd.none )

        KeyPress KeyRight ->
            case model.activePage of
                Products ->
                    if activeProduct >= productsCnt model.vending - 1 then
                        ( { model | activeProduct = 0 }, Cmd.none )

                    else
                        ( { model | activeProduct = model.activeProduct + 1 }, Cmd.none )

                Order ->
                    ( { model | activePayMethod = nextPayMethod model.activePayMethod }, Cmd.none )

                VendingConfig ps ->
                    -- TODO: Вынести это и остальное в глобал
                    Page.Vending.update KeyRight ps model

                _ ->
                    ( model, Cmd.none )

        KeyPress KeyOk ->
            case model.activePage of
                Products ->
                    ( { model | activePage = Order }, Cmd.none )

                Order ->
                    case model.activePayMethod of
                        API.PayMethod1 ->
                            ( { model | activePage = OrderIngenica }, Cmd.batch [] )

                        API.PayMethod2 ->
                            ( { model | activePage = OrderPrivat }, Cmd.batch [] )

                        API.PayMethod3 ->
                            ( { model | activePage = OrderFondi }, Cmd.batch [] )

                OrderIngenica ->
                    ( { model | activePage = TakingOut }, startProcess model )

                OrderPrivat ->
                    ( { model | activePage = TakingOut }, startProcess model )

                OrderFondi ->
                    ( { model | activePage = TakingOut }, startProcess model )

                TakingOut ->
                    ( { model | activePage = OrderConfirm }, sendConfirm model )

                OrderConfirm ->
                    ( { model | activePage = CookAsk1 }, Cmd.none )

                CookAsk1 ->
                    ( { model | activePage = CookAsk2 }, Cmd.none )

                CookAsk2 ->
                    ( { model | activePage = Cooking, cookTimer = cookTimerInit }, Cmd.none )

                Cooking ->
                    ( model, Cmd.none )

                CookingDone ->
                    ( { model | activePage = Products }, sendCooking model )

                VendingConfig ps ->
                    -- TODO: Вынести это и остальное в глобал
                    Page.Vending.update KeyOk ps model

        KeyPress DebugClick ->
            ( { model | showDebugEvents = not model.showDebugEvents }, Cmd.none )

        KeyPress Undefined ->
            ( model, Cmd.none )

        KeyPress ShowVending ->
            case model.activePage of
                VendingConfig _ ->
                    ( { model | activePage = Products, activeProduct = 0 }, Cmd.none )

                _ ->
                    ( { model | activePage = VendingConfig (VPS_SelectRow 0 0) }, Cmd.none )

        SelectPayMethod pm ->
            ( { model | activePayMethod = pm }, Cmd.none )

        WebsocketOpened False ->
            ( { model | connectionState = NotConnected }, Cmd.none )

        WebsocketOpened True ->
            ( { model | connectionState = Connected }, Cmd.none )

        WebsocketIn message ->
            let
                res =
                    API.parsePayload message

                ( m, u ) =
                    case res of
                        Just (API.Key API.Key1) ->
                            update (KeyPress KeyLeft) model

                        Just (API.Key API.Key2) ->
                            update (KeyPress KeyOk) model

                        Just (API.Key API.Key3) ->
                            update (KeyPress KeyRight) model

                        Just (API.Key API.KeyUnknown) ->
                            ( model, Cmd.none )

                        Just (API.Id id) ->
                            ( { model | id = id }, Cmd.none )

                        Just (API.Error _) ->
                            ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )
            in
            ( m, Cmd.batch [ u, debugMessage ("WS" ++ message) ] )

        OpenWebsocket url ->
            ( model, websocketOpen url )

        ReadFileDone (Ok { name, data }) ->
            ( { model | images = Dict.insert name data model.images }, Cmd.none )

        ReadFileDone (Err _) ->
            -- TBD, file not found?
            ( model, Cmd.none )

        ReadVendingDone (Err err) ->
            let
                title =
                    "Ошибка получения данных конфигурации."
            in
            case err of
                Http.BadBody str ->
                    ( { model | error = Just [ title, str ] }, Cmd.none )

                Http.NetworkError ->
                    ( { model | error = Just [ title, "Транспортный сервер не запущен." ] }, Cmd.none )

                Http.BadStatus 404 ->
                    ( { model | error = Just [ title, "Торговый автомат не зарегестрирован." ] }, Cmd.none )

                _ ->
                    ( { model | error = Just [ title ] }, Cmd.none )

        ReadVendingDone (Ok sa) ->
            ( { model | vending = Just sa }
            , Cmd.batch <|
                [ Events.send (Events.EventInit sa) EventConfirmDone ]
                    ++ (sa.products |> List.map readProduct)
            )

        ReadProductDone (Ok product) ->
            ( { model | products = Dict.insert product.id product model.products }, Cmd.none )

        ReadProductDone (Err _) ->
            ( model, Cmd.none )

        EventConfirmDone res ->
            ( model, Cmd.none )

        EventProcessDone res ->
            -- let
            --     _ =
            --         Debug.log "EventProcessDone" res
            -- in
            ( model, Cmd.none )

        DebugMessage s ->
            ( { model | debugEvents = model.debugEvents ++ [ s ] }, Cmd.none )


productsCnt : Maybe Vending -> Int
productsCnt mv =
    case mv of
        Nothing ->
            0

        Just v ->
            List.length v.products


sendConfirm : Model -> Cmd Msg
sendConfirm model =
    case model.vending of
        Nothing ->
            -- TODO: Нужно какое-то сообщение об ошибке
            Cmd.none

        Just vending ->
            let
                getProduct pid =
                    Dict.get pid model.products
                        |> Maybe.withDefault API.Products.unknowFakeProduct

                new_products =
                    vending.products
                        |> List.map getProduct

                product =
                    new_products |> getAt model.activeProduct |> withDefault API.Products.unknowFakeProduct

                -- payload =
                --     Events.EventConfirm_ product.id model.activePayMethod
            in
            -- Events.sendConfirm payload EventConfirmDone
            Events.send (Events.EventConfirm { product = product, payMethod = model.activePayMethod, price = product.price }) EventConfirmDone


sendCooking : Model -> Cmd Msg
sendCooking model =
    case model.vending of
        Nothing ->
            -- TODO: Нужно какое-то сообщение об ошибке
            Cmd.none

        Just vending ->
            let
                getProduct pid =
                    Dict.get pid model.products
                        |> Maybe.withDefault API.Products.unknowFakeProduct

                new_products =
                    vending.products
                        |> List.map getProduct

                product =
                    new_products |> getAt model.activeProduct |> withDefault API.Products.unknowFakeProduct
            in
            Events.send (Events.EventCooking product) EventConfirmDone


nextPayMethod : API.PayMethod -> API.PayMethod
nextPayMethod pm =
    case pm of
        API.PayMethod1 ->
            API.PayMethod2

        API.PayMethod2 ->
            API.PayMethod3

        API.PayMethod3 ->
            API.PayMethod1


prevPayMethod : API.PayMethod -> API.PayMethod
prevPayMethod pm =
    case pm of
        API.PayMethod1 ->
            API.PayMethod3

        API.PayMethod2 ->
            API.PayMethod1

        API.PayMethod3 ->
            API.PayMethod2


startProcess : Model -> Cmd Msg
startProcess model =
    -- websocketOut <|
    --     cmdTest
    Events.process (Events.EventTakeOut model.activeProduct) EventProcessDone


cmdTest =
    Encode.object
        [ ( "cmd", Encode.string "test" )
        , ( "token", Encode.string "TBD" )
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "body" ] [ viewBody model, DebugFrame.viewDebug model (KeyPress DebugClick) ]


viewBody : Model -> Html Msg
viewBody model =
    case model.error of
        Nothing ->
            case model.vending of
                Nothing ->
                    div [] [ Html.text "Конфигурация еще не загружена" ]

                Just vending ->
                    div [] <|
                        [ UI.header vending.logo vending.header
                        , UI.footer vending.footer1 vending.footer2 model.id
                        ]
                            ++ viewPage vending model

        Just error ->
            div [ HA.class "error" ] ((error ++ [ model.id ]) |> List.map (\s -> div [ HA.class "selector" ] [ Html.text s ]))


viewPage : Vending -> Model -> List (Html Msg)
viewPage vending model =
    let
        getProduct pid =
            Dict.get pid model.products
                |> Maybe.withDefault API.Products.unknowFakeProduct

        new_products =
            vending.products
                |> List.map getProduct

        active_product =
            new_products |> getAt model.activeProduct |> withDefault API.Products.unknowFakeProduct

        -- _ =
        --     Debug.log "new_products" ( new_products |> List.map .id, active_product.id )
    in
    case model.activePage of
        Products ->
            [ UI.KeyHelper.title ( KeyPress KeyLeft, KeyPress KeyRight, KeyPress KeyOk ) ]
                -- ++ Page.Products.view model.images products model.activeProduct
                ++ Page.Products.view model.images new_products active_product model.activeProduct

        Order ->
            Page.Order.view
                active_product
                model.activePayMethod
                ( ( SelectPayMethod API.PayMethod1, SelectPayMethod API.PayMethod2, SelectPayMethod API.PayMethod3 ), ( KeyPress KeyLeft, KeyPress KeyRight, KeyPress KeyOk ) )

        OrderIngenica ->
            Page.Order.viewIngenica active_product

        OrderPrivat ->
            Page.Order.viewPrivat active_product

        OrderFondi ->
            Page.Order.viewFondi active_product

        TakingOut ->
            Page.TakingOut.view active_product

        OrderConfirm ->
            Page.OrderConfirm.view ( KeyPress KeyLeft, KeyPress KeyOk )

        CookAsk1 ->
            Page.Cook.viewAsk1 active_product ( KeyPress KeyLeft, KeyPress KeyOk )

        CookAsk2 ->
            Page.Cook.viewAsk2 active_product ( KeyPress KeyLeft, KeyPress KeyOk )

        Cooking ->
            Page.Cook.viewCooking model.cookTimer active_product

        CookingDone ->
            Page.Cook.viewCookingDone active_product

        VendingConfig ps ->
            Page.Vending.view ps ( KeyPress KeyLeft, KeyPress KeyRight, KeyPress KeyOk ) vending new_products model.images model.product_array model.products



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


api_url : String -> String
api_url hostname =
    -- "ws://localhost:8001"
    -- "ws://localhost:8081/api/ws"
    "ws://" ++ hostname ++ ":8081/api/ws"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown Keys.keyDecoder |> Sub.map KeyPress
        , websocketOpened WebsocketOpened
        , websocketIn WebsocketIn
        , Time.every 1000 Tick
        , debugIn DebugMessage
        ]


readFileDecoder : Decode.Decoder ReadFile
readFileDecoder =
    Decode.map2 ReadFile
        (Decode.field "name" Decode.string)
        (Decode.field "data" Decode.string)


port websocketOpen : String -> Cmd msg


port websocketOpened : (Bool -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Encode.Value -> Cmd msg


port debugMessage : String -> Cmd msg


port debugIn : (String -> msg) -> Sub msg

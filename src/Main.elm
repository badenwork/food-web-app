port module Main exposing (..)

import API
import API.Events as Events
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
import List.Extra exposing (getAt)
import MD5
import Maybe exposing (withDefault)
import Page.Cook
import Page.Order
import Page.OrderConfirm
import Page.Products
import Page.TakingOut
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
      , debugEvents = []
      , showDebugEvents = True
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

        KeyLeft ->
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

                _ ->
                    ( model, Cmd.none )

        KeyRight ->
            case model.activePage of
                Products ->
                    if activeProduct >= productsCnt model.vending - 1 then
                        ( { model | activeProduct = 0 }, Cmd.none )

                    else
                        ( { model | activeProduct = model.activeProduct + 1 }, Cmd.none )

                Order ->
                    ( { model | activePayMethod = nextPayMethod model.activePayMethod }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        KeyOk ->
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

        CharacterPressed 'd' ->
            update KeyRight model

        CharacterPressed 'a' ->
            update KeyLeft model

        CharacterPressed 's' ->
            update KeyOk model

        CharacterPressed ' ' ->
            update KeyOk model

        CharacterPressed '`' ->
            update DebugClick model

        CharacterPressed k ->
            ( model, Cmd.none )

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
                            update KeyLeft model

                        Just (API.Key API.Key2) ->
                            update KeyOk model

                        Just (API.Key API.Key3) ->
                            update KeyRight model

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
            let
                _ =
                    Debug.log "EventProcessDone" res
            in
            ( model, Cmd.none )

        DebugClick ->
            ( { model | showDebugEvents = not model.showDebugEvents }, Cmd.none )

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
    div [ class "body" ] [ viewBody model, DebugFrame.viewDebug model DebugClick ]


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
            [ UI.KeyHelper.title ( KeyLeft, KeyRight, KeyOk ) ]
                -- ++ Page.Products.view model.images products model.activeProduct
                ++ Page.Products.view model.images new_products active_product model.activeProduct

        Order ->
            Page.Order.view
                active_product
                model.activePayMethod
                ( ( SelectPayMethod API.PayMethod1, SelectPayMethod API.PayMethod2, SelectPayMethod API.PayMethod3 ), ( KeyLeft, KeyRight, KeyOk ) )

        OrderIngenica ->
            Page.Order.viewIngenica active_product

        OrderPrivat ->
            Page.Order.viewPrivat active_product

        OrderFondi ->
            Page.Order.viewFondi active_product

        TakingOut ->
            Page.TakingOut.view active_product

        OrderConfirm ->
            Page.OrderConfirm.view ( KeyLeft, KeyOk )

        CookAsk1 ->
            Page.Cook.viewAsk1 active_product ( KeyLeft, KeyOk )

        CookAsk2 ->
            Page.Cook.viewAsk2 active_product ( KeyLeft, KeyOk )

        Cooking ->
            Page.Cook.viewCooking model.cookTimer active_product

        CookingDone ->
            Page.Cook.viewCookingDone active_product



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Msg
toKey string =
    case string of
        "ArrowRight" ->
            toKey "d"

        "ArrowLeft" ->
            toKey "a"

        "ArrowDown" ->
            toKey "s"

        "Enter" ->
            toKey "s"

        "A" ->
            toKey "a"

        "D" ->
            toKey "d"

        "ф" ->
            toKey "a"

        "в" ->
            toKey "d"

        "Ф" ->
            toKey "a"

        "В" ->
            toKey "d"

        _ ->
            case String.uncons string of
                Just ( char, "" ) ->
                    CharacterPressed char

                _ ->
                    NoOp


api_url : String -> String
api_url hostname =
    -- "ws://localhost:8001"
    -- "ws://localhost:8081/api/ws"
    "ws://" ++ hostname ++ ":8081/api/ws"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown keyDecoder
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

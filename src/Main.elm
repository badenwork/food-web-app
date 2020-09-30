port module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, text, div, h1, h4, img, ul, li, video, a, input, label, span)
import Html.Attributes as HA exposing (src, class, controls, width, height, href, type_, name, checked, id)
import Json.Decode as Decode
import List.Extra exposing (getAt)
import MD5
import Json.Encode as Encode
import Http
import API
import UI
import UI.KeyHelper
import Page.Products
import Page.Order
import Page.OrderConfirm
import Page.Cook
import Time
import API.Products exposing (..)
import API.Vending exposing (Vending)
import Maybe exposing (withDefault)
import Dict exposing (Dict)


---- MODEL ----


type Page
    = Products
    | Order
    | OrderIngenica
    | OrderPrivat
    | OrderFondi
    | OrderConfirm
    | CookAsk1
    | CookAsk2
    | Cooking
    | CookingDone


type alias Model =
    { vending : Maybe Vending
    , id : String
    , activeProduct : Int
    , connectionState : ConnectionState
    , activePage : Page
    , activePayMethod : API.PayMethod
    , cookTimer : Int
    , images : Dict String String
    , error : Maybe (List String)
    }


type ConnectionState
    = NotConnected
    | Connected


init : ( Model, Cmd Msg )
init =
    ( { vending = Nothing
      , id = "unknown"
      , activeProduct = 0
      , connectionState = NotConnected
      , activePage = Products
      , activePayMethod = API.PayMethod1
      , cookTimer = 0
      , images = Dict.empty
      , error = Nothing
      }
    , Cmd.batch <|
        [ websocketOpen api_url
        ]
            ++ readImages
            ++ [ readVending ]
    )


readVending =
    Http.request
        { method = "GET"
        , headers = [ API.acao ]
        , url = API.Vending.url

        -- , body = Product.productRequest product |> Http.jsonBody
        , body = Http.emptyBody
        , expect = Http.expectJson ReadVendingDone API.Vending.decodeVending
        , timeout = Nothing
        , tracker = Nothing

        -- , withCredentials = False
        }


type alias Response a =
    Result Http.Error a


readImages =
    API.Products.products |> List.map .image |> List.map readFile


cookTimerInit =
    -- 20
    5



---- UPDATE ----


type Msg
    = NoOp
    | CharacterPressed Char
    | WebsocketIn String
    | OpenWebsocket String
    | WebsocketOpened Bool
    | KeyLeft
    | KeyRight
    | KeyOk
    | Tick Time.Posix
    | SelectPayMethod API.PayMethod
    | ReadFileDone (Result Decode.Error ReadFile)
    | ReadVendingDone (Response API.Vending.Vending)


type alias Product =
    { title : String
    , image_src : String
    , description : List ( String, String )
    }


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
                        ( { model | activeProduct = 5 }, Cmd.none )
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
                    if activeProduct >= 5 then
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
                            ( { model | activePage = OrderIngenica }, Cmd.batch [ startProcess ] )

                        API.PayMethod2 ->
                            ( { model | activePage = OrderPrivat }, Cmd.batch [ startProcess ] )

                        API.PayMethod3 ->
                            ( { model | activePage = OrderFondi }, Cmd.batch [ startProcess ] )

                OrderIngenica ->
                    ( { model | activePage = OrderConfirm }, Cmd.none )

                OrderPrivat ->
                    ( { model | activePage = OrderConfirm }, Cmd.none )

                OrderFondi ->
                    ( { model | activePage = OrderConfirm }, Cmd.none )

                OrderConfirm ->
                    ( { model | activePage = CookAsk1 }, Cmd.none )

                CookAsk1 ->
                    ( { model | activePage = CookAsk2 }, Cmd.none )

                CookAsk2 ->
                    ( { model | activePage = Cooking, cookTimer = cookTimerInit }, Cmd.none )

                Cooking ->
                    ( model, Cmd.none )

                CookingDone ->
                    ( { model | activePage = Products }, Cmd.none )

        CharacterPressed 'd' ->
            update KeyRight model

        CharacterPressed 'a' ->
            update KeyLeft model

        CharacterPressed 's' ->
            update KeyOk model

        CharacterPressed ' ' ->
            update KeyOk model

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
            in
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
                        let
                            _ =
                                Debug.log "err" err
                        in
                            ( { model | error = Just [ title ] }, Cmd.none )

        ReadVendingDone (Ok sa) ->
            ( { model | vending = Just sa }, Cmd.none )


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


startProcess =
    websocketOut <|
        cmdTest


cmdTest =
    Encode.object
        [ ( "cmd", Encode.string "test" )
        , ( "token", Encode.string "TBD" )
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.error of
        Nothing ->
            case model.vending of
                Nothing ->
                    div [] [ Html.text "Конфигурация еще не загружена" ]

                Just vending ->
                    div [] <|
                        [ UI.header vending.logo vending.header
                        , UI.footer vending.footer1 vending.footer2
                        ]
                            ++ viewPage model

        Just error ->
            div [ HA.class "error" ] ((error ++ [ model.id ]) |> List.map (\s -> div [ HA.class "selector" ] [ Html.text s ]))


viewPage model =
    case model.activePage of
        Products ->
            [ UI.KeyHelper.title ( KeyLeft, KeyRight, KeyOk ) ]
                ++ Page.Products.view model.images model.activeProduct

        Order ->
            Page.Order.view
                (products |> getAt model.activeProduct |> withDefault unknowproduct)
                model.activePayMethod
                ( ( SelectPayMethod API.PayMethod1, SelectPayMethod API.PayMethod2, SelectPayMethod API.PayMethod3 ), ( KeyLeft, KeyRight, KeyOk ) )

        OrderIngenica ->
            Page.Order.viewIngenica (products |> getAt model.activeProduct |> withDefault unknowproduct)

        OrderPrivat ->
            Page.Order.viewPrivat (products |> getAt model.activeProduct |> withDefault unknowproduct)

        OrderFondi ->
            Page.Order.viewFondi (products |> getAt model.activeProduct |> withDefault unknowproduct)

        OrderConfirm ->
            Page.OrderConfirm.view ( KeyLeft, KeyOk )

        CookAsk1 ->
            Page.Cook.viewAsk1 (products |> getAt model.activeProduct |> withDefault unknowproduct) ( KeyLeft, KeyOk )

        CookAsk2 ->
            Page.Cook.viewAsk2 (products |> getAt model.activeProduct |> withDefault unknowproduct) ( KeyLeft, KeyOk )

        Cooking ->
            Page.Cook.viewCooking model.cookTimer (products |> getAt model.activeProduct |> withDefault unknowproduct)

        CookingDone ->
            Page.Cook.viewCookingDone (products |> getAt model.activeProduct |> withDefault unknowproduct)



-- , ul [ class "main_menu" ] <|
--     viewProducts model.activeProduct produsts
-- , viewActiveProduct model.activeProduct produsts
-- , text <| MD5.hex "Hello World"
-- , video [ src "sony.mp4", controls True, width 400, height 300 ] []


viewProduct : Int -> Int -> Product -> Html Msg
viewProduct active index ({ image_src } as product) =
    if index == active then
        (li [ class "active" ] [ img [ src image_src ] [] ])
    else
        (li [] [ img [ src image_src ] [] ])


viewProducts : Int -> List Product -> List (Html Msg)
viewProducts active products =
    products
        |> List.indexedMap (viewProduct active)


viewActiveProduct : Int -> List Product -> Html Msg
viewActiveProduct selected products =
    case products |> getAt selected of
        Nothing ->
            div [] [ text "Ошибка" ]

        Just { title, image_src, description } ->
            div [ class "main_widget" ]
                [ div [] [ img [ src image_src ] [] ]
                , div []
                    [ h4 [] [ text title ]
                    , ul [] <| viewDescriptions description
                    ]
                ]


viewDescriptions : List ( String, String ) -> List (Html Msg)
viewDescriptions description =
    description
        |> List.map
            (\( n, v ) ->
                li []
                    [ span [] [ text n ]
                    , span [] [ text " : " ]
                    , span [] [ text v ]
                    ]
            )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
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


api_url : String
api_url =
    -- "ws://localhost:8001"
    "ws://localhost:8081/ws"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown keyDecoder
        , websocketOpened WebsocketOpened
        , websocketIn WebsocketIn
        , Time.every 1000 Tick
        , readFileDone (\c -> ReadFileDone (Decode.decodeValue readFileDecoder c))
        ]


type alias ReadFile =
    { name : String
    , data : String
    }


readFileDecoder : Decode.Decoder ReadFile
readFileDecoder =
    Decode.map2 ReadFile
        (Decode.field "name" Decode.string)
        (Decode.field "data" Decode.string)


port websocketOpen : String -> Cmd msg


port websocketOpened : (Bool -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Encode.Value -> Cmd msg


port readFile : String -> Cmd msg


port readFileDone : (Encode.Value -> msg) -> Sub msg

port module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, text, div, h1, h4, img, ul, li, video, a, input, label, span)
import Html.Attributes as HA exposing (src, class, controls, width, height, href, type_, name, checked, id)
import Json.Decode as Decode
import List.Extra exposing (getAt)
import MD5
import Json.Encode as Encode
import API
import UI
import UI.KeyHelper
import Page.Products
import Page.Order


---- MODEL ----


type Page
    = Products
    | Order
    | OrderIngenica
    | OrderPrivat
    | OrderFondi


type alias Model =
    { activeProduct : Int
    , connectionState : ConnectionState
    , activePage : Page
    , activePayMethod : API.PayMethod
    }


type ConnectionState
    = NotConnected
    | Connected


init : ( Model, Cmd Msg )
init =
    ( { activeProduct = 0
      , connectionState = NotConnected
      , activePage = Products
      , activePayMethod = API.PayMethod1
      }
    , Cmd.batch
        [ websocketOpen api_url
        ]
    )



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

        KeyLeft ->
            case model.activePage of
                Products ->
                    if activeProduct <= 0 then
                        ( { model | activeProduct = 5 }, Cmd.none )
                    else
                        ( { model | activeProduct = model.activeProduct - 1 }, Cmd.none )

                Order ->
                    ( { model | activePayMethod = prevPayMethod model.activePayMethod }, Cmd.none )

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
                    ( { model | activePage = Products }, Cmd.none )

                OrderPrivat ->
                    ( { model | activePage = Products }, Cmd.none )

                OrderFondi ->
                    ( { model | activePage = Products }, Cmd.none )

        CharacterPressed 'd' ->
            update KeyRight model

        CharacterPressed 'a' ->
            update KeyLeft model

        CharacterPressed 's' ->
            update KeyOk model

        CharacterPressed k ->
            ( model, Cmd.none )

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

                    Just (API.Error _) ->
                        ( model, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        OpenWebsocket url ->
            ( model, websocketOpen url )


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
    div [] <|
        [ UI.header
        , UI.footer
        ]
            ++ viewPage model


viewPage model =
    case model.activePage of
        Products ->
            [ UI.KeyHelper.title ( KeyLeft, KeyRight, KeyOk ) ]
                ++ Page.Products.view model.activeProduct

        Order ->
            Page.Order.view model.activeProduct model.activePayMethod

        OrderIngenica ->
            Page.Order.viewIngenica model.activeProduct

        OrderPrivat ->
            Page.Order.viewPrivat model.activeProduct

        OrderFondi ->
            Page.Order.viewFondi model.activeProduct



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
    "ws://localhost:8001"


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown keyDecoder
        , websocketOpened WebsocketOpened
        , websocketIn WebsocketIn
        ]


port websocketOpen : String -> Cmd msg


port websocketOpened : (Bool -> msg) -> Sub msg


port websocketIn : (String -> msg) -> Sub msg


port websocketOut : Encode.Value -> Cmd msg

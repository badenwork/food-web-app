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


type alias Model =
    { activeProduct : Int
    , connectionState : ConnectionState
    , activePage : Page
    }


type ConnectionState
    = NotConnected
    | Connected


init : ( Model, Cmd Msg )
init =
    ( { activeProduct = 0
      , connectionState = NotConnected
      , activePage = Products
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

        CharacterPressed 'd' ->
            if activeProduct >= 5 then
                ( { model | activeProduct = 0 }, Cmd.none )
            else
                ( { model | activeProduct = model.activeProduct + 1 }, Cmd.none )

        CharacterPressed 'a' ->
            if activeProduct <= 0 then
                ( { model | activeProduct = 5 }, Cmd.none )
            else
                ( { model | activeProduct = model.activeProduct - 1 }, Cmd.none )

        CharacterPressed 's' ->
            case model.activePage of
                Products ->
                    ( { model | activePage = Order }, Cmd.none )

                Order ->
                    ( { model | activePage = Products }, Cmd.batch [ startProcess ] )

        CharacterPressed k ->
            -- let
            --     _ =
            --         Debug.log "press" k
            -- in
            ( model, Cmd.none )

        KeyLeft ->
            update (CharacterPressed 'a') model

        WebsocketOpened False ->
            ( { model | connectionState = NotConnected }, Cmd.none )

        WebsocketOpened True ->
            -- let
            --     authCmd =
            --         -- case model.token of
            --         --     Nothing ->
            --         --         Cmd.none
            --         --
            --         --     Just token ->
            --         websocketOut <| Encode.string "T"
            -- in
            ( { model | connectionState = Connected }
            , Cmd.none
              -- , Cmd.batch [ authCmd ]
            )

        WebsocketIn message ->
            let
                res =
                    API.parsePayload message
            in
                case res of
                    Just (API.Key API.Key1) ->
                        if activeProduct <= 0 then
                            ( { model | activeProduct = 5 }, Cmd.none )
                        else
                            ( { model | activeProduct = model.activeProduct - 1 }, Cmd.none )

                    Just (API.Key API.Key2) ->
                        ( model, Cmd.none )

                    Just (API.Key API.Key3) ->
                        if activeProduct >= 5 then
                            ( { model | activeProduct = 0 }, Cmd.none )
                        else
                            ( { model | activeProduct = model.activeProduct + 1 }, Cmd.none )

                    Just (API.Key API.KeyUnknown) ->
                        ( model, Cmd.none )

                    Just (API.Error _) ->
                        ( model, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        OpenWebsocket url ->
            ( model, websocketOpen url )


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
            [ UI.KeyHelper.title KeyLeft ]
                ++ Page.Products.view model.activeProduct

        Order ->
            Page.Order.view model.activeProduct



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

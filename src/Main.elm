module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, text, div, h1, img, ul, li, video, a)
import Html.Attributes exposing (src, class, controls, width, height, href)
import Json.Decode as Decode


---- MODEL ----


type alias Model =
    { activeProduct : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { activeProduct = 0
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | CharacterPressed Char


type alias Product =
    { title : String
    , description : List ( String, String )
    }


product01 : Product
product01 =
    Product
        "Каша гречневая в стаканчике с говядиной и овощами, 60"
        [ ( "Пол", "детям, женщинам" )
        , ( "Бренд", "Новоукраїнка" )
        , ( "Тип", "хлопья" )
        , ( "Вид крупы", "гречневая" )
        , ( "Свойства", "без гмо" )
        ]


produsts : List Product
produsts =
    [ product01, product01, product01, product01, product01, product01 ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CharacterPressed 'd' ->
            ( { model | activeProduct = model.activeProduct + 1 }, Cmd.none )

        CharacterPressed 'a' ->
            ( { model | activeProduct = model.activeProduct - 1 }, Cmd.none )

        CharacterPressed k ->
            -- let
            --     _ =
            --         Debug.log "press" k
            -- in
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ a [ href "." ] [ text "Едаааааа!" ] ]
        , ul [ class "main_menu" ] <|
            viewProducts model.activeProduct produsts
        , video [ src "sony.mp4", controls True, width 400, height 300 ] []
        ]


viewProduct : Int -> Int -> Product -> Html Msg
viewProduct active index product =
    if index == active then
        (li [ class "active" ] [ img [ src "/product01.jpg" ] [] ])
    else
        (li [] [ img [ src "/product01.jpg" ] [] ])


viewProducts : Int -> List Product -> List (Html Msg)
viewProducts active products =
    products
        |> List.indexedMap (viewProduct active)



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
    case String.uncons string of
        Just ( char, "" ) ->
            CharacterPressed char

        _ ->
            NoOp


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown keyDecoder
        ]

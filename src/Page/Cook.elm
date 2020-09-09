module Page.Cook exposing (..)

import Html exposing (Html, div, text, img, span, p)
import Html.Attributes exposing (class, src, alt, style)
import Html.Events exposing (onClick)
import API
import UI.KeyHelper exposing (key_left, key_ok)


viewAsk1 : List (Html msg)
viewAsk1 =
    [ div [ class "cook_frame" ]
        [ img [ class "vending", src "img/cook/vending.png" ] []
        , img [ class "arrow", src "img/cook/arrow.png" ] []
        , img [ class "product", src "img/grechka.png" ] []
        , div [ class "ua" ] [ text "Помістіть стаканчик у відсік для приготування" ]
        , div [ class "en" ] [ text "If you want us to cook for you, put it in the cooking compartment" ]
        , key_left "key_1" "Відміна приготування" "Cancel cooking"
        , key_ok "key_2" "Помістив!" "Placed!"
        ]
    ]


viewAsk2 : List (Html msg)
viewAsk2 =
    [ div [ class "cook_frame2" ]
        [ img [ class "product dry", src "img/grechka.png" ] []
        ]
    , div [ class "cook_frame3" ]
        [ div [ class "ua" ] [ span [] [ text "У відсіку для приготування:" ], span [] [ text "Сочевичний суп пюре" ] ]
        , div [ class "en" ] [ span [] [ text "In the cooking compartment:" ], span [] [ text "Lentil puree soup" ] ]
        ]
    , div [ class "cook_ask2_keys" ]
        [ key_left "key_1" "Відміна приготування" "Cancel cooking"
        , key_ok "key_2" "Приготувати!" "Cooking!"
        ]
    ]


viewCooking : Int -> List (Html msg)
viewCooking cookTimer =
    let
        fill =
            (773 - 250) * cookTimer // 30 |> String.fromInt
    in
        [ div [ class "cook_frame2" ] [ img [ class "product", src "img/grechka.png" ] [] ]
        , div [ class "filtered", style "height" (fill ++ "px") ] [ img [ class "product", src "img/grechka.png" ] [] ]
        , div [ class "cook_frame3" ]
            [ div [ class "ua" ] [ span [] [ text "У відсіку для приготування:" ], span [] [ text "Сочевичний суп пюре" ] ]
            , div [ class "en" ] [ span [] [ text "In the cooking compartment:" ], span [] [ text "Lentil puree soup" ] ]
            , div [ class "cook_timer" ]
                [ div [ class "ua" ] [ text "Готуемо" ]
                , div [ class "en" ] [ text "Cooking" ]
                , div [ class "counter" ] [ text <| (String.fromInt cookTimer) ++ " c" ]
                ]
            ]
        ]


viewCookingDone : List (Html msg)
viewCookingDone =
    [ div [ class "cook_frame2" ] [ img [ class "product", src "img/grechka.png" ] [] ]
    , div [ class "cook_frame3" ]
        [ div [ class "done_ua" ]
            [ p [] [ text "Страва готова!" ]
            , p [] [ text "Заберіть стакан з відсіку готування." ]
            , p [] [ text "Обережно гаряче!" ]
            , p [] [ text "Смачного!" ]
            ]
        , div [ class "done_en" ]
            [ p [] [ text "The dish is ready" ]
            , p [] [ text "Bon appetit!" ]
            ]
        ]
    ]

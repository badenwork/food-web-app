module Page.Cook exposing (..)

import Html exposing (Html, div, text, img, span, p)
import Html.Attributes exposing (class, src, alt, style)
import Html.Events exposing (onClick)
import API
import UI.KeyHelper exposing (key_left, key_ok)
import API.Products exposing (Product)


viewAsk1 : Product -> ( msg, msg ) -> List (Html msg)
viewAsk1 p ( k1, k2 ) =
    [ div [ class "cook_frame" ]
        [ img [ class "vending", src "img/cook/vending.png" ] []
        , img [ class "arrow", src "img/cook/arrow.png" ] []
        , img [ class "product", src p.image ] []
        , div [ class "ua" ] [ text "Помістіть стаканчик у відсік для приготування" ]
        , div [ class "en" ] [ text "If you want us to cook for you, put it in the cooking compartment" ]
        , key_left "key_1" "Відміна приготування" "Cancel cooking" k1
        , key_ok "key_2" "Помістив!" "Placed!" k2
        ]
    ]


viewAsk2 : Product -> ( msg, msg ) -> List (Html msg)
viewAsk2 p ( k1, k2 ) =
    [ div [ class "cook_frame2" ]
        [ img [ class "product dry", src p.image ] []
        ]
    , div [ class "cook_frame3" ]
        [ div [ class "ua" ] [ span [] [ text "У відсіку для приготування:" ], span [] [ text p.titleUA ] ]
        , div [ class "en" ] [ span [] [ text "In the cooking compartment:" ], span [] [ text p.titleEN ] ]
        ]
    , div [ class "cook_ask2_keys" ]
        [ key_left "key_1" "Відміна приготування" "Cancel cooking" k1
        , key_ok "key_2" "Приготувати!" "Cooking!" k2
        ]
    ]


viewCooking : Int -> Product -> List (Html msg)
viewCooking cookTimer p =
    let
        fill =
            (773 - 250) * cookTimer // 20 |> String.fromInt
    in
        [ div [ class "cook_frame2" ] [ img [ class "product", src p.image ] [] ]
        , div [ class "filtered", style "height" (fill ++ "px") ] [ img [ class "product", src p.image ] [] ]
        , div [ class "cook_frame3" ]
            [ div [ class "ua" ] [ span [] [ text "У відсіку для приготування:" ], span [] [ text p.titleUA ] ]
            , div [ class "en" ] [ span [] [ text "In the cooking compartment:" ], span [] [ text p.titleEN ] ]
            , div [ class "cook_timer" ]
                [ div [ class "ua" ] [ text "Готуемо" ]
                , div [ class "en" ] [ text "Cooking" ]
                , div [ class "counter" ] [ text <| (String.fromInt cookTimer) ++ " c" ]
                ]
            ]
        ]


viewCookingDone : Product -> List (Html msg)
viewCookingDone product =
    [ div [ class "cook_frame2" ] [ img [ class "product", src product.image ] [] ]
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

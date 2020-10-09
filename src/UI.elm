module UI exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt)
import API.Media exposing (imgUrl)


header : String -> String -> Html msg
header logo header_ =
    div []
        [ div [ class "header1" ] [ img [ src <| imgUrl logo, alt "INFINITY FOODS" ] [] ]
        , div [ class "header2" ] [ text header_ ]
        ]


footer : String -> String -> Html msg
footer footer1 footer2 =
    div []
        [ div [ class "footer11" ] [ text footer1 ]
        , div [ class "footer12" ] [ text footer2 ]
        ]

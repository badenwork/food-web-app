module UI exposing (..)

import API.Media exposing (imgUrl)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (alt, class, src)


header : String -> String -> Html msg
header logo header_ =
    div []
        [ div [ class "header1" ] [ img [ src <| imgUrl logo, alt "INFINITY FOODS" ] [] ]
        , div [ class "header2" ] [ text header_ ]
        ]


footer : String -> String -> String -> Html msg
footer footer1 footer2 id_ =
    div []
        [ div [ class "footer11" ] [ text footer1, text " [", text id_, text "]" ]
        , div [ class "footer12" ] [ text footer2 ]
        ]

module DebugFrame exposing (..)

import Html exposing (Html)
import Html.Attributes as HA
import Html.Events exposing (onClick)
import Types exposing (..)


viewDebug : Model -> Msg -> Html Msg
viewDebug { debugEvents, showDebugEvents } msg =
    let
        ev t =
            Html.li [] [ Html.text t ]

        lis =
            debugEvents |> List.map ev
    in
    Html.div
        [ HA.class <|
            "debug"
                ++ (if showDebugEvents then
                        ""

                    else
                        " hidden"
                   )
        , onClick msg
        ]
        [ Html.ul [] lis ]


pushMsg : String -> List String -> List String
pushMsg =
    (::)

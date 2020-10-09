module Page.Products exposing (..)

import Html exposing (Html, div, text, img)
import Html.Attributes exposing (class, src, alt, style)
import List.Extra exposing (getAt)
import Maybe exposing (withDefault)
import API.Products exposing (FakeProduct)
import API.Media exposing (imgUrl)
import Json.Encode as Encode
import Dict exposing (Dict)


-- view : Dict String String -> List Product -> Int -> List (Html msg)


view : Dict String String -> List FakeProduct -> FakeProduct -> Int -> List (Html msg)
view images products p selected_index =
    [ div [ class "product_selector" ]
        [ div [ class "product_headerUA" ] [ text p.titleUA ]
        , div [ class "product_headerEN" ] [ text p.titleEN ]
        , div [ class "product_price" ] [ text <| p.price ++ " грн" ]

        -- , div [ class "product_descriptionUA" ] <| (p.descriptionUA |> List.map viewDescriptions)
        -- , div [ class "product_descriptionEN" ] <| (p.descriptionEN |> List.map viewDescriptions)
        , div [ class "product_descriptionUA" ] <| viewFakeDescriptions <| p.descriptionUA
        , div [ class "product_descriptionEN" ] <| viewFakeDescriptions <| p.descriptionEN
        ]
    , div [ class "product_image_row", style "left" (offsetInPixels selected_index) ]
        (products |> List.indexedMap (viewImage selected_index))
    ]


viewFakeDescriptions : String -> List (Html msg)
viewFakeDescriptions desc =
    desc
        |> String.lines
        |> List.map String.trim
        |> List.filter (\a -> a /= "")
        |> List.map viewFakeDescriptionsLine


viewFakeDescriptionsLine : String -> Html msg
viewFakeDescriptionsLine dl =
    if String.startsWith "#" dl then
        dl |> String.dropLeft 1 |> String.trimLeft |> viewFakeDescriptionsLineTitle
    else
        dl |> String.split ":" |> List.map String.trim |> viewFakeDescriptionsLineData dl


viewFakeDescriptionsLineTitle : String -> Html msg
viewFakeDescriptionsLineTitle l =
    Html.h1 [] [ text l ]


viewFakeDescriptionsLineData orig ll =
    case ll of
        [] ->
            Html.p [] [ div [ class "desc_t1" ] [ text "?" ], div [ class "desc_t2" ] [ text "?" ] ]

        [ t1, t2 ] ->
            Html.p [] [ div [ class "desc_t1" ] [ text t1 ], div [ class "desc_t2" ] [ text t2 ] ]

        _ ->
            Html.p [] [ text orig ]


scale =
    326


offsetInPixels : Int -> String
offsetInPixels o =
    -- ((760 - o * 380) |> String.fromInt) ++ "px"
    ((scale * 2 - o * scale - 2) |> String.fromInt) ++ "px"


viewImage : Int -> Int -> FakeProduct -> Html msg
viewImage active index { image } =
    if index == active then
        img [ class "active", src <| imgUrl image ] []
    else
        img [ src <| imgUrl image ] []

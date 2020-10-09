module API.Products exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Url
import API


type alias ProductId =
    String


decodeProductId : Decode.Decoder ProductId
decodeProductId =
    Decode.string


type alias Product =
    { id : ProductId
    , titleUA : String
    , titleEN : String
    , image : String
    , descriptionUA : List ProdDescr
    , descriptionEN : List ProdDescr
    }


type alias FakeProduct =
    { id : ProductId
    , titleUA : String
    , titleEN : String
    , image : String
    , descriptionUA : String
    , descriptionEN : String
    }


unknowFakeProduct : FakeProduct
unknowFakeProduct =
    FakeProduct "product_fake" "От халепа!" "Oops!" "img/ovsanka.png" "no_desc" "no_desc"


decodeProduct : Decode.Decoder FakeProduct
decodeProduct =
    Decode.succeed FakeProduct
        |> required "id" decodeProductId
        |> required "titleUA" Decode.string
        |> required "titleEN" Decode.string
        -- |> required "files" (Decode.list Decode.string)
        |> required "image" Decode.string
        |> required "descriptionUA" Decode.string
        |> required "descriptionEN" Decode.string


type alias ProdDescr =
    { title : String

    -- , width : Int
    , content : List ProcDescrContent
    }


type alias ProcDescrContent =
    { t1 : String
    , t2 : String
    }


url : ProductId -> String
url pid =
    API.url ++ "/db/product/" ++ (Url.percentEncode pid)


products : List Product
products =
    [ product1
    , product2
    , product3
    , product4
    , product5
    , product6
    ]


product1 : Product
product1 =
    Product
        "product_01"
        "Сочевичний суп пюре"
        "Lentil puree soup"
        "img/sochevitsa.png"
        [ ProdDescr "Склад:"
            [ ProcDescrContent "83%" "сочевиця"
            , ProcDescrContent "8%" "грінки хлібні"
            , ProcDescrContent "4%" "морква, цибуля"
            , ProcDescrContent "3%" "суміш перців"
            , ProcDescrContent "1%" "зелень та сіль"
            ]
        , ProdDescr "Енергетична цінність на 100г продукту:"
            [ ProcDescrContent "316.11 ккал" "1322.1 кДж"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Білки" "22.51 г"
            , ProcDescrContent "Жири" "2.40 г"
            , ProcDescrContent "Вуглеводи" "54.10 г"
            , ProcDescrContent "Волокно" "9.81 г"
            , ProcDescrContent "Сіль" "3 г"
            ]
        ]
        [ ProdDescr "Composition:"
            [ ProcDescrContent "83%" "lentil"
            , ProcDescrContent "8%" "bread croutons"
            , ProcDescrContent "4%" "carrots, onions"
            , ProcDescrContent "3%" "mixture of peppers"
            , ProcDescrContent "1%" "herbs and salt"
            ]
        , ProdDescr "Energy value per 100 g of product:"
            [ ProcDescrContent "316.11 Kcal" "1322.1 kJ"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Proteins" "22.51 g"
            , ProcDescrContent "Fats" "2.40 g"
            , ProcDescrContent "Carbohydrates" "54.10 g"
            , ProcDescrContent "Fiber" "9.81 g"
            , ProcDescrContent "Salt" "3 g"
            ]
        ]


product2 : Product
product2 =
    Product
        "product_02"
        "Гороховий суп з куркою"
        "Pea soup with chicken"
        "img/goroh.png"
        [ ProdDescr "Склад:"
            [ ProcDescrContent "83%" "горох"
            , ProcDescrContent "8%" "філе куряче"
            , ProcDescrContent "4%" "морква, цибуля"
            , ProcDescrContent "3%" "суміш перців"
            , ProcDescrContent "1%" "зелень та сіль"
            ]
        , ProdDescr "Енергетична цінність на 100г продукту:"
            [ ProcDescrContent "346.09 ккал" "1448.0 кДж"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Білки" "21.61 г"
            , ProcDescrContent "Жири" "4.59 г"
            , ProcDescrContent "Вуглеводи" "44.98 г"
            , ProcDescrContent "Волокно" "0.25 г"
            , ProcDescrContent "Сіль" "1.16 г"
            ]
        ]
        [ ProdDescr "Composition:"
            [ ProcDescrContent "83%" "peas"
            , ProcDescrContent "8%" "chicken fillet"
            , ProcDescrContent "4%" "carrots, onions"
            , ProcDescrContent "3%" "mixture of peppers"
            , ProcDescrContent "1%" "herbs and salt"
            ]
        , ProdDescr "Energy value per 100 g of product:"
            [ ProcDescrContent "346.09 Kcal" "1448.0 kJ"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Proteins" "21.61 g"
            , ProcDescrContent "Fats" "4.59 g"
            , ProcDescrContent "Carbohydrates" "44.98 g"
            , ProcDescrContent "Fiber" "0.25 g"
            , ProcDescrContent "Salt" "1.16 g"
            ]
        ]


product3 : Product
product3 =
    Product
        "product_03"
        "Картопляне пюре з грибами"
        "Mashed potatoes with mushrooms"
        "img/pure.png"
        [ ProdDescr "Склад:"
            [ ProcDescrContent "87%" "картопля"
            , ProcDescrContent "6%" "морква, цибуля"
            , ProcDescrContent "3%" "печериці"
            , ProcDescrContent "3%" "молоко"
            , ProcDescrContent "1%" "зелень та сіль"
            ]
        , ProdDescr "Енергетична цінність на 100г продукту:"
            [ ProcDescrContent "359.61 ккал" "1504.6 кДж"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Білки" "7.74 г"
            , ProcDescrContent "Жири" "2.46 г"
            , ProcDescrContent "Вуглеводи" "74.78 г"
            , ProcDescrContent "Волокно" "5.66 г"
            , ProcDescrContent "Сіль" "1 г"
            ]
        ]
        [ ProdDescr "Composition:"
            [ ProcDescrContent "87%" "potatoes"
            , ProcDescrContent "6%" "carrots, onions"
            , ProcDescrContent "3%" "mushrooms"
            , ProcDescrContent "3%" "milk"
            , ProcDescrContent "1%" "herbs and salt"
            ]
        , ProdDescr "Energy value per 100 g of product:"
            [ ProcDescrContent "359.61 Kcal" "1504.6 kJ"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Proteins" "7.74 g"
            , ProcDescrContent "Fats" "2.46 g"
            , ProcDescrContent "Carbohydrates" "74.78 g"
            , ProcDescrContent "Fiber" "5.66 g"
            , ProcDescrContent "Salt" "1 g"
            ]
        ]


product4 : Product
product4 =
    Product
        "product_04"
        "Вівсянка з малиною"
        "Oatmeal with raspberries"
        "img/ovsanka.png"
        [ ProdDescr "Склад:"
            [ ProcDescrContent "71%" "вівсянка"
            , ProcDescrContent "8%" "молоко сухе"
            , ProcDescrContent "6%" "шоколад білий"
            , ProcDescrContent "4%" "шматочки малини"
            , ProcDescrContent "11%" "цукор"
            ]
        , ProdDescr "Енергетична цінність на 100г продукту:"
            [ ProcDescrContent "335.32 ккал" "1402.9 кДж"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Білки" "11.59 г"
            , ProcDescrContent "Жири" "4.60 г"
            , ProcDescrContent "Вуглеводи" "61.43 г"
            , ProcDescrContent "Волокно" "2.20 г"
            , ProcDescrContent "Сіль" "0.29 г"
            ]
        ]
        [ ProdDescr "Composition:"
            [ ProcDescrContent "71%" "oatmeal"
            , ProcDescrContent "8%" "milk powder"
            , ProcDescrContent "6%" "white chocolate"
            , ProcDescrContent "4%" "slices of raspberry"
            , ProcDescrContent "11%" "sugar"
            ]
        , ProdDescr "Energy value per 100 g of product:"
            [ ProcDescrContent "335.32 Kcal" "1402.9 kJ"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Proteins" "11.59 g"
            , ProcDescrContent "Fats" "4.60 g"
            , ProcDescrContent "Carbohydrates" "61.43 g"
            , ProcDescrContent "Fiber" "2.20 g"
            , ProcDescrContent "Salt" "0.29 g"
            ]
        ]


product5 : Product
product5 =
    Product
        "product_05"
        "Кус-кус дієтичний з овочами"
        "Couscous dietary with vegetables"
        "img/kuskus.png"
        [ ProdDescr "Склад:"
            [ ProcDescrContent "89%" "кус-кус"
            , ProcDescrContent "10%" "овочева суміш"
            , ProcDescrContent "" "(кукурудза, квасоля,"
            , ProcDescrContent "" "солодкий перець,"
            , ProcDescrContent "" "горох, морква)"
            , ProcDescrContent "1%" "спеції та сіль"
            ]
        , ProdDescr "Енергетична цінність на 100г продукту:"
            [ ProcDescrContent "174.63 ккал" "731.14 кДж"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Білки" "7.74 г"
            , ProcDescrContent "Жири" "2.46 г"
            , ProcDescrContent "Вуглеводи" "32.61 г"
            , ProcDescrContent "Волокно" "1.24 г"
            , ProcDescrContent "Сіль" "1 г"
            ]
        ]
        [ ProdDescr "Composition:"
            [ ProcDescrContent "89%" "couscous"
            , ProcDescrContent "10%" "vegetable mixture"
            , ProcDescrContent "" "(corn, beans,"
            , ProcDescrContent "" "sweet peppers,"
            , ProcDescrContent "" "peas, carrots)"
            , ProcDescrContent "1%" "spices and salt"
            ]
        , ProdDescr "Energy value per 100 g of product:"
            [ ProcDescrContent "174.63 Kcal" "731.14 kJ"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Proteins" "7.74 g"
            , ProcDescrContent "Fats" "2.46 g"
            , ProcDescrContent "Carbohydrates" "32.61 g"
            , ProcDescrContent "Fiber" "1.24 g"
            , ProcDescrContent "Salt" "1 g"
            ]
        ]


product6 : Product
product6 =
    Product
        "product_06"
        "Каша гречана з м’ясом"
        "Buckwheat porridge with meat"
        "img/grechka.png"
        [ ProdDescr "Склад:"
            [ ProcDescrContent "88%" "гречка"
            , ProcDescrContent "10%" "філе куряче"
            , ProcDescrContent "2%" "зелень та сіль"
            ]
        , ProdDescr "Енергетична цінність на 100г продукту:"
            [ ProcDescrContent "343.01 ккал" "1435.1 кДж"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Білки" "15.65 г"
            , ProcDescrContent "Жири" "4.52 г"
            , ProcDescrContent "Вуглеводи" "59.21 г"
            , ProcDescrContent "Волокно" "0.08 г"
            , ProcDescrContent "Сіль" "3 г"
            ]
        ]
        [ ProdDescr "Composition:"
            [ ProcDescrContent "88%" "buckwheat"
            , ProcDescrContent "10%" "chicken fillet"
            , ProcDescrContent "2%" "herbs and salt"
            ]
        , ProdDescr "Energy value per 100 g of product:"
            [ ProcDescrContent "343.01 Kcal" "1435.1 kJ"
            ]
        , ProdDescr ""
            [ ProcDescrContent "Proteins" "15.56 g"
            , ProcDescrContent "Fats" "4.52 g"
            , ProcDescrContent "Carbohydrates" "59.21 g"
            , ProcDescrContent "Fiber" "0.08 g"
            , ProcDescrContent "Salt" "3 g"
            ]
        ]


unknowproduct : Product
unknowproduct =
    Product "product_fake" "От халепа!" "Oops!" "img/ovsanka.png" product1_descriptions product1_descriptions


product1_descriptions : List ProdDescr
product1_descriptions =
    [ ProdDescr "Склад"
        [ ProcDescrContent "83%" "сочевиця"
        , ProcDescrContent "8%" "грінки хлібні"
        , ProcDescrContent "4%" "морква, цибуля"
        , ProcDescrContent "3%" "суміш перців"
        , ProcDescrContent "1%" "зелень та сіль"
        ]
    , ProdDescr "Енергетична цінність на 100г продукту:"
        [ ProcDescrContent "1448.0 ккал" "346.09 кДж"
        ]
    , ProdDescr ""
        [ ProcDescrContent "Білки" "21.61 г"
        , ProcDescrContent "Жири" "4.59 г"
        , ProcDescrContent "Вуглеводи" "44.98 г"
        , ProcDescrContent "Волокно" "0.25 г"
        , ProcDescrContent "Сіль" "1.16 г"
        ]
    ]


product2_descriptions : List ProdDescr
product2_descriptions =
    [ ProdDescr "Склад"
        [ ProcDescrContent "90%" "картофан"
        , ProcDescrContent "8%" "мастило"
        , ProcDescrContent "4%" "морква, цибуля"
        , ProcDescrContent "3%" "суміш перців"
        , ProcDescrContent "1%" "зелень та сіль"
        ]
    , ProdDescr "Енергетична цінність на 100г продукту:"
        [ ProcDescrContent "1448.0 ккал" "346.09 кДж"
        ]
    , ProdDescr ""
        [ ProcDescrContent "Білки" "41.61 г"
        , ProcDescrContent "Жири" "14.59 г"
        , ProcDescrContent "Вуглеводи" "4.98 г"
        , ProcDescrContent "Волокно" "1.25 г"
        , ProcDescrContent "Сіль" "0.16 г"
        ]
    ]

module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Random


main : Program Never Model Msg
main =
    Html.program
        { init = createModel
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- TYPES


type alias Card =
    { id : String
    , group : Group
    , flipped : Bool
    }


type Group
    = A
    | B


type alias Deck =
    List Card


type Model
    = Playing Deck


type Msg
    = NoOp
    | Shuffle (List Int)
    | Flip Card



-- MODEL


cards : List String
cards =
    [ "dinosaur"
    , "8-ball"
    , "baked-potato"
    , "kronos"
    , "rocket"
    , "skinny-unicorn"
    , "that-guy"
    , "zeppelin"
    ]


createModel : ( Model, Cmd Msg )
createModel =
    let
        model =
            Playing deck

        cmd =
            randomList Shuffle (List.length deck)
    in
        ( model, cmd )


initCard : Group -> String -> Card
initCard group name =
    { id = name
    , group = group
    , flipped = False
    }


deck : Deck
deck =
    let
        groupA =
            List.map (initCard A) cards

        groupB =
            List.map (initCard B) cards
    in
        List.concat [ groupA, groupB ]



-- UPDATE


randomList : (List Int -> Msg) -> Int -> Cmd Msg
randomList msg len =
    Random.int 0 100
        |> Random.list len
        |> Random.generate msg


shuffleDeck : Deck -> List comparable -> Deck
shuffleDeck deck xs =
    List.map2 (,) deck xs
        |> List.sortBy Tuple.second
        |> List.unzip
        |> Tuple.first


flip : Bool -> Card -> Card -> Card
flip isFlipped a b =
    if (a.id == b.id) && (a.group == b.group) then
        { b | flipped = isFlipped }
    else
        b


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Shuffle xs ->
            let
                newDeck =
                    shuffleDeck deck xs
            in
                Playing newDeck ! []

        Flip card ->
            case model of
                Playing deck ->
                    let
                        newDeck =
                            List.map (flip True card) deck
                    in
                        Playing newDeck ! []



-- VIEW


cardClass : Card -> String
cardClass card =
    "card-" ++ card.id


createCard : Card -> Html Msg
createCard card =
    div [ class "container" ]
        [ div [ classList [ ( "card", True ), ( "flipped", card.flipped ) ], onClick (Flip card) ]
            [ div [ class "card-back" ] []
            , div [ class ("front " ++ cardClass card) ] []
            ]
        ]


view : Model -> Html Msg
view model =
    case model of
        Playing deck ->
            div [ class "wrapper" ] (List.map createCard deck)

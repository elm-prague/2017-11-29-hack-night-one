module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode


---- MODEL ----


type alias Model =
    { name : String
    , url : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { name = "Joe", url = Nothing }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | ChangeName String
    | StartNewGif
    | NewGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeName name ->
            ( { model | name = name }, Cmd.none )

        StartNewGif ->
            ( model, getRandomGif "hello" )

        NewGif response ->
            case response of
                Ok url ->
                    ( { model | url = Just url }, Cmd.none )

                Err error ->
                    ( { model | url = Nothing }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


changeNameButton : String -> Html Msg
changeNameButton name =
    Html.button [ onClick (ChangeName name) ] [ text ("Change name to " ++ name) ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Your Elm App is working!" ]
        , Html.div [] [ text ("Hello, " ++ model.name ++ "!") ]
        , Html.div []
            [ Html.input [ onInput ChangeName ] []
            ]
        , Html.div []
            (List.map changeNameButton [ "Joe", "Rachel", "World", "John" ])
        , Html.button [ onClick StartNewGif ] [ text "Start HTTP!" ]
        , Html.div []
            [ case model.url of
                Just url ->
                    Html.img [ src url ] []

                Nothing ->
                    text "Nothing"
            ]
        ]



-- Http


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
    in
    Http.send NewGif (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }

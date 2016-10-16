module TweetBar.View exposing (..)


import TweetBar.Types exposing (..)
import Generic.Utils exposing ( errorMessage )
import Generic.Animations
import Generic.Types exposing
    ( SubmissionData
        ( NotSent
        , Sending
        , Success
        , Failure
        )
    )

import Json.Decode
import Json.Decode.Pipeline
import String
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


root : Model -> Html Msg
root model =
    case model.submission of
        NotSent ->
            div [ class "TweetBar"]
                [ actionBar
                , inputBoxView model.tweetText
                ]

        Sending _ ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ Generic.Animations.twistingCircle ]
                ]

        Success _ ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ Generic.Animations.tick ]
                ]

        Failure error ->
            div [ class "TweetBar"]
                [ div
                    [ class "TweetBar-loading" ]
                    [ p [ class "loading-error" ]
                        [ text ( errorMessage error ) ]
                    , Generic.Animations.cross
                    ]
                ]



actionBar : Html Msg
actionBar =
    div [ class "TweetBar-actions" ]
        [ button
            [ class "zmdi zmdi-mail-send TweetBar-sendBtn btn btn-default btn-icon"
            , onClick SubmitTweet
            ] []
        , button
            [ class "zmdi zmdi-refresh-alt btn btn-default btn-icon"
            , onClick RefreshTweets
            ] []
        ]



inputBoxView : String -> Html Msg
inputBoxView tweetText =
    div [ class "TweetBar-textBox" ]
        [ span
              [ class "TweetBar-textBox-charCount" ]
              [ remainingCharacters tweetText ]
        , textarea
              [ class "TweetBar-textBox-input"
              , placeholder "Write you tweet here ..."
              , onInput LetterInput
              , onKeyDown submitOnCtrlEnter
              , value tweetText
              ] []
        ]



onKeyDown : (KeyDownEvent -> msg) -> Attribute msg
onKeyDown tagger =
  on "keydown" (Json.Decode.map tagger keyEventDecoder)


type alias KeyDownEvent =
    { keyCode : Int
    , ctrlKey : Bool
    }

keyEventDecoder : Json.Decode.Decoder KeyDownEvent
keyEventDecoder =
    Json.Decode.Pipeline.decode KeyDownEvent
        |> Json.Decode.Pipeline.required "keyCode" Json.Decode.int
        |> Json.Decode.Pipeline.required "ctrlKey" Json.Decode.bool



submitOnCtrlEnter : KeyDownEvent -> Msg
submitOnCtrlEnter  { keyCode, ctrlKey } =
    if keyCode == 13 && ctrlKey then
        SubmitTweet
    else
        DoNothing



remainingCharacters : String -> Html Msg
remainingCharacters tweetText =
    let
        remaining = 140 - ( String.length tweetText )
        remainingText =
            remaining
                |> toString
                |> text
    in
        if remaining >= 50 then
            span [ class "enough" ] [ remainingText ]

        else if remaining > 10 then
            span [ class "quite-a-few" ] [ remainingText ]

        else if remaining >= 0 then
            span [ class "few-left" ] [ remainingText ]

        else
            span [ class "too-much" ] [ remainingText ]
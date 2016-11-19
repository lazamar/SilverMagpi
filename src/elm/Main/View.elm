module Main.View exposing (..)

import Main.Types exposing
    ( Msg( TweetsMsg, TweetBarMsg, LoginMsg )
    , MainModel ( HomeRoute, LoginRoute)
    )
import Generic.Types exposing ( SubMsg ( SubMsgLocal ) )
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.App

import Routes.Timelines.Timeline.View
import Routes.Timelines.TweetBar.View
import Routes.Login.View


view : MainModel -> Html Msg
view modelRoute =
    case modelRoute of
        LoginRoute model ->
            Html.div [ class "Main"]
            [ Routes.Login.View.root model
                |> Html.App.map SubMsgLocal
                |> Html.App.map LoginMsg
            ]

        HomeRoute model ->
            Html.div [ class "Main"]
                [ Routes.Timelines.Timeline.View.root model.tweetsModel
                    |> Html.App.map TweetsMsg
                , Routes.Timelines.TweetBar.View.root model.tweetBarModel
                    |> Html.App.map TweetBarMsg
                ]

module Main.View exposing (..)

import Main.State exposing (credentialInUse)
import Main.Types exposing (..)
import Main.LoginView
import Twitter.Types exposing (Credential)
import Timelines.View
import Generic.Http
import Generic.Utils exposing (tooltip)
import List.Extra
import Html exposing (Html, div, button, text, span, img, a)
import Html.Attributes exposing (class, tabindex, src, href, target)
import Html.Events exposing (onClick)
import Twitter.Types exposing (Credential)
import Html


view : Model -> Html Msg
view model =
    case timelinesView model of
        Nothing ->
            Main.LoginView.root model

        Just aView ->
            div [ class "Main" ]
                [ aView
                , footerView
                    model.footerMessageNumber
                    (getSessionID model.sessionID)
                    model.usersDetails
                ]


timelinesView : Model -> Maybe (Html Msg)
timelinesView model =
    model.timelinesModel
        |> Maybe.map (\m -> Timelines.View.root m)
        |> Maybe.map (Html.map TimelinesMsg)


footerView : Int -> SessionID -> List UserDetails -> Html Msg
footerView footerMessageNumber sessionID usersDetails =
    div [ class "Main-footer" ]
        [ button
            [ class "zmdi zmdi-collection-item btn btn-default btn-icon"
            , tooltip "Detach window"
            , tabindex -1
            , onClick Detach
            ]
            []
          -- , span
          --     [ class "Timelines-footer-cues animated fadeInUp" ]
          --     [ text <| footerMessage footerMessageNumber ]
        , accountsView sessionID usersDetails
        ]


footerMessage : Int -> String
footerMessage seed =
    let
        messagesLength =
            List.length footerMessages

        msgNumber =
            seed % messagesLength
    in
        List.Extra.getAt msgNumber footerMessages
            |> Maybe.withDefault ""


footerMessages =
    [ "Press Tab to navigate the timeline using the arrow keys :)"
    , "You can open Silver Magpie with Ctrl+Alt+1"
    , "Use Ctrl+Enter to send your tweet"
    , "Use arrows to navigate handler suggestions"
    ]


accountsView : SessionID -> List UserDetails -> Html Msg
accountsView sessionID usersDetails =
    let
        avatarClass idx =
            if idx == 0 then
                "Main-footer-accounts-img--selected"
            else
                "Main-footer-accounts-img"

        createAvatar idx acc =
            img
                [ src acc.profile_image
                , class <| avatarClass idx
                , onClick <| SelectAccount acc.credential
                ]
                []

        accountsAvatars =
            usersDetails
                |> List.indexedMap (\idx u -> ( u, createAvatar idx u ))
                |> List.sortBy (Tuple.first >> .handler)
                |> List.map Tuple.second

        currentCredential =
            credentialInUse usersDetails
                |> Maybe.withDefault ""

        addAccountButton =
            a
                [ class "zmdi zmdi-plus btn btn-default btn-icon Main-footer-addAccount"
                , target "blank"
                , href <| Generic.Http.sameDomain <| "/sign-in/?app_session_id=" ++ sessionID
                ]
                []
    in
        div [ class "Main-footer-accounts-wrapper" ]
            [ span
                [ class "Main-footer-accounts" ]
                (addAccountButton :: accountsAvatars)
            , button
                [ class "zmdi zmdi-power btn btn-default btn-icon"
                , tabindex -1
                , tooltip "Logout"
                , onClick <| Logout currentCredential
                ]
                []
            ]


getSessionID : SessionIDAuthentication -> SessionID
getSessionID auth =
    case auth of
        NotAttempted id ->
            id

        Authenticating id ->
            id

        Authenticated id _ ->
            id

        AuthenticationFailed id _ ->
            id

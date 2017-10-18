module Main exposing (..)

import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)
import DynamicStyle exposing (..)
import Markdown exposing (toHtml)
import SmoothScroll exposing (scrollTo)
import Keyboard


main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }


type ValidationType
    = NotNull
    | Email
    | AtLeastOne


type alias Flags =
    { user : String
    , token : String
    }


type alias Model =
    { value : Int
    , demoData : DemoData
    , currentActiveQuestionNumber : Int
    , isFormActivated : Bool
    , numQuestionsAnswered : Int
    , totalQuestions : Int
    }


type alias Question =
    { questionType : QuestionType
    , questionNumber : Int
    , questionText : String
    , isAnswered : Bool
    , answer : String
    }


type QuestionType
    = Text TextOptions
    | Select SelectOptions


type alias DemoData =
    { topSection : TopSection
    , questions : List Question
    , name : String
    , colors : DemoColors
    }


type alias DemoColors =
    { colorMain : String
    , colorBackground : String
    , colorText : String
    , colorButton : String
    , colorButtonBackground : String
    , colorButtonHover : String
    , colorGray : String
    , colorSelectBackground : String
    , colorSelectHover : String
    , colorSelectLetterBackground : String
    , colorFooterBackground : String
    , colorFooter : String
    }


type alias TopSection =
    { imageLink : String
    , headerText : String
    , buttonText : String
    , pressText : String
    }


type alias TextOptions =
    { buttonText : String
    , pressText : String
    }


type alias Choice =
    { letter : String
    , body : String
    }


type alias SelectOptions =
    { choices : List Choice
    }



--Placeholder Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Keyboard.downs KeyMsg ]


emptyModel : Model
emptyModel =
    { value = 0
    , demoData = demoData
    , currentActiveQuestionNumber = 0
    , isFormActivated = False
    , numQuestionsAnswered = 0
    , totalQuestions = 0
    }



--Placeholder flags


init : Maybe Flags -> ( Model, Cmd Msg )
init flags =
    emptyModel ! []


type Msg
    = NoOp
    | Increment
    | NextQuestion
    | AnswerQuestion Int
    | PreviousQuestion
    | ActivateForm
    | KeyMsg Keyboard.KeyCode
    | TextQuestionInputChanged Int String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        --Change (newContent, questionNumber) ->
        TextQuestionInputChanged questionNumber newContent ->
            let
                demoData =
                    model.demoData

                questions =
                    demoData.questions

                newDemoData =
                    { demoData | questions = setQuestionAnswer questions newContent questionNumber }

                newModel =
                    { model | demoData = newDemoData }
            in
                ( newModel, Cmd.none )

        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )

        KeyMsg keyCode ->
            if keyCode == 13 then
                if model.isFormActivated then
                    --TODO: Jump to the next question
                    ( model, Cmd.none )
                else
                    ( { model | isFormActivated = True }, Cmd.none )
            else
                ( model, Cmd.none )

        NextQuestion ->
            ( { model | currentActiveQuestionNumber = model.currentActiveQuestionNumber + 1 }, Cmd.none )

        AnswerQuestion questionNumber ->
            let
                demoData =
                    model.demoData

                questions =
                    demoData.questions

                newDemoData =
                    { demoData | questions = (answerQuestion questions questionNumber) }

                newModel =
                    { model | demoData = newDemoData }

                newModel2 =
                    setNumQuestionsAnswered newModel

                newModel3 =
                    incrementCurrentlyActiveQuestion model
            in
                ( newModel3, scrollToId newModel3.currentActiveQuestionNumber )

        PreviousQuestion ->
            ( { model | currentActiveQuestionNumber = model.currentActiveQuestionNumber - 1 }, Cmd.none )

        ActivateForm ->
            let
                newModel =
                    model |> setActivated |> setTotalQuestions |> setCurrentQuestionToFirst
            in
                ( newModel, Cmd.none )


incrementCurrentlyActiveQuestion : Model -> Model
incrementCurrentlyActiveQuestion model =
    { model | currentActiveQuestionNumber = model.currentActiveQuestionNumber + 1 }


scrollToId : Int -> Cmd Msg
scrollToId id =
    scrollTo ("question" ++ (toString id))


setQuestionAnswer : List Question -> String -> Int -> List Question
setQuestionAnswer questions newContent questionNumber =
    List.map
        (\question ->
            if question.questionNumber == questionNumber then
                { question | answer = newContent }
            else
                question
        )
        questions


setNumQuestionsAnswered : Model -> Model
setNumQuestionsAnswered model =
    { model | numQuestionsAnswered = (getNumQuestionsAnswered model) }


getNumQuestionsAnswered : Model -> Int
getNumQuestionsAnswered model =
    let
        questionsAnswered =
            List.filter
                (\x ->
                    x.isAnswered == True
                )
                model.demoData.questions
    in
        List.length questionsAnswered


answerQuestion : List Question -> Int -> List Question
answerQuestion questions questionNumber =
    List.map
        (\question ->
            if question.questionNumber == questionNumber then
                let
                    question2 =
                        testSetIsAnswered question
                in
                    testSetIsAnswered question2
            else
                question
        )
        questions


testSetIsAnswered : Question -> Question
testSetIsAnswered question =
    { question | isAnswered = True }


testSetAnswer : Question -> String -> Question
testSetAnswer question answer =
    { question | answer = answer }


setCurrentQuestionToFirst : Model -> Model
setCurrentQuestionToFirst model =
    { model | currentActiveQuestionNumber = 1 }


setActivated : Model -> Model
setActivated model =
    { model | isFormActivated = True }


setTotalQuestions : Model -> Model
setTotalQuestions model =
    { model | totalQuestions = List.length model.demoData.questions }


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }


view : Model -> Html Msg
view model =
    div [ classes [ fl, w_100 ], class "montserrat" ]
        [ demo model model.demoData
        ]


liElement : String -> String -> CSSValue -> CSSValue -> String -> Html msg
liElement letter body colorBackground colorHover colorLetterBackground =
    li
        ((liElementTachyons) ++ (hover [ ( "backgroundColor", colorBackground, colorHover ) ]))
        [ span
            [ classes
                [ Tachyons.Classes.ba
                , Tachyons.Classes.ph2
                , Tachyons.Classes.pv1
                , Tachyons.Classes.mr2
                ]
            , style [ ( "backgroundColor", colorLetterBackground ) ]
            ]
            [ text letter ]
        , span []
            [ text body ]
        ]


liElementTachyons : List (Attribute msg)
liElementTachyons =
    [ classes
        [ Tachyons.Classes.ba
        , Tachyons.Classes.pa3
        , Tachyons.Classes.br2
        , Tachyons.Classes.b__black_40
        , Tachyons.Classes.mv3
        , Tachyons.Classes.pointer
        ]
    ]


topSectionButton : DemoColors -> String -> Html Msg
topSectionButton colors buttonText =
    button ([ (Html.Events.onClick ActivateForm) ] ++ (buttonTopTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover)) [ span [] [ Html.text buttonText ] ]


typeFormFooterButton colorButton colorButtonBackground colorButtonHover isUp =
    button
        ((buttonTypeformTachyons) ++ (hoverStyles colorButton colorButtonBackground colorButtonHover))
        [ span [ Html.Attributes.class (chevronUpOrDown isUp) ]
            []
        ]


chevronUpOrDown isUp =
    if isUp == True then
        "fa fa-chevron-up"
    else
        "fa fa-chevron-down"


buttonTopTachyons =
    [ classes
        ([ Tachyons.Classes.ph4 ] ++ buttonBaseTachyons)
    ]


buttonTypeformTachyons =
    [ classes
        ([ Tachyons.Classes.ph3 ] ++ buttonBaseTachyons)
    ]


buttonBaseTachyons =
    [ Tachyons.Classes.button_reset
    , Tachyons.Classes.b
    , Tachyons.Classes.br2
    , Tachyons.Classes.pv2
    , Tachyons.Classes.ph3
    , Tachyons.Classes.bn
    , Tachyons.Classes.pointer
    , Tachyons.Classes.shadow_5
    ]


hoverStyles colorButton colorButtonBackground colorButtonHover =
    hover_
        [ ( "color", colorButton )
        ]
        [ ( "backgroundColor", colorButtonBackground, colorButtonHover ) ]


buttonAsideText asideText asideColor =
    span
        [ classes [ Tachyons.Classes.f6, Tachyons.Classes.pl3 ]
        , Html.Attributes.style [ ( "color", asideColor ) ]
        ]
        [ Html.text asideText ]


demoData : DemoData
demoData =
    { topSection = demoTopSection
    , questions = [ demoFirstQuestion, demoSecondQuestion ]
    , name = "hey"
    , colors = demoColors
    }


demoColors : DemoColors
demoColors =
    { colorMain = "#5fb4bf"
    , colorBackground = "#E5F3F5"
    , colorText = "#275b62"
    , colorButton = "#275b62"
    , colorButtonBackground = "#73BEC8"
    , colorButtonHover = "#98cfd6"
    , colorGray = "#696969"
    , colorSelectBackground = "#DFEDEE"
    , colorSelectHover = "#CCD7D9"
    , colorSelectLetterBackground = "#C7D2D4"
    , colorFooterBackground = "#E1EEF0"
    , colorFooter = "#7C697F"
    }


demo : Model -> DemoData -> Html Msg
demo model data =
    div [ Html.Attributes.style [ ( "color", data.colors.colorMain ), ( "backgroundColor", data.colors.colorBackground ) ] ]
        [ if model.isFormActivated then
            div []
                [ div [ Html.Attributes.style [ ( "asdf", "asdf" ) ] ] (mapQuestions data.questions data.colors)
                , viewFooter data.colors.colorFooter data.colors.colorFooterBackground data.colors.colorButton data.colors.colorButtonBackground data.colors.colorButtonHover model.numQuestionsAnswered model.totalQuestions
                ]
          else
            viewTopSection data.topSection data.colors
        ]


viewFooter colorFooter colorBackground colorButton colorButtonBackground colorButtonHover completed total =
    div [ class "fixed left-0 right-0 bottom-0 ph6 pv3 fl w-100 bt  ", style [ ( "backgroundColor", colorBackground ), ( "color", colorFooter ) ] ]
        [ div [ class "fl w-50" ]
            (viewFooterProgressBar completed total)
        , div [ class "fl w-50" ]
            [ typeFormFooterButton colorButton colorButtonBackground colorButtonHover True
            , typeFormFooterButton colorButton colorButtonBackground colorButtonHover False
            ]
        ]


viewFooterProgressBar : Int -> Int -> List (Html Msg)
viewFooterProgressBar completed total =
    [ p [] [ text (toString completed ++ " out of " ++ toString total ++ " questions completed") ]
    , div [ class "bg-moon-gray br-pill h1 overflow-y-hidden" ] [ div [ class "bg-blue br-pill h1 shadow-1", style [ ( "width", calculateProgressbar completed total ) ] ] [] ]
      --, div [ class "bg-moon-gray br-pill h1 overflow-y-hidden" ] [ div [ class "bg-blue br-pill h1 shadow-1", style [ ( "width", "10%" ) ] ] [] ]
    ]


calculateProgressbar : Int -> Int -> String
calculateProgressbar completed total =
    toString (100 * (toFloat completed / toFloat total)) ++ "%"


mapQuestions : List Question -> DemoColors -> List (Html Msg)
mapQuestions questions colors =
    List.map
        (\question ->
            viewQuestion question colors
        )
        questions


viewQuestion : Question -> DemoColors -> Html Msg
viewQuestion question colors =
    case question.questionType of
        Text options ->
            viewTextQuestion question options colors

        Select options ->
            viewSelectQuestion question options colors


demoTopSection : TopSection
demoTopSection =
    { imageLink = "images/typeform-example-face.png"
    , headerText = "Hey stranger, I'm dying to get to know you better!"
    , buttonText = "Talk to me"
    , pressText = "press ENTER"
    }


demoFirstQuestion : Question
demoFirstQuestion =
    { questionNumber = 1
    , questionType = Text { buttonText = "OK", pressText = "press ENTER" }
    , answer = ""
    , isAnswered = False
    , questionText = "**Hello**. What's your name?*"
    }


demoSecondQuestion : Question
demoSecondQuestion =
    { questionNumber = 2
    , questionType =
        Select
            { choices =
                [ { letter = "A", body = "hey" }
                , { letter = "B", body = "still hardcoded" }
                , { letter = "C", body = "but safer" }
                ]
            }
    , answer = ""
    , isAnswered = False
    , questionText = "Hi, {{question1answer}}. What's your **gender**?"
    }


viewTopSection : TopSection -> DemoColors -> Html Msg
viewTopSection options colors =
    div
        [ classes
            [ Tachyons.Classes.pt6
            , Tachyons.Classes.f3
            , Tachyons.Classes.mw7
            , Tachyons.Classes.center
            , Tachyons.Classes.tc
            , Tachyons.Classes.vh_100
            ]
        , Html.Attributes.id "topsection"
        ]
        [ img
            [ classes []
            , Html.Attributes.src options.imageLink
            ]
            []
        , p [ classes [] ] [ Html.text options.headerText ]
        , div []
            [ topSectionButton colors options.buttonText
            , buttonAsideText options.pressText colors.colorGray
            ]
        ]


viewTextQuestion : Question -> TextOptions -> DemoColors -> Html Msg
viewTextQuestion question options colors =
    div
        [ classes
            [ Tachyons.Classes.pt6
            , Tachyons.Classes.mh7
            , Tachyons.Classes.f3
            , Tachyons.Classes.vh_100
            ]
        , Html.Attributes.id ("question" ++ toString question.questionNumber)
        ]
        [ questionText colors question.questionNumber question.questionText
        , div [ classes [ Tachyons.Classes.ml3 ], Html.Attributes.class "input--hoshi" ]
            [ input [ Html.Events.onInput (TextQuestionInputChanged question.questionNumber), Html.Attributes.class "input__field--hoshi", Html.Attributes.id "input-4", type_ "text" ]
                []
            , label [ Html.Attributes.class "input__label--hoshi hoshi-color-4", for "input-4" ]
                []
            ]
        , div
            [ classes
                [ Tachyons.Classes.pt2
                , Tachyons.Classes.ml3
                ]
            ]
            [ typeFormButton colors options.buttonText question.questionNumber
            , buttonAsideText options.pressText colors.colorGray
            ]
        , Html.br []
            []
        ]


typeFormButton : DemoColors -> String -> Int -> Html Msg
typeFormButton colors buttonText questionNumber =
    button
        ([ onClick (AnswerQuestion questionNumber) ] ++ (buttonTypeformTachyons) ++ (hoverStyles colors.colorButton colors.colorButtonBackground colors.colorButtonHover))
        [ span []
            [ Html.text buttonText ]
        , span [ Html.Attributes.class "fa fa-check" ]
            []
        ]


viewSelectQuestion : Question -> SelectOptions -> DemoColors -> Html Msg
viewSelectQuestion question options colors =
    div []
        [ div
            [ classes
                [ Tachyons.Classes.mt6
                , Tachyons.Classes.mh7
                , Tachyons.Classes.f3
                , Tachyons.Classes.vh_100
                ]
            , Html.Attributes.id ("question" ++ toString question.questionNumber)
            ]
            [ questionText colors question.questionNumber question.questionText
            , ul
                [ classes
                    [ Tachyons.Classes.list
                    , Tachyons.Classes.mw6
                    ]
                , Html.Attributes.style [ ( "color", colors.colorGray ) ]
                ]
                (listChoices options.choices colors)
            ]
        ]


listChoices : List Choice -> DemoColors -> List (Html msg)
listChoices choices colors =
    List.map
        (\choice ->
            liElement choice.letter choice.body colors.colorSelectBackground colors.colorSelectHover colors.colorSelectLetterBackground
        )
        choices


questionText colors questionNumber body =
    div [ Html.Attributes.class "" ]
        [ span [ classes [ Tachyons.Classes.pr2, Tachyons.Classes.fl ] ]
            [ span [ Html.Attributes.style [ ( "color", colors.colorGray ) ] ]
                [ span [ classes [ Tachyons.Classes.pr1 ] ]
                    [ Html.text (toString questionNumber) ]
                , span [ Html.Attributes.class "fa fa-arrow-right" ]
                    []
                ]
            ]
        , span [] <|
            toHtml Nothing body
        ]

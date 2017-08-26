module Simple exposing (main)

import Html exposing (Html, Attribute, text, div, h1, p)
import Html.Attributes exposing (style, class, id)
import AccordionMenu exposing (Menu)
import AccordionMenu.Style as Style


type alias Model =
    { clickMenu : SelectableMenu
    , mouseMenu : SelectableMenu
    }


type alias SelectableMenu =
    { menu : Menu Msg
    , selected : Selection
    }


type Selection
    = NoSelection
    | Trumpet
    | Trombone
    | Oboe
    | Flute
    | Piccolo


init : Model
init =
    { clickMenu =
        { menu = menu "click"
        , selected = NoSelection
        }
    , mouseMenu =
        { menu = menu "mouse"
        , selected = NoSelection
        }
    }


menu : String -> Menu Msg
menu id =
    AccordionMenu.menu "Instruments"
        [ AccordionMenu.link "Ukelele" "#/uke" []
        , AccordionMenu.separator "separator1" [ style styleSeparator ]
        , AccordionMenu.subMenu "Brass"
            [ AccordionMenu.subMenuAction (Select id Trumpet) "Trumpet" []
            , AccordionMenu.subMenuAction (Select id Trombone) "Trombone" []
            ]
        , AccordionMenu.subMenu "Reed"
            [ AccordionMenu.subMenuAction (Select id Oboe) "Oboe" []
            , AccordionMenu.subMenuAction (Select id Flute) "Flute" []
            , AccordionMenu.subMenuAction (Select id Piccolo) "Piccolo" []
            ]
        ]


type Msg
    = Select String Selection
    | UpdateMenu String AccordionMenu.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        Select id selection ->
            let
                _ =
                    Debug.log "Select" ( id, selection )
            in
                case id of
                    "mouse" ->
                        { model | mouseMenu = selectMenuItem selection model.mouseMenu }
                            |> andCloseMenu "mouse"

                    "click" ->
                        { model | clickMenu = selectMenuItem selection model.clickMenu }
                            |> andCloseMenu "click"

                    _ ->
                        model

        UpdateMenu id submsg ->
            case id of
                "mouse" ->
                    { model | mouseMenu = updateMenu submsg model.mouseMenu }

                "click" ->
                    { model | clickMenu = updateMenu submsg model.clickMenu }

                _ ->
                    model


updateMenu : AccordionMenu.Msg -> SelectableMenu -> SelectableMenu
updateMenu submsg menu =
    { menu | menu = AccordionMenu.update submsg menu.menu }


selectMenuItem : Selection -> SelectableMenu -> SelectableMenu
selectMenuItem selection menu =
    { menu | selected = selection }


andCloseMenu : String -> Model -> Model
andCloseMenu id model =
    let
        closeMenu menu =
            { menu | menu = AccordionMenu.closeMenu menu.menu }
    in
        case id of
            "mouse" ->
                { model | mouseMenu = closeMenu model.mouseMenu }

            "click" ->
                { model | clickMenu = closeMenu model.clickMenu }

            _ ->
                model


view : Model -> Html Msg
view { clickMenu, mouseMenu } =
    div [ id "page" ]
        [ div [ id "header" ]
            [ h1 []
                [ text "Simple example" ]
            , p []
                [ text "The menu on the left responds to clicks. The menu on the right responds to mouse movement (mouseenter/mouseleave). The default is to respond to clicks." ]
            ]
        , div [ id "main-left" ]
            [ viewMenu "click" clickMenu
            ]
        , div [ id "main-right" ]
            [ viewMenu "mouse" mouseMenu
            ]
        ]


viewMenu : String -> SelectableMenu -> Html Msg
viewMenu id { menu } =
    AccordionMenu.view
        (case id of
            "mouse" ->
                menuConfig "mouse" "darkred"
                    |> AccordionMenu.setMenuEventsOnHover

            "click" ->
                menuConfig "click" "darkgreen"

            anythingElse ->
                menuConfig anythingElse "darkgrey"
        )
        menu


menuConfig : String -> String -> AccordionMenu.Config Msg
menuConfig id color =
    AccordionMenu.blankConfig (UpdateMenu id)
        |> AccordionMenu.setOpenArrow
            { attributes = [ style styleArrows ], children = [ text "↓" ] }
        |> AccordionMenu.setCloseArrow
            { attributes = [ style styleArrows ], children = [ text "↑" ] }
        |> Style.resetListStyles
        |> Style.listItemStyles styleListItems
        |> Style.absolutePositioned styleMenuList
        |> Style.staticMenuStyles styleMenu
        |> Style.menuTitleStyles (styleMenuTitle color)
        |> Style.menuListStyles styleMenuList
        |> Style.subMenuTitleStyles (styleMenuTitle color)


styleListItems : List ( String, String )
styleListItems =
    [ ( "padding-left", "0.5rem" ) ]


styleMenu : List ( String, String )
styleMenu =
    [ ( "width", "300px" )
    , ( "margin", "0.5rem" )
    , ( "position", "relative" )
    ]


styleMenuTitle : String -> AccordionMenu.MenuState -> List ( String, String )
styleMenuTitle color state =
    case state of
        AccordionMenu.Closed ->
            [ ( "border", ("1px solid " ++ color) )
            , ( "border-radius", "5px" )
            , ( "color", color )
            , ( "padding", "5px" )
            , ( "margin-top", "0.25rem" )
            ]

        AccordionMenu.Open ->
            [ ( "border", "1px solid white" )
            , ( "border-radius", "5px" )
            , ( "background-color", color )
            , ( "color", "white" )
            , ( "padding", "5px" )
            , ( "margin-top", "0.25rem" )
            ]


styleMenuList : List ( String, String )
styleMenuList =
    [ ( "background-color", "#fff" )
    , ( "padding", "1rem" )
    , ( "top", "30px" )
    , ( "box-shadow", "0 0 5px rgba(0,0,0,0.3)" )
    ]


styleSeparator : List ( String, String )
styleSeparator =
    [ ( "border", "0" )
    , ( "background", "rgba(0, 0, 0, 0.3)" )
    , ( "height", "1px" )
    ]


styleArrows : List ( String, String )
styleArrows =
    [ ( "margin-left", "5px" ) ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = init
        , view = view
        , update = update
        }

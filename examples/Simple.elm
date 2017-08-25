module Simple exposing (main)

import Html exposing (Html, Attribute, text)
import Html.Attributes exposing (style)
import AccordionMenu exposing (Menu)
import AccordionMenu.Style as Style


type alias Model =
    { menu : Menu Msg
    , selected : Selection
    }


type Selection
    = NoSelection
    | Trumpet
    | Trombone


init : Model
init =
    { menu = menu
    , selected = NoSelection
    }


menu : Menu Msg
menu =
    AccordionMenu.menu "Instruments"
        [ AccordionMenu.link "Ukelele" "#/uke" []
        , AccordionMenu.separator [ style styleSeparator ]
        , AccordionMenu.subMenu "Brass"
            [ AccordionMenu.subMenuAction "Trumpet" (Select Trumpet) []
            , AccordionMenu.subMenuAction "Trombone" (Select Trombone) []
            ]
        ]


type Msg
    = Select Selection
    | UpdateMenu AccordionMenu.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        Select selection ->
            { model | selected = Debug.log "Select" selection } |> andCloseMenu

        UpdateMenu submsg ->
            { model | menu = AccordionMenu.update submsg model.menu }


andCloseMenu : Model -> Model
andCloseMenu model =
    { model | menu = AccordionMenu.closeMenu model.menu }


view : Model -> Html Msg
view { menu } =
    AccordionMenu.view menuConfig menu


menuConfig : AccordionMenu.Config Msg
menuConfig =
    Style.blankConfig UpdateMenu
        |> AccordionMenu.setOpenArrow 
            { attributes = [ style styleArrows ], children = [ text "↓" ] }
        |> AccordionMenu.setCloseArrow 
            { attributes = [ style styleArrows ], children = [ text "↑" ] }
        |> Style.resetListStyles
        |> Style.absolutePositioned styleMenuList
        |> Style.staticMenuStyles styleMenu
        |> Style.menuTitleStyles styleMenuTitle
        |> Style.menuListStyles styleMenuList
        |> Style.subMenuTitleStyles styleMenuTitle


styleMenu : List (String, String)
styleMenu =
        [ ( "width", "300px" )
        , ( "margin", "1em" )
        , ( "position", "relative" )
        ]

styleMenuTitle : AccordionMenu.MenuState -> List (String, String)
styleMenuTitle state =
    case state of
        AccordionMenu.Closed ->
                [ ( "border", "1px solid blue" )
                , ( "border-radius", "5px" )
                , ( "color", "blue" )
                , ( "padding", "5px" )
                ]

        AccordionMenu.Open ->
                [ ( "border", "1px solid white" )
                , ( "border-radius", "5px" )
                , ( "background-color", "blue" )
                , ( "color", "white" )
                , ( "padding", "5px" )
                ]

styleMenuList : List (String, String)
styleMenuList =
    [ ( "background-color", "#fff" )
    , ( "padding", "1rem" )
    , ( "transform", "translate(0px, 35px)" )
    , ( "box-shadow", "0 0 5px rgba(0,0,0,0.3)" )
    ]



styleSeparator : List (String, String)
styleSeparator =
        [ ( "border", "0" )
        , ( "background", "rgba(0, 0, 0, 0.3)" )
        , ( "height", "1px" )
        ]


styleArrows : List (String, String)
styleArrows =
        [ ( "margin-left", "5px" ) ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = init
        , view = view
        , update = update
        }

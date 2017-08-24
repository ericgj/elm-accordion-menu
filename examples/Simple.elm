module Simple exposing (main)

import Html exposing (Html, Attribute, text)
import Html.Attributes exposing (style)
import AccordionMenu exposing (Menu)


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
        , AccordionMenu.separator styleSeparator
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
    AccordionMenu.customConfig
        { updateMenu = UpdateMenu
        , openArrow = { attributes = styleArrows, children = [ text "↓" ] }
        , closeArrow = { attributes = styleArrows, children = [ text "↑" ] }
        , ul = styleLists
        , li = []
        , menu = styleMenu
        , menuTitle = styleMenuTitle
        , menuList = styleMenuList
        , menuSubMenu = (\_ -> [])
        , subMenuTitle = styleMenuTitle
        , subMenuList = []
        }



-- Note: you don't have to do this reset here, could be in CSS


styleLists : List (Attribute Never)
styleLists =
    [ style
        [ ( "list-style-type", "none" )
        , ( "-webkit-margin-before", "0" )
        , ( "-webkit-margin-after", "0" )
        , ( "-webkit-padding-start", "0" )
        ]
    ]


styleMenu : AccordionMenu.MenuState -> List (Attribute Never)
styleMenu state =
    [ style
        [ ( "width", "300px" )
        , ( "margin", "1em" )
        , ( "position", "relative" )
        ]
    ]


styleMenuTitle : AccordionMenu.MenuState -> List (Attribute Never)
styleMenuTitle state =
    case state of
        AccordionMenu.Closed ->
            [ style
                [ ( "border", "1px solid blue" )
                , ( "border-radius", "5px" )
                , ( "color", "blue" )
                , ( "padding", "5px" )
                ]
            ]

        AccordionMenu.Open ->
            [ style
                [ ( "border", "1px solid white" )
                , ( "border-radius", "5px" )
                , ( "background-color", "blue" )
                , ( "color", "white" )
                , ( "padding", "5px" )
                ]
            ]


styleMenuList : List (Attribute Never)
styleMenuList =
    [ style
        [ ( "position", "absolute" )
        , ( "top", "0" )
        , ( "left", "0" )
        , ( "width", "100%" )
        , ( "background-color", "#fff" )
        , ( "padding", "1em" )
        , ( "transform", "translate(10px, 35px)" )
        , ( "box-shadow", "0 0 5px rgba(0, 0, 0, 0.3)" )
        ]
    ]


styleSeparator : List (Attribute Msg)
styleSeparator =
    [ style
        [ ( "border", "0" )
        , ( "background", "rgba(0, 0, 0, 0.3)" )
        , ( "height", "1px" )
        ]
    ]


styleArrows : List (Attribute Never)
styleArrows =
    [ style
        [ ( "margin-left", "5px" ) ]
    ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = init
        , view = view
        , update = update
        }

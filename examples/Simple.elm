module Simple exposing (main)

import Html exposing (Html, text)
import AccordionMenu exposing (Menu)

type alias Model =
    { menu : Menu Msg
    , selected : Maybe String
    }


init : Model
init =
  { menu = menu 
  , selected = Nothing
  }

menu : Menu Msg
menu =
    AccordionMenu.menu "Instruments"
        [ AccordionMenu.link "Ukelele" "#/uke"
        , AccordionMenu.separator
        , AccordionMenu.subMenu "Brass"
            [ AccordionMenu.subMenuAction "Trumpet" Trumpet
            , AccordionMenu.subMenuAction "Trombone" Trombone
            ]
        ]


type Msg
  = Trumpet
  | Trombone
  | UpdateMenu AccordionMenu.Msg

update : Msg -> Model -> Model
update msg model =
    case msg of
        Trumpet ->
            { model | selected = Just "Trumpet" } |> andCloseMenu
        Trombone ->
            { model | selected = Just "Trombone" } |> andCloseMenu
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
        , openArrow = { attributes = [], children = [ text "↓" ] }
        , closeArrow = { attributes = [], children = [ text "↑" ] }
        , menu = []
        , menuTitle = []
        , menuSeparator = []
        , menuLink = []
        , menuAction = []
        , menuSubMenu = []
        , subMenuTitle = []
        , subMenuLink = []
        , subMenuAction = []
        }


main : Program Never Model Msg
main =
    Html.beginnerProgram 
        { model = init
        , view = view
        , update = update
        }



module AccordionMenu
    exposing
        ( Menu
        , SubMenu
        , Msg
        , Config
        , update
        , view
        , customConfig
        , menu
        , separator
        , link
        , action
        , subMenu
        , subMenuLink
        , subMenuAction
        , toggleMenu
        , closeMenu
        , closeSubMenus
        , closeMenuAndSubMenus
        , openMenu
        )

import Json.Decode as JD
import Html exposing (..)
import Html.Attributes exposing (title, href)
import Html.Events exposing (onWithOptions, on)


type MenuState
    = Open
    | Closed


type Menu msg
    = Menu
        { title : String
        , items : List (MenuItem msg)
        , state : MenuState
        }


type SubMenu msg
    = SubMenu
        { title : String
        , items : List (SubMenuItem msg)
        , state : MenuState
        }


type MenuItem msg
    = MenuSeparator
    | MenuLink String String
    | MenuAction String msg
    | MenuSubMenu (SubMenu msg)


type SubMenuItem msg
    = SubLink String String
    | SubAction String msg


type alias HtmlDetails msg =
    { attributes : List (Attribute msg)
    , children : List (Html msg)
    }


type Config msg
    = Config
        { updateMenu : Msg -> msg
        , openArrow : HtmlDetails Never
        , closeArrow : HtmlDetails Never
        , menu : List (Attribute Never)
        , menuTitle : List (Attribute Never)
        , menuSeparator : List (Attribute Never)
        , menuLink : List (Attribute Never)
        , menuAction : List (Attribute Never)
        , menuSubMenu : List (Attribute Never)
        , subMenuTitle : List (Attribute Never)
        , subMenuLink : List (Attribute Never)
        , subMenuAction : List (Attribute Never)
        }



-- MODEL


menu : String -> List (MenuItem msg) -> Menu msg
menu title_ items =
    Menu { title = title_, items = items, state = Closed }


separator : MenuItem msg
separator =
    MenuSeparator


link : String -> String -> MenuItem msg
link =
    MenuLink


action : String -> msg -> MenuItem msg
action =
    MenuAction


subMenu : String -> List (SubMenuItem msg) -> MenuItem msg
subMenu title_ items =
    MenuSubMenu (SubMenu { title = title_, items = items, state = Closed })


subMenuLink : String -> String -> SubMenuItem msg
subMenuLink =
    SubLink


subMenuAction : String -> msg -> SubMenuItem msg
subMenuAction =
    SubAction



-- CONFIG


customConfig :
    { a
        | updateMenu : Msg -> msg
        , openArrow : HtmlDetails Never
        , closeArrow : HtmlDetails Never
        , menu : List (Attribute Never)
        , menuTitle : List (Attribute Never)
        , menuSeparator : List (Attribute Never)
        , menuLink : List (Attribute Never)
        , menuAction : List (Attribute Never)
        , menuSubMenu : List (Attribute Never)
        , subMenuTitle : List (Attribute Never)
        , subMenuLink : List (Attribute Never)
        , subMenuAction : List (Attribute Never)
    }
    -> Config msg
customConfig { updateMenu, openArrow, closeArrow, menu, menuTitle, menuSeparator, menuLink, menuAction, menuSubMenu, subMenuTitle, subMenuLink, subMenuAction } =
    Config
        { updateMenu = updateMenu
        , openArrow = openArrow
        , closeArrow = closeArrow
        , menu = menu
        , menuTitle = menuTitle
        , menuSeparator = menuSeparator
        , menuLink = menuLink
        , menuAction = menuAction
        , menuSubMenu = menuSubMenu
        , subMenuTitle = subMenuTitle
        , subMenuLink = subMenuLink
        , subMenuAction = subMenuAction
        }



-- UPDATE


type Msg
    = ToggleMenuState
    | ToggleSubMenuState Int
    | CloseMenu
    | CloseSubMenus
    | OpenMenu
    | OpenSubMenu Int
    | NoOp


update : Msg -> Menu msg -> Menu msg
update msg (Menu menu) =
    case msg of
        NoOp ->
            (Menu menu)

        ToggleMenuState ->
            toggleMenu (Menu menu)

        ToggleSubMenuState index ->
            let
                toggleItemAt index i item =
                    if i == index then
                        case item of
                            MenuSubMenu (SubMenu submenu) ->
                                MenuSubMenu (SubMenu { submenu | state = toggle submenu.state })

                            _ ->
                                item
                    else
                        item
            in
                Menu { menu | items = List.indexedMap (toggleItemAt index) menu.items }

        CloseMenu ->
            closeMenu (Menu menu)

        CloseSubMenus ->
            closeSubMenus (Menu menu)

        OpenMenu ->
            openMenu (Menu menu)

        OpenSubMenu index ->
            let
                openItemAt index i item =
                    if i == index then
                        case item of
                            MenuSubMenu (SubMenu submenu) ->
                                MenuSubMenu (SubMenu { submenu | state = Open })

                            _ ->
                                item
                    else
                        item
            in
                Menu { menu | items = List.indexedMap (openItemAt index) menu.items }



toggle : MenuState -> MenuState
toggle mstate =
    case mstate of
        Open ->
            Closed

        Closed ->
            Open

toggleMenu : Menu msg -> Menu msg
toggleMenu (Menu menu) =
    Menu { menu | state = toggle menu.state }

closeMenu : Menu msg -> Menu msg
closeMenu (Menu menu) =
    Menu { menu | state = Closed }

closeSubMenus : Menu msg -> Menu msg
closeSubMenus (Menu menu) =
    let
        closeSubMenu item =
            case item of
                MenuSubMenu (SubMenu submenu) ->
                    MenuSubMenu (SubMenu { submenu | state = Closed })

                _ ->
                    item
    in
        Menu { menu | items = List.map closeSubMenu menu.items }


closeMenuAndSubMenus : Menu msg -> Menu msg
closeMenuAndSubMenus =
   closeSubMenus >> closeMenu

openMenu : Menu msg -> Menu msg
openMenu (Menu menu) =
    Menu { menu | state = Open }



-- VIEW


view : Config msg -> Menu msg -> Html msg
view (Config c) (Menu { title, items, state }) =
    div (noOpAttrs c.updateMenu c.menu)
        ([ viewTitle (Config c) title state
         ]
            ++ (case state of
                    Open ->
                        [ viewMenu (Config c) items ]

                    Closed ->
                        []
               )
        )


viewTitle :
    Config msg
    -> String
    -> MenuState
    -> Html msg
viewTitle (Config c) title_ state =
    let
        arrow state =
            case state of
                Open ->
                    noOpHtmlDetails c.updateMenu c.closeArrow

                Closed ->
                    noOpHtmlDetails c.updateMenu c.openArrow
    in
        div (noOpAttrs c.updateMenu c.menuTitle)
            [ viewMenuTitleAction
                title_
                (OpenMenu |> c.updateMenu)
                (ToggleMenuState |> c.updateMenu)
                (arrow state)
            ]


viewMenu :
    Config msg
    -> List (MenuItem msg)
    -> Html msg
viewMenu config menuItems =
    ul []
        (List.indexedMap (viewMenuItem config) menuItems)


viewMenuItem :
    Config msg
    -> Int
    -> MenuItem msg
    -> Html msg
viewMenuItem (Config c) index item =
    case item of
        MenuSeparator ->
            li (noOpAttrs c.updateMenu c.menuSeparator)
                [ hr [] [] ]

        MenuLink title href ->
            li (noOpAttrs c.updateMenu c.menuLink)
                [ viewMenuLink title href [] ]

        MenuAction title click ->
            li (noOpAttrs c.updateMenu c.menuAction)
                [ viewMenuAction title click [] ]

        MenuSubMenu (SubMenu { title, items, state }) ->
            li (noOpAttrs c.updateMenu c.menuSubMenu)
                ([ viewSubTitle (Config c) index title state
                 ]
                    ++ (case state of
                            Open ->
                                [ viewSubMenu (Config c) items ]

                            Closed ->
                                []
                       )
                )


viewSubTitle :
    Config msg
    -> Int
    -> String
    -> MenuState
    -> Html msg
viewSubTitle (Config c) index title_ state =
    let
        arrow state =
            case state of
                Open ->
                    (noOpHtmlDetails c.updateMenu c.closeArrow)

                Closed ->
                    (noOpHtmlDetails c.updateMenu c.openArrow)
    in
        div (noOpAttrs c.updateMenu c.subMenuTitle)
            [ viewMenuTitleAction
                title_
                (OpenSubMenu index |> c.updateMenu)
                (ToggleSubMenuState index |> c.updateMenu)
                (arrow state)
            ]


viewSubMenu :
    Config msg
    -> List (SubMenuItem msg)
    -> Html msg
viewSubMenu config items =
    ul []
        (List.map (viewSubMenuItem config) items)


viewSubMenuItem :
    Config msg
    -> SubMenuItem msg
    -> Html msg
viewSubMenuItem (Config c) item =
    case item of
        SubLink title href ->
            li (noOpAttrs c.updateMenu c.subMenuLink)
                [ viewMenuLink title href [] ]

        SubAction title click ->
            li (noOpAttrs c.updateMenu c.subMenuAction)
                [ viewMenuAction title click [] ]


viewMenuLink : String -> String -> List (Attribute msg) -> Html msg
viewMenuLink title_ href_ attribs =
    a
        ([ title title_, href href_ ] ++ attribs)
        [ text title_ ]


viewMenuAction : String -> msg -> List (Attribute msg) -> Html msg
viewMenuAction title_ msg attribs =
    a
        ([ title title_ ]
            ++ [ onWithOptions
                    "click"
                    { stopPropagation = False, preventDefault = True }
                    (JD.succeed msg)
               ]
            ++ attribs
        )
        [ text title_ ]


viewMenuTitleAction : String -> msg -> msg -> HtmlDetails msg -> Html msg
viewMenuTitleAction title_ mouseMsg clickMsg arrow =
    a
        [ title title_
        , on "mouseover" (JD.succeed mouseMsg)
        , onWithOptions
            "click"
            { stopPropagation = False, preventDefault = True }
            (JD.succeed clickMsg)
        ]
        [ text title_
        , span arrow.attributes arrow.children
        ]


mapNeverToMsg : msg -> Attribute Never -> Attribute msg
mapNeverToMsg msg attr =
    Html.Attributes.map (\_ -> msg) attr


mapNeverToNoOp : (Msg -> msg) -> Attribute Never -> Attribute msg
mapNeverToNoOp mapper attr =
    Html.Attributes.map (\_ -> mapper NoOp) attr


noOpAttrs : (Msg -> msg) -> List (Attribute Never) -> List (Attribute msg)
noOpAttrs mapper attrs =
    List.map (mapNeverToNoOp mapper) attrs


noOpHtmlDetails : (Msg -> msg) -> HtmlDetails Never -> HtmlDetails msg
noOpHtmlDetails mapper details =
    { details
        | attributes = noOpAttrs mapper details.attributes
        , children = List.map (Html.map (\_ -> mapper NoOp)) details.children
    }

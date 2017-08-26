module AccordionMenu
    exposing
        ( Menu
        , SubMenu
        , MenuState(..)
        , MenuEventsOn(..)
        , SubMenuBehavior(..)
        , Msg
        , Config
        , update
        , view
        , customConfig
        , menu
        , separator
        , link
        , action
        , customMenuItem
        , subMenu
        , subMenuLink
        , subMenuAction
        , customSubMenuItem
        , toggleMenu
        , closeMenu
        , closeSubMenus
        , closeMenuAndSubMenus
        , openMenu
        , setMenuEventsOn
        , setMenuEventsOnMouseEnter
        , setMenuEventsOnClick
        , setOpenArrow
        , setCloseArrow
        , addListAttributes
        , addListItemAttributes
        , staticMenuAttributes, menuAttributes
        , staticMenuTitleAttributes, menuTitleAttributes
        , addMenuListAttributes
        , staticSubMenuAttributes, subMenuAttributes
        , staticSubMenuTitleAttributes, subMenuTitleAttributes
        , addSubMenuListAttributes
        )

import Json.Decode as JD
import Html exposing (..)
import Html.Attributes exposing (title, href, style)
import Html.Events exposing (onWithOptions, on)


type MenuState
    = Open
    | Closed

type MenuEventsOn
    = MouseEnter
    | Click

type SubMenuBehavior
    = SingleOpen
    | ManyOpen


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
    = MenuItem (HtmlDetails msg)
    | MenuSubMenu (SubMenu msg)


type SubMenuItem msg
    = SubMenuItem (HtmlDetails msg)


type alias HtmlDetails msg =
    { attributes : List (Attribute msg)
    , children : List (Html msg)
    }


type Config msg
    = Config
        { updateMenu : Msg -> msg
        , menuEventsOn : MenuEventsOn
        , openArrow : HtmlDetails Never
        , closeArrow : HtmlDetails Never
        , ul : List (Attribute Never)
        , li : List (Attribute Never)
        , menu : MenuState -> List (Attribute Never)
        , menuTitle : MenuState -> List (Attribute Never)
        , menuList : List (Attribute Never)
        , menuSubMenu : MenuState -> List (Attribute Never)
        , subMenuTitle : MenuState -> List (Attribute Never)
        , subMenuList : List (Attribute Never)
        }


-- MODEL


menu : String -> List (MenuItem msg) -> Menu msg
menu title_ items =
    Menu { title = title_, items = items, state = Closed }


separator : List (Attribute msg) -> MenuItem msg
separator attrs =
    MenuItem
        { attributes = []
        , children = [ hr attrs [] ]
        }

link : String -> String -> List (Attribute msg) -> MenuItem msg
link title_ href_ attrs =
    MenuItem
        { attributes = []
        , children = 
            [ viewMenuLink title_ href_ attrs ]
        }


action : msg -> String -> List (Attribute msg) -> MenuItem msg
action msg title_ attrs =
    MenuItem
        { attributes = []
        , children =
            [ viewMenuAction msg title_ attrs ]
        }

customMenuItem : List (Attribute msg) -> List (Html msg) -> MenuItem msg
customMenuItem attributes children =
    MenuItem
        { attributes = attributes
        , children = children
        }


subMenu : String -> List (SubMenuItem msg) -> MenuItem msg
subMenu title_ items =
    MenuSubMenu (SubMenu { title = title_, items = items, state = Closed })


subMenuLink : String -> String -> List (Attribute msg) -> SubMenuItem msg
subMenuLink title_ href_ attrs =
    SubMenuItem
        { attributes = []
        , children =
            [ viewMenuLink title_ href_ attrs ]
        }

subMenuAction : msg -> String -> List (Attribute msg) -> SubMenuItem msg
subMenuAction msg title_ attrs =
    SubMenuItem
        { attributes = []
        , children =
            [ viewMenuAction msg title_ attrs ]
        }

customSubMenuItem : List (Attribute msg) -> List (Html msg) -> SubMenuItem msg
customSubMenuItem attributes children =
    SubMenuItem
        { attributes = attributes
        , children = children
        }



-- CONFIG


customConfig :
    { a
        | updateMenu : Msg -> msg
        , menuEventsOn : MenuEventsOn
        , openArrow : HtmlDetails Never
        , closeArrow : HtmlDetails Never
        , ul : List (Attribute Never)
        , li : List (Attribute Never)
        , menu : MenuState -> List (Attribute Never)
        , menuTitle : MenuState -> List (Attribute Never)
        , menuList : List (Attribute Never)
        , menuSubMenu : MenuState -> List (Attribute Never)
        , subMenuTitle : MenuState -> List (Attribute Never)
        , subMenuList : List (Attribute Never)
    }
    -> Config msg
customConfig { updateMenu, menuEventsOn, openArrow, closeArrow, ul, li, menu, menuTitle, menuList, menuSubMenu, subMenuTitle, subMenuList } =
    Config
        { updateMenu = updateMenu
        , menuEventsOn = menuEventsOn
        , openArrow = openArrow
        , closeArrow = closeArrow
        , ul = ul
        , li = li
        , menu = menu
        , menuTitle = menuTitle
        , menuList = menuList
        , menuSubMenu = menuSubMenu
        , subMenuTitle = subMenuTitle
        , subMenuList = subMenuList
        }

setMenuEventsOnClick : Config msg -> Config msg
setMenuEventsOnClick = setMenuEventsOn Click

setMenuEventsOnMouseEnter : Config msg -> Config msg
setMenuEventsOnMouseEnter = setMenuEventsOn MouseEnter

setMenuEventsOn : MenuEventsOn -> Config msg -> Config msg
setMenuEventsOn eventsOn (Config config) =
    Config { config | menuEventsOn = eventsOn }

setOpenArrow : HtmlDetails Never -> Config msg -> Config msg
setOpenArrow details (Config config) =
    Config { config | openArrow = details }

setCloseArrow : HtmlDetails Never -> Config msg -> Config msg
setCloseArrow details (Config config) =
    Config { config | closeArrow = details }

addListAttributes : List (Attribute Never) -> Config msg -> Config msg
addListAttributes attrs (Config config) =
    customConfig { config | ul = config.ul ++ attrs }

addListItemAttributes : List (Attribute Never) -> Config msg -> Config msg
addListItemAttributes attrs (Config config) =
    customConfig { config | li = config.li ++ attrs }

menuAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
menuAttributes func (Config config) =
    customConfig { config | menu = func }

staticMenuAttributes : List (Attribute Never) -> Config msg -> Config msg
staticMenuAttributes attrs (Config config) =
    customConfig { config | menu = (\_ -> attrs) }

menuTitleAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
menuTitleAttributes func (Config config) =
    customConfig { config | menuTitle = func }

staticMenuTitleAttributes : List (Attribute Never) -> Config msg -> Config msg
staticMenuTitleAttributes attrs (Config config) =
    customConfig { config | menuTitle = (\_ -> attrs) }

addMenuListAttributes : List (Attribute Never) -> Config msg -> Config msg
addMenuListAttributes attrs (Config config) =
    customConfig { config | menuList = config.menuList ++ attrs }

subMenuAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
subMenuAttributes func (Config config) =
    customConfig { config | menuSubMenu = func }

staticSubMenuAttributes : List (Attribute Never) -> Config msg -> Config msg
staticSubMenuAttributes attrs (Config config) =
    customConfig { config | menuSubMenu = (\_ -> attrs) }

subMenuTitleAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
subMenuTitleAttributes func (Config config) =
    customConfig { config | subMenuTitle = func }

staticSubMenuTitleAttributes : List (Attribute Never) -> Config msg -> Config msg
staticSubMenuTitleAttributes attrs (Config config) =
    customConfig { config | subMenuTitle = (\_ -> attrs) }

addSubMenuListAttributes : List (Attribute Never) -> Config msg -> Config msg
addSubMenuListAttributes attrs (Config config) =
    customConfig { config | subMenuList = config.subMenuList ++ attrs }



-- UPDATE


type Msg
    = ToggleMenuState
    | ToggleSubMenuState Int
    | CloseMenu
    | CloseSubMenu Int
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

        CloseSubMenu index ->
            closeSubMenu index (Menu menu)

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

closeSubMenu : Int -> Menu msg -> Menu msg
closeSubMenu index (Menu menu) =
    let
        closeSubMenuAt i item =
            if i == index then
              case item of
                  MenuSubMenu (SubMenu submenu) ->
                      MenuSubMenu (SubMenu { submenu | state = Closed })

                  _ ->
                      item
            else
              item
    in
        Menu { menu | items = List.indexedMap closeSubMenuAt menu.items }


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
    let
        handlers = 
            handleMenuEventsWith c.updateMenu c.menuEventsOn
    in
        div 
            ( handlers ++ (noOpAttrs c.updateMenu (c.menu state)))
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
        div (noOpAttrs c.updateMenu (c.menuTitle state))
            [ viewMenuTitleAction
                title_
                (arrow state)
            ]


viewMenu :
    Config msg
    -> List (MenuItem msg)
    -> Html msg
viewMenu (Config c) menuItems =
    ul (noOpAttrs c.updateMenu (c.ul ++ c.menuList))
        (List.indexedMap (viewMenuItem (Config c)) menuItems)


viewMenuItem :
    Config msg
    -> Int
    -> MenuItem msg
    -> Html msg
viewMenuItem (Config c) index item =
    let
        liAttrs =
            noOpAttrs c.updateMenu c.li

        handlers index = 
            handleSubMenuEventsWith c.updateMenu c.menuEventsOn index
    in
        case item of
            MenuItem { attributes, children } ->
                li (liAttrs ++ attributes) children

            MenuSubMenu (SubMenu { title, items, state }) ->
                li 
                    ( ( handlers index ) ++
                      ( noOpAttrs c.updateMenu (c.menuSubMenu state) ) ++ 
                      liAttrs 
                    )
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
        div (noOpAttrs c.updateMenu (c.subMenuTitle state))
            [ viewMenuTitleAction
                title_
                (arrow state)
            ]


viewSubMenu :
    Config msg
    -> List (SubMenuItem msg)
    -> Html msg
viewSubMenu (Config c) items =
    ul (noOpAttrs c.updateMenu (c.ul ++ c.subMenuList))
        (List.map (viewSubMenuItem (Config c)) items)


viewSubMenuItem :
    Config msg
    -> SubMenuItem msg
    -> Html msg
viewSubMenuItem (Config c) item =
    let
        liAttrs =
            noOpAttrs c.updateMenu c.li
    in
        case item of
            SubMenuItem { attributes, children } ->
                li (liAttrs ++ attributes) children


viewMenuLink : String -> String -> List (Attribute msg) -> Html msg
viewMenuLink title_ href_ attribs =
    a
        ([ title title_, href href_ ] ++ attribs)
        [ text title_ ]


viewMenuAction : msg -> String -> List (Attribute msg) -> Html msg
viewMenuAction msg title_ attribs =
    div
        ([ style [ ( "cursor", "pointer" ) ]
         , onWithOptions 
             "click"
             { stopPropagation = False, preventDefault = True } 
             (JD.succeed msg)
         ]
            ++ attribs
        )
        [ text title_ ]


viewMenuTitleAction : String -> HtmlDetails msg -> Html msg
viewMenuTitleAction title_ arrow =
    div
        [ style [ ( "cursor", "pointer" ) ]
        ]
        [ text title_
        , span arrow.attributes arrow.children
        ]



handleMenuEventsWith : (Msg -> msg) -> MenuEventsOn -> List (Attribute msg)
handleMenuEventsWith updateMenu eventsOn =
    case eventsOn of
        MouseEnter ->
            [ on "mouseenter" (JD.succeed (OpenMenu |> updateMenu))
            , on "mouseleave" (JD.succeed (CloseMenu |> updateMenu))
            ]
        Click ->
            [ onWithOptions 
                  "click" 
                  { stopPropagation = True, preventDefault = True } 
                  (JD.succeed (ToggleMenuState |> updateMenu))
            ]

handleSubMenuEventsWith : (Msg -> msg) -> MenuEventsOn -> Int -> List (Attribute msg)
handleSubMenuEventsWith updateMenu eventsOn index =
    case eventsOn of
        MouseEnter ->
            [ on "mouseenter" (JD.succeed (OpenSubMenu index |> updateMenu))
            , on "mouseleave" (JD.succeed (CloseSubMenu index |> updateMenu))
            ]
        Click ->
            [ onWithOptions 
                  "click" 
                  { stopPropagation = True, preventDefault = True } 
                  (JD.succeed (ToggleSubMenuState index |> updateMenu))
            ]


-- HELPERS

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

addAttributes : List (Attribute msg) -> HtmlDetails msg -> HtmlDetails msg
addAttributes attrs details =
    { details | attributes = (details.attributes ++ attrs) }



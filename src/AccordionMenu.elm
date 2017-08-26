module AccordionMenu
    exposing
        ( Menu
        , SubMenu
        , MenuItem
        , SubMenuItem
        , MenuState(..)
        , MenuEventsOn(..)
        , HtmlDetails
        , Msg
        , Config
        , update
        , view
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
        , customConfig
        , blankConfig
        , setMenuEventsOnHover
        , setMenuEventsOnClick
        , setOpenArrow
        , setCloseArrow
        , addListAttributes
        , addListItemAttributes
        , staticMenuAttributes
        , menuAttributes
        , staticMenuTitleAttributes
        , menuTitleAttributes
        , addMenuListAttributes
        , staticSubMenuAttributes
        , subMenuAttributes
        , staticSubMenuTitleAttributes
        , subMenuTitleAttributes
        , addSubMenuListAttributes
        )

{-| A library for designing expandable menus or other "accordion" interfaces.


# Features and constraints:

  - Menu items can be whatever you want. They have the msg type of your
    application. Builder functions are provided for common cases.

  - The only state managed by the menu is open/closed state. (If you want
    to keep track of the "last selected menu item" for instance, you do that
    within your application.)

  - Menus can respond to either clicks or hover (mouseenter/mouseleave).

  - Only a single submenu level is permitted. (But
    [what about a tree view?](#what-about-a-tree-view-))

  - Absolute minimum styling, with helpers for typical cases and more fine-
    grained styling via inline styles or classes.

See [Simple example](https://github.com/ericgj/elm-accordion-menu/blob/master/examples/Simple.elm)
for basic usage, and [live demo](https://ericgj.github.io/elm-accordion-menu/).


# Menu state

@docs MenuState


# Building the menu

@docs menu, separator, link, action, subMenu, customMenuItem

@docs subMenuLink, subMenuAction, customSubMenuItem

@docs Menu, MenuItem, SubMenu, SubMenuItem


# Displaying and updating the menu

@docs view, update, Msg

@docs closeMenu, closeSubMenus, closeMenuAndSubMenus, toggleMenu


# Configuring the menu

@docs blankConfig, customConfig, Config


## Open/close behavior

You can decide whether the menu and submenus should toggle open/closed when a
user clicks, or whether they should open when a user hovers (mouseenter) and
close when they move away (mouseleave).

@docs setMenuEventsOnHover, setMenuEventsOnClick, MenuEventsOn


## Open/close arrows

You may want to indicate the presence of a menu/submenu with an *arrow* (AKA
"caret"). This lets you specify separate arrows for opening and closing.
(Note these attributes and child nodes will be attached to a `span` node,
which by default is `display: inline`).

@docs HtmlDetails, setOpenArrow, setCloseArrow


## Top-level menu styling

Functions for adding attributes to the top-level menu container, to the
menu title, and to the menu list. You can either add attributes dependent on
current menu state, or regardless of menu state with the `static*` functions.

Note that for styling purposes, the higher-level setters in
`AccordionMenu.Style` are probably more useful.

@docs staticMenuAttributes, menuAttributes, staticMenuTitleAttributes, menuTitleAttributes

@docs addMenuListAttributes


## Submenu styling

Functions for adding attributes to all submenu containers, to the
submenu titles, and to the submenu lists. You can either add attributes
dependent on current submenu state, or regardless of submenu state with the
`static*` functions.

Note that for styling purposes, the higher-level setters in
`AccordionMenu.Style` are probably more useful.

@docs staticSubMenuAttributes, subMenuAttributes, staticSubMenuTitleAttributes, subMenuTitleAttributes

@docs addSubMenuListAttributes


## Generic list styling

You may have attributes to apply to *both* the top-level menu
list (`ul`) and list items (`li`), *and* all submenu lists and list items. Most
likely you will want to use the helpers in `AccordionMenu.Style` for setting
styles and classes, but these give you lower-level setters.

@docs addListAttributes, addListItemAttributes


# Q & A


## Do I really need a library for this?

Nope. The two main places it helps are with the opening and closing of menu
segments, and the absolute-positioning typically needed for menus. It doesn't
sound like a lot, but if you're like me, getting the UI right for these kinds
of things, in a cross-browser-compatible way, is a royal pain. This library
isn't quite there yet, but it's a start.

Eventually I hope to add some more UI improvements such as "bordered zones" to
deal with the infamous diagonal mouse-movement issues (see for instance this
[CSS-Tricks writeup](https://css-tricks.com/dropdown-menus-with-more-forgiving-mouse-movement-paths/)
).


## What about a tree view?

Having only a single level of submenu here is a *design decision*. Just because
it's easier (in some ways) to represent a structure as a tree, doesn't mean you
*should*.

Are you sure you want to inflict a hierarchical tree view on your users? Is
there not a better way?

Old, but still relevant:
["users prefer simple, flat lists"](https://blog.codinghorror.com/trees-treeviews-and-ui/)


## Can I animate opening and closing a menu?

With CSS. Example coming soon.

-}

import Json.Decode as JD
import Html exposing (..)
import Html.Attributes exposing (title, href, style)
import Html.Events exposing (onWithOptions, on)
import Html.Keyed


{-| A menu can be either open (i.e., its list of items are visible) or closed
(i.e., not visible). This describes both the state of the top-level menu, and
the state of submenus.
-}
type MenuState
    = Open
    | Closed


{-| How menus and submenus are opened/closed: with a mouse click or hover.
Specified in configuration.
-}
type MenuEventsOn
    = Hover
    | Click


{-| Top-level menu title, items, and current state
-}
type Menu msg
    = Menu
        { title : String
        , items : List (MenuItem msg)
        , state : MenuState
        }


{-| Submenu title, items, and current state
-}
type SubMenu msg
    = SubMenu
        { title : String
        , items : List (SubMenuItem msg)
        , state : MenuState
        }


{-| Top-level menu item
-}
type MenuItem msg
    = MenuItem String (HtmlDetails msg)
    | MenuSubMenu String (SubMenu msg)


{-| Submenu item. Cannot be a deeper submenu.
-}
type SubMenuItem msg
    = SubMenuItem String (HtmlDetails msg)


{-| Html attributes and child nodes. Used in specifying open/closed arrows in
configuration.
-}
type alias HtmlDetails msg =
    { attributes : List (Attribute msg)
    , children : List (Html msg)
    }


{-| Menu configuration
-}
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


{-| Construct a menu with the given title and list of menu items.

    AccordionMenu.menu "Instruments"
        [ AccordionMenu.link "Ukelele" "#/uke" []
        , AccordionMenu.link "Guitar" "#/guitar" []
        , AccordionMenu.link "Banjo" "#/banjo" []
        , AccordionMenu.separator "separator1" []
        , AccordionMenu.action Play "Play" []
        ]

-}
menu : String -> List (MenuItem msg) -> Menu msg
menu title_ items =
    Menu { title = title_, items = items, state = Closed }


{-| Construct a separator (`hr`) menu item with the given name and attributes.
(Note that the name given will be used to key the menu item to avoid any
virtual-dom confusion with multiple separators.)
-}
separator : String -> List (Attribute msg) -> MenuItem msg
separator key attrs =
    MenuItem
        key
        { attributes = []
        , children = [ hr attrs [] ]
        }


{-| Construct a link menu item with the given name, href, and attributes.
Clicking on this menu item will trigger standard browser navigation.
-}
link : String -> String -> List (Attribute msg) -> MenuItem msg
link title_ href_ attrs =
    MenuItem
        title_
        { attributes = []
        , children =
            [ viewMenuLink title_ href_ attrs ]
        }


{-| Construct an "action" menu item which triggers the given update msg, with
the given name and attributes.
-}
action : msg -> String -> List (Attribute msg) -> MenuItem msg
action msg title_ attrs =
    MenuItem
        title_
        { attributes = []
        , children =
            [ viewMenuAction msg title_ attrs ]
        }


{-| Construct a custom menu item with the given name (virtual-dom key), list of
attributes, and list of child nodes. Use this to define your own constructors
for more complex menu items, with multiple user interactions, etc.

    contactCardMenuItem : ContactInfo -> Image -> MenuItem Msg
    contactCardMenuItem contact url =
        customMenuItem
            contact.id
            []
            [ viewContactCard contact url ]

-}
customMenuItem : String -> List (Attribute msg) -> List (Html msg) -> MenuItem msg
customMenuItem key attributes children =
    MenuItem
        key
        { attributes = attributes
        , children = children
        }


{-| Construct a submenu with the given title and list of submenu items.

    AccordionMenu.menu "Instruments"
        [ AccordionMenu.subMenu "Brass"
            [ AccordionMenu.subMenuAction (Select id Trumpet) "Trumpet" []
            , AccordionMenu.subMenuAction (Select id Trombone) "Trombone" []
            ]
        ]

-}
subMenu : String -> List (SubMenuItem msg) -> MenuItem msg
subMenu title_ items =
    MenuSubMenu
        title_
        (SubMenu { title = title_, items = items, state = Closed })


{-| Same as `link`, except to construct a submenu item.
-}
subMenuLink : String -> String -> List (Attribute msg) -> SubMenuItem msg
subMenuLink title_ href_ attrs =
    SubMenuItem
        title_
        { attributes = []
        , children =
            [ viewMenuLink title_ href_ attrs ]
        }


{-| Same as `action`, except to construct a submenu item.
-}
subMenuAction : msg -> String -> List (Attribute msg) -> SubMenuItem msg
subMenuAction msg title_ attrs =
    SubMenuItem
        title_
        { attributes = []
        , children =
            [ viewMenuAction msg title_ attrs ]
        }


{-| Same as `customMenuItem`, except to construct a submenu item.
-}
customSubMenuItem : String -> List (Attribute msg) -> List (Html msg) -> SubMenuItem msg
customSubMenuItem key attributes children =
    SubMenuItem
        key
        { attributes = attributes
        , children = children
        }



-- CONFIG


{-| Construct a menu configuration with no styling and no arrows, with the given
update mapper function. Useful for building from a "blank slate" config with
setter functions, especially if you don't have all the config data in scope at
once.

Note that by default it constructs a config for a menu that responds to
clicks rather than mouse hover.

    AccordionMenu.blankConfig UpdateMenu
        |> AccordionMenu.setMenuEventsOnHover
        |> AccordionMenu.setOpenArrow myArrow
        |> AccordionMenu.setCloseArrow myArrow
        |> AccordionMenu.Style.resetListStyles
        |> ...

Configuration is passed into the `view` function.

-}
blankConfig : (Msg -> msg) -> Config msg
blankConfig updateMenu =
    customConfig
        { updateMenu = updateMenu
        , menuEventsOn = Click
        , openArrow = { attributes = [], children = [] }
        , closeArrow = { attributes = [], children = [] }
        , ul = []
        , li = []
        , menu = (\_ -> [])
        , menuTitle = (\_ -> [])
        , menuList = []
        , menuSubMenu = (\_ -> [])
        , subMenuTitle = (\_ -> [])
        , subMenuList = []
        }


{-| Construct menu configuration from scratch. Note it may be easier to
start with `blankConfig` and pipe setter functions onto it if you don't have
all the necessary data in scope at once.
-}
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


{-| Menu responds to clicks rather than mouse hover.
-}
setMenuEventsOnClick : Config msg -> Config msg
setMenuEventsOnClick =
    setMenuEventsOn Click


{-| Menu responds to mouse hover rather than clicks.
-}
setMenuEventsOnHover : Config msg -> Config msg
setMenuEventsOnHover =
    setMenuEventsOn Hover


setMenuEventsOn : MenuEventsOn -> Config msg -> Config msg
setMenuEventsOn eventsOn (Config config) =
    Config { config | menuEventsOn = eventsOn }


{-| Specify what a menu or submenu arrow (caret) should look like when the menu
is open.
-}
setOpenArrow : HtmlDetails Never -> Config msg -> Config msg
setOpenArrow details (Config config) =
    Config { config | openArrow = details }


{-| Specify what a menu or submenu arrow (caret) should look like when the menu
is closed.
-}
setCloseArrow : HtmlDetails Never -> Config msg -> Config msg
setCloseArrow details (Config config) =
    Config { config | closeArrow = details }


{-| Specify generic list (`ul`) attributes for all menus and submenus.
-}
addListAttributes : List (Attribute Never) -> Config msg -> Config msg
addListAttributes attrs (Config config) =
    customConfig { config | ul = config.ul ++ attrs }


{-| Specify generic list item (`li`) attributes for all menus and submenus.
-}
addListItemAttributes : List (Attribute Never) -> Config msg -> Config msg
addListItemAttributes attrs (Config config) =
    customConfig { config | li = config.li ++ attrs }


{-| Specify top-level menu container (`div`) attributes, as a function of the
current menu state (Open or Closed).
-}
menuAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
menuAttributes func (Config config) =
    customConfig { config | menu = func }


{-| Specify top-level menu container (`div`) attributes, ignoring current menu
state.
-}
staticMenuAttributes : List (Attribute Never) -> Config msg -> Config msg
staticMenuAttributes attrs (Config config) =
    customConfig { config | menu = (\_ -> attrs) }


{-| Specify top-level menu title (`div`) attributes, as a function of the
current menu state (Open or Closed).
-}
menuTitleAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
menuTitleAttributes func (Config config) =
    customConfig { config | menuTitle = func }


{-| Specify top-level menu title (`div`) attributes, ignoring current menu
state.
-}
staticMenuTitleAttributes : List (Attribute Never) -> Config msg -> Config msg
staticMenuTitleAttributes attrs (Config config) =
    customConfig { config | menuTitle = (\_ -> attrs) }


{-| Specify top-level menu list (`ul`) attributes.
-}
addMenuListAttributes : List (Attribute Never) -> Config msg -> Config msg
addMenuListAttributes attrs (Config config) =
    customConfig { config | menuList = config.menuList ++ attrs }


{-| Specify submenu container (`li`) attributes, as a function of the
current submenu state (Open or Closed).
-}
subMenuAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
subMenuAttributes func (Config config) =
    customConfig { config | menuSubMenu = func }


{-| Specify submenu container (`li`) attributes, ignoring current submenu
state.
-}
staticSubMenuAttributes : List (Attribute Never) -> Config msg -> Config msg
staticSubMenuAttributes attrs (Config config) =
    customConfig { config | menuSubMenu = (\_ -> attrs) }


{-| Specify submenu title (`div`) attributes, as a function of the
current submenu state (Open or Closed).
-}
subMenuTitleAttributes : (MenuState -> List (Attribute Never)) -> Config msg -> Config msg
subMenuTitleAttributes func (Config config) =
    customConfig { config | subMenuTitle = func }


{-| Specify subsubmenu title (`div`) attributes, ignoring current menu state.
-}
staticSubMenuTitleAttributes : List (Attribute Never) -> Config msg -> Config msg
staticSubMenuTitleAttributes attrs (Config config) =
    customConfig { config | subMenuTitle = (\_ -> attrs) }


{-| Specify submenu list (`ul`) attributes.
-}
addSubMenuListAttributes : List (Attribute Never) -> Config msg -> Config msg
addSubMenuListAttributes attrs (Config config) =
    customConfig { config | subMenuList = config.subMenuList ++ attrs }



-- UPDATE


{-| Msg type for internal menu updates
-}
type Msg
    = ToggleMenuState
    | ToggleSubMenuState Int
    | CloseMenu
    | CloseSubMenu Int
    | CloseSubMenus
    | OpenMenu
    | OpenSubMenu Int
    | NoOp


{-| Update menu state. This should be called from your application `update`,
using the same mapper msg you specify in the config.

    type Model =
        { menu : AccordionMenu.Menu Msg
        }

    config : AccordionMenu.Config Msg
    config =
        AccordionMenu.blankConfig UpdateMenu
            |> ....

    type Msg
       = UpdateMenu AccordionMenu.Msg
       | ...

    update : Msg -> Model -> Model
    update msg model
        case msg of
            UpdateMenu menuMsg ->
               { model | menu = AccordionMenu.update menuMsg model.menu }

            ...

    view : Model -> Html Msg
    view model =
        ...
            [ div [ class "menu" ]
                [ AccordionMenu.view config model.menu ]
            ]

See [Simple example](https://github.com/ericgj/elm-accordion-menu/blob/master/examples/Simple.elm)
for a more fully worked-out example.

-}
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
                            MenuSubMenu key (SubMenu submenu) ->
                                MenuSubMenu
                                    key
                                    (SubMenu { submenu | state = toggle submenu.state })

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
                            MenuSubMenu key (SubMenu submenu) ->
                                MenuSubMenu
                                    key
                                    (SubMenu { submenu | state = Open })

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


{-| Manually toggle menu state from Open to Closed or Closed to Open.
Not usually called from application code.
-}
toggleMenu : Menu msg -> Menu msg
toggleMenu (Menu menu) =
    Menu { menu | state = toggle menu.state }


{-| Manually close menu. This is useful if you want to close the menu after the
user clicks on a menu item, for instance.

    andCloseMenu : Model -> Model
    andCloseMenu model =
        { model | menu = AccordionMenu.closeMenu model.menu }

    update : Msg -> Model -> Model
    update msg model
        case msg of
            SelectMenuItem item ->
               { model | selectedItem = item }
                   |> andCloseMenu

            ...

-}
closeMenu : Menu msg -> Menu msg
closeMenu (Menu menu) =
    Menu { menu | state = Closed }


closeSubMenu : Int -> Menu msg -> Menu msg
closeSubMenu index (Menu menu) =
    let
        closeSubMenuAt i item =
            if i == index then
                case item of
                    MenuSubMenu key (SubMenu submenu) ->
                        MenuSubMenu key (SubMenu { submenu | state = Closed })

                    _ ->
                        item
            else
                item
    in
        Menu { menu | items = List.indexedMap closeSubMenuAt menu.items }


{-| Manually close all submenus. This is useful if you want to close all
submenus after the user clicks on a submenu item, but want to keep the main
menu open.

    andCloseSubMenus : Model -> Model
    andCloseSubMenus model =
        { model | menu = AccordionMenu.closeSubMenus model.menu }

    update : Msg -> Model -> Model
    update msg model
        case msg of
            SelectMenuItem item ->
               { model | selectedItem = item }
                   |> andCloseSubMenus

            ...

-}
closeSubMenus : Menu msg -> Menu msg
closeSubMenus (Menu menu) =
    let
        closeSubMenu item =
            case item of
                MenuSubMenu key (SubMenu submenu) ->
                    MenuSubMenu key (SubMenu { submenu | state = Closed })

                _ ->
                    item
    in
        Menu { menu | items = List.map closeSubMenu menu.items }


{-| Manually close all submenus and the main menu, resetting the menu to its
default state. This is useful if you want "zip up everything" after the user
clicks on a menu or submenu item.

    andCloseAll : Model -> Model
    andCloseAll model =
        { model | menu = AccordionMenu.closeMenuAndSubMenus model.menu }

    update : Msg -> Model -> Model
    update msg model
        case msg of
            SelectMenuItem item ->
               { model | selectedItem = item }
                   |> andCloseAll

            ...

-}
closeMenuAndSubMenus : Menu msg -> Menu msg
closeMenuAndSubMenus =
    closeSubMenus >> closeMenu


openMenu : Menu msg -> Menu msg
openMenu (Menu menu) =
    Menu { menu | state = Open }



-- VIEW


{-| The menu view. Pass in configuration and menu data.
-}
view : Config msg -> Menu msg -> Html msg
view (Config c) (Menu { title, items, state }) =
    let
        handlers =
            handleMenuEventsWith c.updateMenu c.menuEventsOn
    in
        div
            (handlers ++ (noOpAttrs c.updateMenu (c.menu state)))
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
    Html.Keyed.ul (noOpAttrs c.updateMenu (c.ul ++ c.menuList))
        (List.indexedMap (viewMenuItem (Config c)) menuItems)


viewMenuItem :
    Config msg
    -> Int
    -> MenuItem msg
    -> ( String, Html msg )
viewMenuItem (Config c) index item =
    let
        liAttrs =
            noOpAttrs c.updateMenu c.li

        handlers index =
            handleSubMenuEventsWith c.updateMenu c.menuEventsOn index
    in
        case item of
            MenuItem key { attributes, children } ->
                ( key
                , li (liAttrs ++ attributes) children
                )

            MenuSubMenu key (SubMenu { title, items, state }) ->
                ( key
                , li
                    ((handlers index)
                        ++ (noOpAttrs c.updateMenu (c.menuSubMenu state))
                        ++ liAttrs
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
    Html.Keyed.ul (noOpAttrs c.updateMenu (c.ul ++ c.subMenuList))
        (List.map (viewSubMenuItem (Config c)) items)


viewSubMenuItem :
    Config msg
    -> SubMenuItem msg
    -> ( String, Html msg )
viewSubMenuItem (Config c) item =
    let
        liAttrs =
            noOpAttrs c.updateMenu c.li
    in
        case item of
            SubMenuItem key { attributes, children } ->
                ( key
                , li (liAttrs ++ attributes) children
                )


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
        Hover ->
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
        Hover ->
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

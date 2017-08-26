module AccordionMenu.Style
    exposing
        ( absolutePositioned
        , resetListStyles
        , listClass
        , listStyles
        , listItemClass
        , listItemStyles
        , staticMenuClass
        , staticMenuStyles
        , menuClass
        , menuClasses
        , menuStyles
        , staticMenuTitleClass
        , staticMenuTitleStyles
        , menuTitleClass
        , menuTitleClasses
        , menuTitleStyles
        , menuListClass
        , menuListStyles
        , staticSubMenuClass
        , staticSubMenuStyles
        , subMenuClass
        , subMenuClasses
        , subMenuStyles
        , staticSubMenuTitleClass
        , staticSubMenuTitleStyles
        , subMenuTitleClass
        , subMenuTitleClasses
        , subMenuTitleStyles
        , subMenuListClass
        , subMenuListStyles
        )

{-| Helper functions for styling menus.

All these helpers are intended to be piped onto `AccordionMenu.Config`
instances.

Example usage with inline styles:

    AccordionMenu.blankConfig UpdateMenu
        |> Style.resetListStyles
        |> Style.listItemStyles styleListItems
        |> Style.absolutePositioned styleMenuList
        |> Style.staticMenuStyles styleMenu
        |> Style.menuTitleStyles styleMenuTitle
        |> Style.menuListStyles styleMenuList
        |> Style.subMenuTitleStyles styleMenuTitle

Example usage with CSS classes:

    AccordionMenu.blankConfig UpdateMenu
        |> Style.listClass "dropdown"
        |> Style.menuClasses
            (\state ->
                [ ("menu-container",True)
                , ("menu-open", state == AccordionMenu.Open)
                , ("menu-closed", state == AccordionMenu.Closed)
                ]
            )
        |> Style.staticMenuTitleClass "menu-title"
        |> Style.menuListClass "menu-list"
        |> Style.subMenuClasses
            (\state ->
                [ ("menu-submenu-container",True)
                , ("menu-submenu-open", state == AccordionMenu.Open)
                , ("menu-submenu-closed", state == AccordionMenu.Closed)
                ]
            )


# "Porcelain" styling

These are shortcuts for typical combinations of styles, resets, etc. They still
are very minimalistic, leaving all but the most basic structural styling to the
application designer.

@docs absolutePositioned, resetListStyles


# Finer-grained styling

Helpers for setting inline styles or CSS class(es) on various elements of the
menu.


## Top-level menu

@docs staticMenuClass , staticMenuStyles , menuClass , menuClasses , menuStyles


## Top-level menu title

@docs staticMenuTitleClass , staticMenuTitleStyles , menuTitleClass , menuTitleClasses , menuTitleStyles


## Top-level menu list

@docs menuListClass , menuListStyles


## Submenu

@docs staticSubMenuClass , staticSubMenuStyles , subMenuClass , subMenuClasses , subMenuStyles


## Submenu title

@docs staticSubMenuTitleClass , staticSubMenuTitleStyles , subMenuTitleClass , subMenuTitleClasses , subMenuTitleStyles


## Submenu list

@docs subMenuListClass , subMenuListStyles


## Lists and list items in general

@docs listClass , listStyles , listItemClass , listItemStyles

-}

import Html exposing (Attribute)
import Html.Attributes exposing (style, class, classList)
import AccordionMenu exposing (..)


-- PORCELAIN


{-| Set up the styles for the menu list to be absolute-positioned under its
container, i.e. so it looks like a menu, sticking out of the document flow.

Note that if you use this, you should not set further styles on the menu
container, but pass them in as the first parameter.

Also note you will likely want to set the menu list `top` (or `translateY`) to
at least the height of the menu title, so the list appears below the title
instead of obscuring it.

    myConfig
        |> absolutePositioned otherMenuStyles
        |> menuListStyles [ ("top", "30px") ]

-}
absolutePositioned : List ( String, String ) -> Config msg -> Config msg
absolutePositioned styles config =
    config
        |> staticMenuStyles
            (styles
                ++ [ ( "position", "relative" )
                   ]
            )
        |> menuListStyles
            [ ( "position", "absolute" )
            , ( "top", "0" )
            , ( "left", "0" )
            , ( "width", "100%" )
            ]


{-| A reset for all menu lists (`ul`). Removes `padding` and `margin` and
`list-style-type`.
-}
resetListStyles : Config msg -> Config msg
resetListStyles config =
    config
        |> listStyles
            [ ( "list-style-type", "none" )
            , ( "margin", "0" )
            , ( "padding", "0" )
            , ( "-webkit-margin-before", "0" )
            , ( "-webkit-margin-after", "0" )
            , ( "-webkit-padding-start", "0" )
            ]



-- FINER-GRAINED UPDATES


{-| Set CSS class for all menu lists (`ul`).
-}
listClass : String -> Config msg -> Config msg
listClass class_ config =
    addListAttributes [ class class_ ] config


{-| Set inline styles for all menu lists (`ul`).
-}
listStyles : List ( String, String ) -> Config msg -> Config msg
listStyles styles config =
    addListAttributes [ style styles ] config


{-| Set CSS class for all menu list items (`li`).
-}
listItemClass : String -> Config msg -> Config msg
listItemClass class_ config =
    addListItemAttributes [ class class_ ] config


{-| Set inline styles for all menu list items (`li`).
-}
listItemStyles : List ( String, String ) -> Config msg -> Config msg
listItemStyles styles config =
    addListItemAttributes [ style styles ] config


{-| Set CSS class for menu container (`div`), ignoring menu state.
-}
staticMenuClass : String -> Config msg -> Config msg
staticMenuClass class_ config =
    staticMenuAttributes [ class class_ ] config


{-| Set inline styles for menu container (`div`), ignoring menu state.
-}
staticMenuStyles : List ( String, String ) -> Config msg -> Config msg
staticMenuStyles styles config =
    staticMenuAttributes [ style styles ] config


{-| Set CSS class for menu container (`div`), as a function of menu state.
-}
menuClass : (MenuState -> String) -> Config msg -> Config msg
menuClass func config =
    menuAttributes (func >> (\class_ -> [ class class_ ])) config


{-| Set CSS classes for menu container (`div`), as a function of menu state.
-}
menuClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
menuClasses func config =
    menuAttributes (func >> (\classes -> [ classList classes ])) config


{-| Set inline styles for menu container (`div`), as a function of menu state.
-}
menuStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
menuStyles func config =
    menuAttributes (func >> (\styles -> [ style styles ])) config


{-| Set CSS class for menu title (`div`), ignoring menu state.
-}
staticMenuTitleClass : String -> Config msg -> Config msg
staticMenuTitleClass class_ config =
    staticMenuTitleAttributes [ class class_ ] config


{-| Set inline styles for menu title (`div`), ignoring menu state.
-}
staticMenuTitleStyles : List ( String, String ) -> Config msg -> Config msg
staticMenuTitleStyles styles config =
    staticMenuTitleAttributes [ style styles ] config


{-| Set CSS class for menu title (`div`), as a function of menu state.
-}
menuTitleClass : (MenuState -> String) -> Config msg -> Config msg
menuTitleClass func config =
    menuTitleAttributes (func >> (\class_ -> [ class class_ ])) config


{-| Set CSS classes for menu title (`div`), as a function of menu state.
-}
menuTitleClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
menuTitleClasses func config =
    menuTitleAttributes (func >> (\classes -> [ classList classes ])) config


{-| Set inline styles for menu title (`div`), as a function of menu state.
-}
menuTitleStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
menuTitleStyles func config =
    menuTitleAttributes (func >> (\styles -> [ style styles ])) config


{-| Set CSS class for menu list (`ul`).
-}
menuListClass : String -> Config msg -> Config msg
menuListClass class_ config =
    addMenuListAttributes [ class class_ ] config


{-| Set inline styles for menu list (`ul`).
-}
menuListStyles : List ( String, String ) -> Config msg -> Config msg
menuListStyles styles config =
    addMenuListAttributes [ style styles ] config


{-| Set CSS class for submenu container (`li`), ignoring menu state.
-}
staticSubMenuClass : String -> Config msg -> Config msg
staticSubMenuClass class_ config =
    staticSubMenuAttributes [ class class_ ] config


{-| Set inline styles for submenu container (`li`), ignoring menu state.
-}
staticSubMenuStyles : List ( String, String ) -> Config msg -> Config msg
staticSubMenuStyles styles config =
    staticSubMenuAttributes [ style styles ] config


{-| Set CSS class for submenu container (`li`), as a function of submenu state.
-}
subMenuClass : (MenuState -> String) -> Config msg -> Config msg
subMenuClass func config =
    subMenuAttributes (func >> (\class_ -> [ class class_ ])) config


{-| Set CSS classes for submenu container (`li`), as a function of submenu state.
-}
subMenuClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
subMenuClasses func config =
    subMenuAttributes (func >> (\classes -> [ classList classes ])) config


{-| Set inline styles for submenu container (`li`), as a function of submenu state.
-}
subMenuStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
subMenuStyles func config =
    subMenuAttributes (func >> (\styles -> [ style styles ])) config


{-| Set CSS class for submenu title (`div`), ignoring submenu state.
-}
staticSubMenuTitleClass : String -> Config msg -> Config msg
staticSubMenuTitleClass class_ config =
    staticSubMenuTitleAttributes [ class class_ ] config


{-| Set inline styles for submenu title (`div`), ignoring submenu state.
-}
staticSubMenuTitleStyles : List ( String, String ) -> Config msg -> Config msg
staticSubMenuTitleStyles styles config =
    staticSubMenuTitleAttributes [ style styles ] config


{-| Set CSS class for submenu title (`div`), as a function of submenu state.
-}
subMenuTitleClass : (MenuState -> String) -> Config msg -> Config msg
subMenuTitleClass func config =
    subMenuTitleAttributes (func >> (\class_ -> [ class class_ ])) config


{-| Set CSS classes for submenu title (`div`), as a function of submenu state.
-}
subMenuTitleClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
subMenuTitleClasses func config =
    subMenuTitleAttributes (func >> (\classes -> [ classList classes ])) config


{-| Set inline styles for submenu title (`div`), as a function of submenu state.
-}
subMenuTitleStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
subMenuTitleStyles func config =
    subMenuTitleAttributes (func >> (\styles -> [ style styles ])) config


{-| Set CSS class for submenu list (`ul`).
-}
subMenuListClass : String -> Config msg -> Config msg
subMenuListClass class_ config =
    addSubMenuListAttributes [ class class_ ] config


{-| Set inline styles for submenu list (`ul`).
-}
subMenuListStyles : List ( String, String ) -> Config msg -> Config msg
subMenuListStyles styles config =
    addSubMenuListAttributes [ style styles ] config

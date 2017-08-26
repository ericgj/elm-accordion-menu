module AccordionMenu.Style
    exposing
        ( blankConfig
        , absolutePositioned
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
        , subMenuTitleClass
        , subMenuTitleClasses
        , subMenuTitleStyles
        , subMenuListClass
        , subMenuListStyles
        )

import Html exposing (Attribute)
import Html.Attributes exposing (style, class, classList)
import AccordionMenu exposing (..)


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



-- PORCELAIN


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


listClass : String -> Config msg -> Config msg
listClass class_ config =
    addListAttributes [ class class_ ] config


listStyles : List ( String, String ) -> Config msg -> Config msg
listStyles styles config =
    addListAttributes [ style styles ] config


listItemClass : String -> Config msg -> Config msg
listItemClass class_ config =
    addListItemAttributes [ class class_ ] config


listItemStyles : List ( String, String ) -> Config msg -> Config msg
listItemStyles styles config =
    addListItemAttributes [ style styles ] config


staticMenuClass : String -> Config msg -> Config msg
staticMenuClass class_ config =
    staticMenuAttributes [ class class_ ] config


staticMenuStyles : List ( String, String ) -> Config msg -> Config msg
staticMenuStyles styles config =
    staticMenuAttributes [ style styles ] config


menuClass : (MenuState -> String) -> Config msg -> Config msg
menuClass func config =
    menuAttributes (func >> (\class_ -> [ class class_ ])) config


menuClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
menuClasses func config =
    menuAttributes (func >> (\classes -> [ classList classes ])) config


menuStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
menuStyles func config =
    menuAttributes (func >> (\styles -> [ style styles ])) config


menuTitleClass : (MenuState -> String) -> Config msg -> Config msg
menuTitleClass func config =
    menuTitleAttributes (func >> (\class_ -> [ class class_ ])) config


menuTitleClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
menuTitleClasses func config =
    menuTitleAttributes (func >> (\classes -> [ classList classes ])) config


menuTitleStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
menuTitleStyles func config =
    menuTitleAttributes (func >> (\styles -> [ style styles ])) config


menuListClass : String -> Config msg -> Config msg
menuListClass class_ config =
    addMenuListAttributes [ class class_ ] config


menuListStyles : List ( String, String ) -> Config msg -> Config msg
menuListStyles styles config =
    addMenuListAttributes [ style styles ] config


staticSubMenuClass : String -> Config msg -> Config msg
staticSubMenuClass class_ config =
    staticSubMenuAttributes [ class class_ ] config


staticSubMenuStyles : List ( String, String ) -> Config msg -> Config msg
staticSubMenuStyles styles config =
    staticSubMenuAttributes [ style styles ] config


subMenuClass : (MenuState -> String) -> Config msg -> Config msg
subMenuClass func config =
    subMenuAttributes (func >> (\class_ -> [ class class_ ])) config


subMenuClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
subMenuClasses func config =
    subMenuAttributes (func >> (\classes -> [ classList classes ])) config


subMenuStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
subMenuStyles func config =
    subMenuAttributes (func >> (\styles -> [ style styles ])) config


subMenuTitleClass : (MenuState -> String) -> Config msg -> Config msg
subMenuTitleClass func config =
    subMenuTitleAttributes (func >> (\class_ -> [ class class_ ])) config


subMenuTitleClasses : (MenuState -> List ( String, Bool )) -> Config msg -> Config msg
subMenuTitleClasses func config =
    subMenuTitleAttributes (func >> (\classes -> [ classList classes ])) config


subMenuTitleStyles : (MenuState -> List ( String, String )) -> Config msg -> Config msg
subMenuTitleStyles func config =
    subMenuTitleAttributes (func >> (\styles -> [ style styles ])) config


subMenuListClass : String -> Config msg -> Config msg
subMenuListClass class_ config =
    addSubMenuListAttributes [ class class_ ] config


subMenuListStyles : List ( String, String ) -> Config msg -> Config msg
subMenuListStyles styles config =
    addSubMenuListAttributes [ style styles ] config

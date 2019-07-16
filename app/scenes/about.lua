
-- -----------------------------------------------------------------------------------
-- Las funciones de evento de código fuera de la escena a continuación solo se ejecutarán UNA VEZ a menos que
-- la escena se elimina por completo (no se recicla) a través de "composer.removeScene ()"
-- -----------------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
local ui = require("plugin.ui_framework")
local json = require("json")

-- -----------------------------------------------------------------------------------
-- Borramos las escenas ocultas
-- -----------------------------------------------------------------------------------
composer.removeHidden()

-- -----------------------------------------------------------------------------------
-- Importamos librerias
-- -----------------------------------------------------------------------------------
local screen = require("utils.screen")
local console = require("utils.console")
local color = require("utils.color")
local U = require("utils.components")


-- -----------------------------------------------------------------------------------
-- incluimos el archivo de configuracion con los textos
-- -----------------------------------------------------------------------------------
local store = require( "utils.store" )
local config = store.loadTable("storage/config.json",system.ResourceDirectory)

-- ---------------------------------------------
-- iniciamos las variables
-- ---------------------------------------------
local background,header,nav,sheet,myAnimation,h1,p,githubBtn

-- ---------------------------------------------
-- metodo para volver al inicio
-- ---------------------------------------------
local backToTheHome = function(event)
    if event.phase == "ended" then
        composer.gotoScene( "scenes.init", {effect = "fromBottom",time = 200})
    end
end







-- -----------------------------------------------------------------------------------
-- Metodos de Escena
-- -----------------------------------------------------------------------------------

-- ---------------------------------------------
-- Creamos la Escena
-- Se definen los elementos a enseñar
-- ---------------------------------------------
function scene:create( event )
    -- creamos el grupo de la escena
    local sceneGroup = self.view
    -- iniciamos el ui framework 
    ui:init({enable={loader=true}})

    -- craemos el fondo
    background = display.newRect(0,0,360, 570)
    background.x = screen.centerX
    background.y = screen.centerY
    background:setFillColor(unpack(ui.colors.white))

    -- creamos el fondo de la parte de arriba del navbar
    header = display.newRect(0,0,360, 67)
    header.x = screen.centerX
    header.y = screen.top+header.height/2
    header.height = 70
    header:setFillColor(unpack(ui.colors.purpleDark))

    -- navegacion
    nav = U.navbar(ui,{
        title=config.about.name,
        buttons = {
            left = { 
                config = { 
                    style = "back", touchCallback = backToTheHome
                },
                label = {text = "Volver"} 
            },
        }
    })
    nav.x = screen.centerX
    nav.y = screen.top + 50

    -- agrupaos
    sceneGroup:insert(background)
    sceneGroup:insert(header)
    sceneGroup:insert(nav)

end
 

-- ---------------------------------------------
-- Enseñamos la Escena
-- Antes de que carge (will) creamos el resto
-- de objetos que se veran
-- ---------------------------------------------
function scene:show( event )

    local sceneGroup = self.view

    if ( event.phase == "will" ) then

        --ui.newLoader({tag = "list_loader",config = { x = screen.centerX,y = screen.centerY}})

        -- animation
        sheet = graphics.newImageSheet( config.dance, {
            width=300,
            height=300,
            numFrames=4,
            sheetContentWidth=300,
            sheetContentHeight=1200
        })
        -- sprite
        myAnimation = display.newSprite( sheet, {
            name="hello",
            frames= { 1,2,3,4 },
            time = 1000,
        })
        myAnimation.x = screen.centerX
        myAnimation.y = screen.top+header.height*3.4
        myAnimation:play()

        -- titulo
        h1 = display.newText("", 0, 0, native.systemFontBold, 14 )
        h1.text = config.about.title
        h1.x = screen.centerX
        h1.y = myAnimation.height*1.2
        h1:setFillColor(unpack(ui.colors.black))
        transition.from(h1,{time=500,alpha=0})

        -- descripcion
        p = display.newText("", 0, 0, native.systemFont, 13 )
        p.text = config.about.description
        p.x = screen.centerX
        p.y = h1.y+25
        p:setFillColor(unpack(ui.colors.grayDarkExtra))
        transition.from(p,{delay=300,time=500,alpha=0})
        -- boton
        githubBtn = ui.newButton( { 
            config = { 
                style = "flat_fill",
                touchCallback = function(event)
                    if event.phase == "ended" then
                        system.openURL(config.about.url)
                        return true
                    end
                end
            }, 
            label = {
                text = "Github"
            }
        })
        githubBtn.x = screen.centerX
        githubBtn.y = p.y+40
        transition.from(githubBtn,{delay=500,time=500,y=screen.bottom+100})


        -- agrupamos el resto
        sceneGroup:insert(myAnimation)
        sceneGroup:insert(h1)
        sceneGroup:insert(p)
        sceneGroup:insert(githubBtn)

    elseif ( event.phase == "did" ) then
        -- ocultamos el cargador
        --ui.removeLoader('list_loader')

        background:addEventListener("touch", function() return true end)
        header:addEventListener("touch", function() return true end)
        nav:addEventListener("touch", function() return true end)
        myAnimation:addEventListener("touch", function() return true end)
        h1:addEventListener("touch", function() return true end)
        p:addEventListener("touch", function() return true end)
        githubBtn:addEventListener("touch", function() return true end)

        background:addEventListener("enterFrame", function() return true end)
        header:addEventListener("enterFrame", function() return true end)
        nav:addEventListener("enterFrame", function() return true end)
        myAnimation:addEventListener("enterFrame", function() return true end)
        h1:addEventListener("enterFrame", function() return true end)
        p:addEventListener("enterFrame", function() return true end)
        githubBtn:addEventListener("enterFrame", function() return true end)
    end
end
 
 
-- ---------------------------------------------
-- Ocultamos la Escena
-- Antes de que oculte (will) la escena está a punto de desaparecer
-- después (did) la escena se apaga por completo
-- ---------------------------------------------
function scene:hide( event )
    local sceneGroup = self.view
    if ( event.phase == "will" ) then
        -- El código aquí se ejecuta cuando la escena está en la pantalla (pero está a punto de desaparecer)
    elseif ( event.phase == "did" ) then
        -- El código aquí se ejecuta inmediatamente después de que la escena se apaga por completo.
        
        -- borramos la estuctura
        background.removeSelf()
        background = nil

        header.removeSelf()
        header = nil

        nav.removeSelf()
        nav = nil

        sheet.removeSelf()
        sheet = nil

        myAnimation.removeSelf()
        myAnimation = nil

        h1.removeSelf()
        h1 = nil

        p.removeSelf()
        p = nil

        githubBtn.removeSelf()
        githubBtn = nil


        config = nil
        backToTheHome = nil

        background:removeEventListener("touch", function() return true end)
        header:removeEventListener("touch", function() return true end)
        nav:removeEventListener("touch", function() return true end)
        myAnimation:removeEventListener("touch", function() return true end)
        h1:removeEventListener("touch", function() return true end)
        p:removeEventListener("touch", function() return true end)
        githubBtn:removeEventListener("touch", function() return true end)

        background:removeEventListener("enterFrame", function() return true end)
        header:removeEventListener("enterFrame", function() return true end)
        nav:removeEventListener("enterFrame", function() return true end)
        myAnimation:removeEventListener("enterFrame", function() return true end)
        h1:removeEventListener("enterFrame", function() return true end)
        p:removeEventListener("enterFrame", function() return true end)
        githubBtn:removeEventListener("enterFrame", function() return true end)
    end
end
 
 
-- ---------------------------------------------
-- Destruimos la escena
-- ---------------------------------------------
function scene:destroy( event )
    local sceneGroup = self.view
    -- El código aquí se ejecuta antes de la eliminación de la vista de la escena.
    sceneGroup:removeSelf()
    sceneGroup = nil
end
 
 
-- -----------------------------------------------------------------------------------
-- Escuchas de eventos de escena
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene
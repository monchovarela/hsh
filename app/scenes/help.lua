
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
-- iniciamos las variables de la estructura
-- ---------------------------------------------
local background,header,nav

-- ---------------------------------------------
-- iniciamos las variables de los objetos
-- ---------------------------------------------
local html

-- ---------------------------------------------
-- metodo para volver al inicio
-- ---------------------------------------------
local backToTheHome = function(event)
    if event.phase == "ended" then
        composer.gotoScene( "scenes.init", {effect = "fromBottom",time = 200})
    end
end

-- ---------------------------------------------
-- metodo del webview
-- ---------------------------------------------
local onLoadWebview = function(event)
    -- ocultamos el cargador
    ui.removeLoader('list_loader')
    if event.url then
        print( "You are visiting: " .. event.url )
    end
    if event.errorCode then
        native.showAlert( "Error!", event.errorMessage, { "OK" } )
    end
    return true
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
        title=config.help.name,
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

    -- agrupamos 
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
        ui.newLoader({tag = "list_loader",config = { x = screen.centerX,y = screen.centerY}})
    elseif ( event.phase == "did" ) then
        
        -- cargamos el webview
        html = U.loadHtml(config.help.webview,onLoadWebview)
        html.y = nav.height - 23
        html.x = screen.centerX
        html.width = screen.width + 10
        html.height = screen.height+23
        html.anchorY = 0


        html:addEventListener("touch", function() return true end)
        background:addEventListener("touch", function() return true end)
        header:addEventListener("touch", function() return true end)
        nav:addEventListener("touch", function() return true end)

        html:addEventListener("enterFrame", function() return true end)
        background:addEventListener("enterFrame", function() return true end)
        header:addEventListener("enterFrame", function() return true end)
        nav:addEventListener("enterFrame", function() return true end)

        sceneGroup:insert(html)
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

        html.removeSelf()
        html = nil
        
        html:removeEventListener("touch", function() return true end)
        background:removeEventListener("touch", function() return true end)
        header:removeEventListener("touch", function() return true end)
        nav:removeEventListener("touch", function() return true end)

        html:removeEventListener("enterFrame", function() return true end)
        background:removeEventListener("enterFrame", function() return true end)
        header:removeEventListener("enterFrame", function() return true end)
        nav:removeEventListener("enterFrame", function() return true end)
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
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene
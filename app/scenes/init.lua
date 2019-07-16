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
local background,header,bg,navigation,nav_bg,links,nav,infoText,search,modal,card,btn


-- ---------------------------------------------
-- Metodo para enseñar o ocultar la navegacion
-- ---------------------------------------------
local function toogleNav(event)
    if event.phase == "ended" then
        if navigation.isVisible == true then
            transition.to(navigation,{time=200,x=-200,onComplete=function()
                navigation.isVisible = false
            end})
        else
            navigation.isVisible = true
            transition.to(navigation,{time=200,x=0})
        end
    end
    return true
end


-- ---------------------------------------------------
-- Metodo para enseñar o ocultar la barra de busqueda
-- ---------------------------------------------------
local function toogleSearch(event)
    if event.phase == "ended" then
        if search.isVisible == false then
            navigation.isVisible = false
            search.isVisible = true
            transition.from(search,{time=200,x=screen.width,onComplete=function()
                search:setFocus() 
            end})
        end
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

    ui:addColor("purple", {color.set("#6B07B2")}) 
    ui:addColor("purpleDark", {color.set("#7741AD")})
    ui:addColor("grayLite", {color.set("#fdfdfd")})

    -- iniciamos el ui framework 
    ui:init({
        primaryColor = "purple",
        secondaryColor = "white",
        enable={
            loader=true
        }})

    -- craemos el fondo
    background = display.newRect(0,0,360, 570)
    background.x = screen.centerX
    background.y = screen.centerY
    background:setFillColor(unpack(ui.colors.grayLite))

    -- creamos el fondo de la parte de arriba del navbar
    header = display.newRect(0,0,360, 67)
    header.x = screen.centerX
    header.y = screen.top+header.height/2
    header.height = 70
    header:setFillColor(unpack(ui.colors.purpleDark))

   -- barra de navegacion
    nav = U.navbar(ui,{
        title=config.init.name,
        buttons = {
            left = {config = { style = "icon", touchCallback = toogleNav}, icon = {text = ui.fonts.icon.menu} },
            right = {
                {config = { style = "icon", touchCallback = toogleSearch}, icon = {text = ui.fonts.icon.search} }
            }
        }
    })
    nav.x = screen.centerX
    nav.y = screen.top + 50

    -- agrupamos todo
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

        -- navigacion
        navigation = display.newGroup()
        navigation.y = screen.top+header.height + 3
        navigation.x = -200
        navigation.isVisible = false

        -- fondo navegacion
        nav_bg = display.newRect(navigation,0,0,screen.width/2,screen.height)
        nav_bg.anchorX = 0
        nav_bg.anchorY = 0
        nav_bg.height = screen.height+header.height
        nav_bg:setFillColor(unpack(ui.colors.white))

        -- creamos los enlaces del menu
        U.createLinks(ui,navigation,{
            {
                name = config.links.help,
                icon = ui.fonts.icon.info,
                listener = function(event)
                    if event.phase == "ended" then
                        transition.to(navigation,{time=200,x=-200,onComplete=function()
                            composer.gotoScene( "scenes.help", {effect = "slideDown",time = 200})
                            navigation.isVisible = false
                        end})
                    end
                    return true
                end
            },
            {
                name = config.links.aboutus,
                icon = ui.fonts.icon.account,
                listener = function(event)
                    if event.phase == "ended" then
                        transition.to(navigation,{time=200,x=-200,onComplete=function()
                            composer.gotoScene( "scenes.about", {effect = "slideDown",time = 200})
                            navigation.isVisible = false
                        end})
                    end
                    return true
                end
            }
        })

        -- mas iconos
        --console.log(ui.fonts.icon)

        -- barra de busqueda
        modal = display.newGroup()
        search = U.search(ui,{
            placeholder = config.search,
            onEdit = function(a) return true end,
            onSubmit = function(mail)
                -- is hay texto escrito
                if mail ~= " " and #mail > 3 then
                    -- enseñamos que esta buscando
                    U.notif(ui,{title=config.init.modal.search})
                    -- enseñamos el loader
                    ui.newLoader({tag = "list_loader",config = { x = screen.centerX,y = screen.centerY}})
                    
                    U.request(ui,{
                        parent = modal,
                        url = config.url,
                        mail = mail,
                        listener = function(event)

                            -- ocultamos el cargador
                            ui.removeLoader('list_loader')

                            local response = {}

                            local desc = ""
                            local showMore = false
                            if event.status == 200 then
                                showMore = true
                                desc = string.format(config.init.modal.description, #json.decode(event.response))
                                response = event.response
                            else
                                desc = config.init.modal.nomatches
                            end
      
                            -- enseñamos la tarjeta 
                            U.card(ui,{
                                parent=modal,
                                title=config.init.modal.title,
                                subtitle = config.init.modal.subtitle.." "..mail,
                                description = desc,
                                btn = config.close,
                                showMore = showMore,
                                showMoreBtn = config.init.modal.showmore,
                                showMoreCallback = function(event)
                                    if event.phase == "ended" then
                                        composer.gotoScene( "scenes.results", {
                                            effect = "slideDown",
                                            time = 200,
                                            params = {
                                                mail = mail,
                                                data = response
                                            }
                                        })
                                    end
                                    return true
                                end
                            })
                            
                            return true
                        end
                    })
                end
                return true
            end
        })

        -- imagen de cabecera
        bg = display.newImage(config.header_image,system.ResourceDirectory,0,0)
        bg.x = screen.centerX
        bg.y = screen.top + 180
        bg.width = screen.width
        bg.height = screen.width/1.5

        bg.fill.effect = "filter.opTile"
         
        transition.from(bg.fill.effect,{time=500,numPixels = 50,angle = 45,scale = 2,onComplete=function() 
            bg.fill.effect.numPixels = 1
            bg.fill.effect.angle = 0
            bg.fill.effect.scale = 0
        end})

        -- texto informativo
        infoText = display.newText("",0,0,native.systemFont,16)
        infoText.text = config.init.description
        infoText.y = bg.height*1.67
        infoText.x = screen.centerX
        infoText.align = "left"
        infoText:setFillColor(unpack(ui.colors.black))

        -- boton comprobar
        btn = ui.newButton( { 
            config = { 
                style = "raised_fill",
                touchCallback = toogleSearch
            }, 
            label = {
                text = config.init.btn
            } 
        } )
        btn.x = screen.centerX
        btn.y = (infoText.y + (infoText.height/2)) + 25
         
        transition.from(btn,{delay=500,time=500,y=screen.bottom+100})

        -- agrupamos
        sceneGroup:insert(infoText)
        sceneGroup:insert(search)
        sceneGroup:insert(btn)
        sceneGroup:insert(bg)
        sceneGroup:insert(modal)
        -- el menu lateral lo ponemos al final para que se vea
        -- y no lo oculte nada
        sceneGroup:insert(navigation)
        

    elseif ( event.phase == "did" ) then
        -- ocultamos el cargador
        --ui.removeLoader('list_loader')

        -- previene el touch donde no se necesita
        background:addEventListener("touch", function() return true end)
        header:addEventListener("touch", function() return true end)
        nav:addEventListener("touch", function() return true end)
        navigation:addEventListener("touch", function() return true end)
        nav_bg:addEventListener("touch", function() return true end)
        modal:addEventListener("touch", function() return true end)
        search:addEventListener("touch", function() return true end)
        infoText:addEventListener("touch", function() return true end)
        -- previene el enterFrame donde no se necesita
        background:addEventListener("enterFrame", function() return true end)
        header:addEventListener("enterFrame", function() return true end)
        nav:addEventListener("enterFrame", function() return true end)
        navigation:addEventListener("enterFrame", function() return true end)
        nav_bg:addEventListener("enterFrame", function() return true end)
        modal:addEventListener("enterFrame", function() return true end)
        search:addEventListener("enterFrame", function() return true end)
        infoText:addEventListener("enterFrame", function() return true end)

        console.memory()
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

        navigation.removeSelf()
        navigation = nil

        nav_bg.removeSelf()
        nav_bg = nil

        modal.removeSelf()
        modal = nil

        search.removeSelf()
        search = nil

        infoText.removeSelf()
        infoText = nil

        

        -- quitamos los listener
        background:removeEventListener("touch", function() return true end)
        header:removeEventListener("touch", function() return true end)
        nav:removeEventListener("touch", function() return true end)
        navigation:removeEventListener("touch", function() return true end)
        nav_bg:removeEventListener("touch", function() return true end)
        modal:removeEventListener("touch", function() return true end)
        search:removeEventListener("touch", function() return true end)
        infoText:removeEventListener("touch", function() return true end)
        -- quitamos los enterFrame
        background:removeEventListener("enterFrame", function() return true end)
        header:removeEventListener("enterFrame", function() return true end)
        nav:removeEventListener("enterFrame", function() return true end)
        navigation:removeEventListener("enterFrame", function() return true end)
        nav_bg:removeEventListener("enterFrame", function() return true end)
        modal:removeEventListener("enterFrame", function() return true end)
        search:removeEventListener("enterFrame", function() return true end)
        infoText:removeEventListener("enterFrame", function() return true end)
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
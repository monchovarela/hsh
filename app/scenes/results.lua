
-- -----------------------------------------------------------------------------------
-- Las funciones de evento de código fuera de la escena a continuación solo se ejecutarán UNA VEZ a menos que
-- la escena se elimina por completo (no se recicla) a través de "composer.removeScene ()"
-- -----------------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
local ui = require("plugin.ui_framework")
local widget = require("widget")
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
local background,header,nav,tableView,data

-- ---------------------------------------------
-- metodo para volver al inicio
-- ---------------------------------------------
local backToTheHome = function(event)
    if event.phase == "ended" then
        composer.gotoScene( "scenes.init", {effect = "fromBottom",time = 200})
    end
end


-- ---------------------------------------------
-- metodo listar la tabla
-- ---------------------------------------------
local onRowRender = function(event)

    -- Get reference to the row group
    local row = event.row
    local params = row.params

       -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    -- show title
    local rowTitle = display.newText( row, params.name, 0, 0, native.systemFont, 14 )
    rowTitle.anchorX = 0
    rowTitle.x = 100
    rowTitle.y = 20
    rowTitle:setFillColor( unpack(ui.colors.black) )

    local rowDate = display.newText( row, config.results.date..": "..params.date, 0, 0, native.systemFont, 14 )
    rowDate.anchorX = 0
    rowDate.x = 100
    rowDate.y = 40
    rowDate:setFillColor( unpack(ui.colors.gray) )  

    local rowDomain = display.newText( row, config.results.domain..": "..params.domain, 0, 0, native.systemFont, 14 )
    rowDomain.anchorX = 0
    rowDomain.x = 100
    rowDomain.y = 60
    rowDomain:setFillColor( unpack(ui.colors.blue) )  

    
    local IsVerified = display.newText( row, config.results.verify..": "..params.IsVerified, 0, 0, native.systemFont, 14 )
    IsVerified.anchorX = 0
    IsVerified.x = 100
    IsVerified.y = 80
    IsVerified:setFillColor( unpack(ui.colors.purple) )  

    local uid = event.row.params.uid

    if uid < 2 then U.loadImage(row, params.image,uid.."_image.png",50,50)
    else U.loadImage(row, params.image,uid.."_image.png",50,50) end
end

-- ---------------------------------------------
-- metodo para invocar una accion al hacer touch 
-- ---------------------------------------------
local onRowTouch = function(event)
    local row = event.row
    local params = row.params
    if params.domain ~="" and params.domain ~= nil then system.openURL("https://"..params.domain) end
end

-- -----------------------------------------------------------------------------------
-- Metodos de Escena
-- -----------------------------------------------------------------------------------

-- ---------------------------------------------
-- Creamos la Escena
-- Se definen los elementos a enseñar
-- ---------------------------------------------
function scene:create( event )
    local sceneGroup = self.view

    ui:init({enable={loader = true}})

    ui.newLoader({tag = "list_loader",config = { x = screen.centerX,y = screen.centerY}})

    local colors = ui.colors

    -- craemos el fondo
    background = display.newRect(0,0,360, 570)
    background.x = screen.centerX
    background.y = screen.centerY
    background:setFillColor(unpack(colors.white))

    -- creamos el fondo de la parte de arriba del navbar
    header = display.newRect(0,0,360, 67)
    header.x = screen.centerX
    header.y = screen.top+header.height/2
    header.height = 70
    header:setFillColor(unpack(ui.colors.purpleDark))

    -- navegacion
    nav = U.navbar(ui,{title=config.results.name,buttons = {left = {config = {style = "back", touchCallback = backToTheHome},label = {text = config.back} }}})
    nav.x = screen.centerX
    nav.y = screen.top + 50

    -- Create the widget
    tableView = widget.newTableView(
        {
            left = screen.left,
            top = screen.top + 75,
            height = screen.height,
            width = screen.width,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch
        }
    )   

    data = event.params.data

    local dataJson = json.decode(data)
    for i, v in ipairs(dataJson) do

        local rowHeight = 100
        local rowColor = { default={color.set('#fdfdfd')} }
        local lineColor = { color.set('#eeeeee') }

        local verify = "No"
        if dataJson[i].IsVerified then verify = config.results.yes end

        -- Insert a row into the tableView
        tableView:insertRow(
            {
                rowHeight = rowHeight,
                rowColor = rowColor,
                lineColor = lineColor,
                params = {
                    uid = i,
                    image = dataJson[i].LogoPath,
                    name = dataJson[i].Name,
                    date = dataJson[i].BreachDate,
                    IsVerified = verify,
                    domain = dataJson[i].Domain
                }
            }
        )
    end


    sceneGroup:insert(background)
    sceneGroup:insert(header)
    sceneGroup:insert(nav)
    sceneGroup:insert(tableView)

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
        -- ocultamos el cargador
        ui.removeLoader('list_loader')-- 
        
        background:addEventListener("touch", function() return true end)
        header:addEventListener("touch", function() return true end)
        nav:addEventListener("touch", function() return true end)

        background:addEventListener("enterFrame", function() return true end)
        header:addEventListener("enterFrame", function() return true end)
        nav:addEventListener("enterFrame", function() return true end)
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

        background:removeEventListener("touch", function() return true end)
        header:removeEventListener("touch", function() return true end)
        nav:removeEventListener("touch", function() return true end)

        background:removeEventListener("enterFrame", function() return true end)
        header:removeEventListener("enterFrame", function() return true end)
        nav:removeEventListener("enterFrame", function() return true end)

        backToTheHome = nil
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
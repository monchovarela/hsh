-- -----------------------------------------------------------------------------------
-- Statusbar traslucido
-- -----------------------------------------------------------------------------------
display.setStatusBar( display.TranslucentStatusBar) 

-- -----------------------------------------------------------------------------------
-- Cargamos el composer
-- -----------------------------------------------------------------------------------
local composer = require( "composer" )
composer.gotoScene( "scenes.init", {effect = "fade",time = 500} )


-- -----------------------------------------------------------------------------------
-- Eventos del sistema
-- -----------------------------------------------------------------------------------
--Runtime:addEventListener( "system", function(event)
--    print(event.type)
--    if event.type=="applicationSuspend" then
--       print(event.type)
--    end
--end) 

-- -----------------------------------------------------------------------------------
-- incluimos el archivo de configuracion con los textos
-- -----------------------------------------------------------------------------------
local store = require( "utils.store" )
local config = store.loadTable("storage/config.json",system.ResourceDirectory)


-- -----------------------------------------------------------------------------------
-- Eventos al presionar teclas
-- -----------------------------------------------------------------------------------

Runtime:addEventListener( "key", function( event )
    -- is se presiona el boton back en android
    if ( event.keyName == "back" ) then
        native.showAlert(config.exit_title,config.exit_msg, {config.close,config.noclose },function(event)
            if ( event.action == "clicked" ) then
                local i = event.index
                if ( i == 1 ) then -- btn cerrar
                    native.requestExit()
                end
            end
        end) 
    end
    -- ¡IMPORTANTE! Devuelva falso para indicar que esta aplicación NO está anulando la clave recibida
    -- Esto le permite al sistema operativo ejecutar su manejo predeterminado de la clave.
    return false
end)




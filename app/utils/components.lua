local screen = require("utils.screen")
local console = require("utils.console")
local color = require("utils.color")

local M = {}

function M.navbar(ui,args)
    local navbar = ui.newNavbar(args or {
        title = "Application", 
        buttons = {
            left = { config = { style = "back", touchCallback = function() print("back touched") end}, label = {text = "home"} },
            right = {
                {config = { style = "icon", touchCallback = function() print("options touched") end}, icon = {text = ui.fonts.icon.options} },
                {config = { style = "icon", touchCallback = function() print("search touched") end}, icon = {text = ui.fonts.icon.search} },

            } 
        }})
    return navbar
end

function M.notif(ui,args)
    local toast = ui.newToast({
        config = {
            color = args.color or {color.set("#ffffff")},
            x = args.x or screen.centerX, 
            y = args.y or screen.bottom - 100,
        },
        label = {
            text = args.title or "Bup", 
            color = args.labelColor or {color.set("#333333")} 
        },
    })
end

function M.search(ui,args)

    local search_bar = ui.newSearchbar({config = {},placeholder = {text = args.placeholder or "Buscar"}})

    local hideSearch = function()
        --search_bar.input.setText("")
        transition.to(search_bar,{time=200,x=-screen.width,onComplete= function()
            search_bar.isVisible = false 
            search_bar.x = screen.width/2
        end})
    end

    search_bar:setCancelTouchCallback(function(event)
        if event.phase == "ended" then  
            search_bar:removeFocus() 
            hideSearch()
        end
        return true
    end)

    search_bar:setSubmittedCallback(function(input_value) 
        args.onSubmit(input_value) 
        hideSearch()
    end)

    search_bar.x = screen.width*.5
    search_bar.y = screen.top + 50
    search_bar.isVisible = false
    return search_bar
end


function M.createLinks(ui,group,links)
    -- enlaces
    for i=1,#links do
        local nav_link = ui.newButton( { 
            config = {
                style = "icon", 
                touchCallback = links[i].listener
            },
            icon = {
                text = links[i].icon or nil,
                fontSize = 15,
                x = -50,
                color = {color.set("#333333")},
            },
            label = {
                text = links[i].name,
                fontSize = 12,
                color = {color.set("#777777")},
            }
        })
        nav_link.y = (nav_link.height + 10)*i
        nav_link.x = group.width/2
        group:insert(nav_link)
    end
end


function M.card(ui,args)
    local cardGroup = display.newGroup()
    
    local overlay = display.newRect(0,0,320,570)
    overlay.x = screen.centerX
    overlay.y = screen.centerY
    overlay:setFillColor(0,0,0,0.8)
    -- previene hacer click en las capas de abajo
    overlay:addEventListener('touch',function(event) return true end)

    local buttons = {
        {config = { style = "flat", touchCallback = function(event) closeCard(event) end},label = {color={color.set("#f55555")},text = args.btn or "Cerrar"} }
    }

    if args.showMore then
        buttons = {
            {config = { style = "flat", touchCallback = function(event) closeCard(event) end},label = {color={color.set("#f55555")},text = args.btn or "Cerrar"} },
            {config = { style = "flat", touchCallback = function(event) 
                closeCard(event)
                args.showMoreCallback(event) 
            end},
            label = {color={color.set("#333333")},text = args.showMoreBtn or "Ver mas"} },
        }
    end

    local card = ui.newCard({
        x = screen.width/2, 
        y = 100, 
        title = args.title or "halo", 
        subtitle = args.subtitle or "sub", 
        description = args.description or "long description for this cards", 
        width = screen.width-20, 
        height = 150,
        buttons = buttons
    })


    function closeCard(event)
        if event.phase == "ended" then
            card:removeSelf()
            overlay:removeSelf() 
        end
        return true 
    end

    args.parent:insert(overlay)
    args.parent:insert(card)

    return card
end


function M.request(ui,args)
    local headers = {}
    headers["Content-Type"] = "application/json"
    headers["user-agent"] = "android"

    local params = {}
    params.headers = headers


    network.request( args.url..args.mail, "GET", function(event)
        return args.listener(event)
    end, params )
end


function M.loadImage(parent,url,image,x,y)

    local box = display.newRect(parent,x,y,80,80)
    box:setFillColor(0.9)

    local function networkListener( event )

        if ( event.isError ) then
            print ( "Network error - download failed" )
        else
            event.target.width = 50
            event.target.height = 50
            event.target.alpha = 0
            if event.target._class then 
                parent:insert(event.target) 
            end
            transition.to( event.target, { alpha = 1.0 } )
        end
    end
    display.loadRemoteImage( url, "GET", networkListener, image, system.TemporaryDirectory, x, y )
end

-- requests.loadHtml('filename.html',function)
function M.loadHtml(filename,callback)
    local baseDir = system.ResourceDirectory
    local webView = native.newWebView(0,0,200,300)
    webView:request(filename, baseDir)
    webView:addEventListener( "urlRequest", callback )
    return webView
end

local swipeWasDone = false 
function M.swipe(event)
    local right = screen.right-screen.left
    if ( event.phase == "moved" ) then
        local dX = event.x - event.xStart
        if ( dX > 5 and swipeWasDone == false ) then
            swipeWasDone = true
            local spot = right
            if ( event.target.x == screen.left ) then
                    spot = screen.centerX
            end
            transition.to( event.target, { time=500, x=spot,
                onComplete=function() swipeWasDone = false; end } )
        elseif ( dX < -5 and swipeWasDone == false ) then
            swipeWasDone = true
            local spot = screen.left
            if ( event.target.x == right ) then
                    spot = screen.centerX
            end
            transition.to( event.target, { time=500, x=spot,
                onComplete=function() swipeWasDone = false; end } )
        end
    end
end


return M
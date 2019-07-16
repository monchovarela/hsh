M = {}


M.log = function( ... )
    if (#arg > 1) then
        print("========================LOG ("..#arg..")========================")
        for i=1, #arg do
            print("========================LOG ["..i.."]========================")
            dump(arg[i])
        end
    else
        local t = arg[1]
        print("========================LOG========================")
        for k,v in pairs(t) do
            print("\t",k,v)
        end
        print("========================LOG========================")
    end
end


M.memory = function()      
    local memUsed = (collectgarbage("count")) / 1000
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1000000
    
    print("\n---------MEMORY USAGE INFORMATION---------")
    print("System Memory Used:", string.format("%.03f", memUsed), "Mb")
    print("Texture Memory Used:", string.format("%.03f", texUsed), "Mb")
    print("------------------------------------------\n")
     
    return true
end


return M
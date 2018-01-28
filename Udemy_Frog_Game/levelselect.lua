local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- local forward references should go here --
local levels = {}

local function loadLevel(event)
    local phase = event.phase
    local obj = event.target
    
    if phase == "began" then
        display.getCurrentStage():setFocus(obj);
        obj.isFocus = true;
        print(levels[obj.idx].idx)
        storyboard.gotoScene("play", { effect="slideUp" })
    end
   
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
        local group = self.view

        local bg = display.newImageRect("images/bg_iPhone.png", 480, 320)
        bg.x = centerX
        bg.y = centerY
        group:insert(bg)

        local scrollView = widget.newScrollView
        {
            left = 40,
            top = 40,
            width = 400,
            height = 160,
            scrollWidth = 400,
            scrollHeight = 160,
            hideBackground = true
        }
        group:insert(scrollView)
        
        local levelApart = 112
        for idx = 1, 11 do
            local level = display.newImageRect("images/lilypad_green.png", 64, 64)
            level.x = idx * levelApart
            level.y = scrollView.height / 2
            scrollView:insert(level)
            
            local levelNum = display.newText(idx, 0, 0, native.systemFont, 20)
            levelNum.x = level.x
            levelNum.y = level.y
            scrollView:insert(levelNum)
            
            levels[idx] = level
            levels[idx].idx = idx
            
            level:addEventListener("touch", loadLevel)
          
            if (idx == 11) then
                level.alpha = 0
            end
        end

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view

        --      INSERT code here (e.g. start timers, load audio, start listeners, etc.)

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view

        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view

        --      INSERT code here (e.g. remove listeners, widgets, save state, etc.)

end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )


---------------------------------------------------------------------------------

return scene
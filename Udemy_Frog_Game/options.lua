local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
--widget.setTheme("widget_theme_ios")

-- local forward references should go here --

local function buttonHit(parm)
	storyboard.gotoScene ( "menu", { effect = "slideDown" } )
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
        local group = self.view

	--      CREATE display objects and add them to 'group' here.
	--      Example use-case: Restore 'group' from previously saved state.

	local bg = display.newImageRect("images/bg_iPhone.png", 480, 320)
	bg.x = centerX
	bg.y = centerY
	group:insert(bg)
	
	local title = display.newText(group, "Options", 0, 0, native.systemFont, 48)
	title.x = centerX
	title.y = centerY - 100
  
  local musicTxt = display.newText(group, "Music", 0, 0, native.systemFont, 24)
	musicTxt.x = centerX - 50
  musicTxt.y = centerY
  local checkMusic = widget.newSwitch
  {
      left = 290,
      top = centerY-15,
      style = "checkbox",
      initialSwitchState = musicIsPlaying,
      onRelease = function() musicIsPlaying = not musicIsPlaying end
  }
  group:insert(checkMusic)
  
  local sfxTxt = display.newText(group, "SFX", 0, 0, native.systemFont, 24)
	sfxTxt.x = centerX - 50
  sfxTxt.y = centerY + 50
  
  local checkSFX = widget.newSwitch
  {
      left = 290,
      top = centerY+ 35,
      style = "checkbox",
      initialSwitchState = sfxIsPlaying,
      onRelease = function() sfxIsPlaying = not sfxIsPlaying end
  }
  group:insert(checkSFX)
  
	makeButton("Back", 40, display.contentHeight-20, buttonHit, "back", group, backLarge)
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view

        

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

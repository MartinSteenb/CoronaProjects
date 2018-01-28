
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function loadGame ()
  composer.gotoScene("game", {time = 800, effect="crossFade"})
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newImageRect(sceneGroup, "Background.png", 1600, 1000)
  background.x = display.contentCenterX
  background.y = display.contentCenterY
  
  local title = display.newText(sceneGroup, "King", display.contentCenterX, 150, "I-pixel-u.ttf", 200)
  local Play = display.newText(sceneGroup, "Play", display.contentCenterX, 400, "I-pixel-u.ttf", 90)
  local Highscores = display.newText(sceneGroup, "Highscores", display.contentCenterX, 520, "I-pixel-u.ttf", 90)
  local ComingSoon = display.newText(sceneGroup, "(Coming soon)", display.contentCenterX, 600, "I-pixel-u.ttf", 50)
  
  Play:addEventListener("tap", loadGame)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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


local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require("physics")
physics.start()
physics.setGravity(0, 30)

-- Image sheets
local sheetOptions =
{
    width = 102,
    height = 138,
    numFrames = 4
}
local sheet_runningKing = graphics.newImageSheet( "runningKing_sheet.png", sheetOptions )

-- sequences table
local sequences_runningKing = {
    -- consecutive frames sequence
    {
        name = "normalRun",
        start = 1,
        count = 4,
        time = 400,
        loopCount = 0,
        loopDirection = "forward"
    }
}

local chestSheet =
{
    frames =
    {
        {   -- 1) left
            x = 0,
            y = 2,
            width = 14,
            height = 11
        },
        {   -- 2) mid
            x = 16,
            y = 0,
            width = 14,
            height = 13
        },
        {   -- 3) right
            x = 32,
            y = 0,
            width = 14,
            height = 13
        },
    },
}
local imageSheetChest = graphics.newImageSheet("Chest_sheet.png", chestSheet)

local king
local enemy
local exit
local chest
local chestOpen
local chestEmpty
local chestEmptied = false
local collectText
local leftControl
local rightControl
local jumpControl
local jumping = false

local perspective = require("perspective")
local camera = perspective.createView()

local enemyMovingLeft = true
local enemyMovingRight

local backGroup
local mainGroup
local uiGroup

local function jump (event)
  if(event.phase == "began" and jumping == false) then
     jumping = true 
		 king:applyLinearImpulse(0, -3.3, king.x, king.y)
	end
end  

local function moveLeft (event)
  if (event.phase == "began") then
      king:setLinearVelocity(-300, 0)
      king:play()
  end
  
  if (event.phase == "ended") then
      king:setLinearVelocity(0, 0)
      king:pause()
  end
  
  king.xScale = -1
end

local function moveRight (event)
  if (event.phase == "began") then
      king:setLinearVelocity(300, 0)
        king:play()
  end
  
  if (event.phase == "ended") then
      king:setLinearVelocity(0, 0)
      king:pause()
  end
  
  king.xScale = 1
end

local function enemyMovement ()
  
  if (enemyMovingLeft) then
      enemyMovingRight = false
      enemy:setLinearVelocity(-300, 0)
  elseif (enemyMovingRight) then
      enemyMovingLeft = false
      enemy:setLinearVelocity(300, 0)
  end
end

local function openExit ()
  chestEmptied = true
  
  exit = display.newImageRect(mainGroup, "exit.png", 100, 150)
  exit.x, exit.y = display.contentCenterX + 800, display.contentHeight - 592
  physics.addBody(exit, "static", {radius = 10 , bounce = 0})
  exit.alpha = 0
  exit.myName = "exit"
  transition.to(exit, {alpha = 1, time = 2000})
  
  chestEmpty = display.newImageRect(mainGroup, imageSheetChest, 2, 90, 78)
  chestEmpty.x, chestEmpty.y = display.contentCenterX + 1000, display.contentHeight - 227
  physics.addBody(chestEmpty, "static", {radius = 100, isSensor = true})
  
  camera:add(exit, 2, false)
  
  if (chestEmptied == true) then
      camera:add(chestEmpty, 2, false)
      chestOpen:removeSelf()
      collectText:removeSelf()
  end
end

local function endGame ()
  composer.gotoScene("menu", {time = 800, effect="crossFade"})
end
local function youDied ()
  composer.gotoScene("menu", {time = 800, effect="crossFade"}) 
end

local function openChest ()
  if (chestEmptied == false) then
    chestOpen = display.newImageRect(mainGroup, imageSheetChest, 3, 90, 78)
    chestOpen.x, chestOpen.y = display.contentCenterX + 1000, display.contentHeight - 227
    chestOpen.myName = "chest"
    
       collectText = display.newText(uiGroup, "Collect", display.contentCenterX, display.contentCenterY - 150,"I-pixel-u.ttf", 100)
    collectText:addEventListener("tap", openExit)
    
    camera:add(chestOpen, 2, false)
  end
  
end

local function closeChest ()
  
  chest = display.newImageRect(mainGroup, imageSheetChest, 1, 90, 66)
  chest.x, chest.y = display.contentCenterX + 1000, display.contentHeight - 220
  chest.myName = "chest"
  
  if (chestEmptied == false) then
      chestOpen:removeSelf()
      collectText:removeSelf()
  end

end

local function onCollision (event)
  if (event.phase == "began") then
      local obj1 = event.object1
      local obj2 = event.object2
      
      if (obj1.myName == "king" and obj2.myName == "enemy") then
          king.alpha = 0
          display.newText(uiGroup, "YOU DIED", display.contentCenterX, display.contentCenterY - 150, "I-pixel-u.ttf", 100)
          timer.performWithDelay(2000, youDied)
      end
      
      if (obj1.myName == "king" and obj2.myName == "floor") then
          jumping = false
      end
      
      if (obj1.myName == "enemy" and obj2.myName == "rotationObject" and enemyMovingLeft == true) then
          enemy.xScale = 1
          enemyMovingRight = true
          enemyMovingLeft = false
      elseif (obj1.myName == "enemy" and obj2.myName == "rotationObject" and enemyMovingRight) then
          enemy.xScale = -1
          enemyMovingRight = false
          enemyMovingLeft = true
      end
      
       if (obj1.myName == "king" and obj2.myName == "chest") then
           openChest()
       end
       
       if (obj1.myName == "king" and obj2.myName == "exit") then
           endGame()
       end
  end
  
  if (event.phase == "ended") then
      local obj1 = event.object1
      local obj2 = event.object2
      if (obj1.myName == "king" and obj2.myName == "chest") then
           closeChest()
      end    
  end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
  physics.pause()
  
  backGroup = display.newGroup()  
  mainGroup = display.newGroup()  
  uiGroup = display.newGroup()
  
  sceneGroup:insert(backGroup)  
  sceneGroup:insert(mainGroup)  
  sceneGroup:insert(camera)
  sceneGroup:insert(uiGroup)
  
  
  local background = display.newImageRect(backGroup, "Background.png", 3000, 3000)
  background.x, background.y = display.contentCenterX, display.contentCenterY
  
  local leftWall = display.newRect(-760, display.contentCenterY, 100, 800)
  physics.addBody(leftWall, "static", {bounce = 0})
  
   local rightWall = display.newRect(2040, display.contentCenterY, 100, 800)
  physics.addBody(rightWall, "static", {bounce = 0})
  
  -- Player
  king = display.newSprite(sheet_runningKing, sequences_runningKing)
  king.x, king.y = display.contentCenterX - 1200, display.contentHeight - 254 -- +x = 1400 -x = 1200
  physics.addBody(king, "dynamic", {bounce = 0})
  king.myName = "king"
  king.isFixedRotation = true
  
  -- Controls
  leftControl = display.newImageRect(uiGroup, "leftControl.png", 100, 100)
  leftControl.x, leftControl.y = display.contentCenterX - 100, display.contentHeight - 70
  leftControl.myName = "leftControl"
  
  rightControl = display.newImageRect(uiGroup, "rightControl.png", 100, 100)
  rightControl.x, rightControl.y = display.contentCenterX, display.contentHeight - 70
  rightControl.myName = "rightControl"
  
  jumpControl = display.newImageRect(uiGroup, "jumpControl.png", 100, 100)
  jumpControl.x, jumpControl.y = display.contentCenterX + 100, display.contentHeight - 70
  jumpControl.myName = "jumpControl"
 
  -- floor
  local floor = display.newImageRect(backGroup, "Floor.png", 4260, 250)
  floor.x, floor.y = display.contentCenterX, display.contentHeight - 60
  physics.addBody(floor, "static", {bounce = 0})
  floor.myName = "floor"
  
  -- platform
  local platform1 = display.newImageRect(backGroup, "Platform.png", 560, 32)
  platform1.x, platform1.y = display.contentCenterX, display.contentHeight - 340
  physics.addBody(platform1, "static", {bounce = 0})
  platform1.myName = "floor"
  
  local platform2 = display.newImageRect(backGroup, "Platform.png", 560, 32)
  platform2.x, platform2.y = display.contentCenterX + 600, display.contentHeight - 500
  physics.addBody(platform2, "static", {bounce = 0})
  platform2.myName = "floor"
  
  -- enemies
  enemy = display.newImageRect(mainGroup, "Enemy.png", 108, 84)
  enemy.x, enemy.y = display.contentCenterX + 1000, display.contentHeight - 200
  physics.addBody(enemy, "dynamic", {bounce = 0})
  enemy.myName = "enemy"
  enemy.xScale = -1
  
  -- enemy checkpoints
  local rotationObject1 = display.newRect(0, 0, 50, 100)
  rotationObject1.x, rotationObject1.y = display.contentCenterX + 300, display.contentCenterY + 150
  physics.addBody(rotationObject1, "static", {isSensor = true})
  rotationObject1.myName = "rotationObject"
  rotationObject1.alpha = 0
  
  local rotationObject2 = display.newRect(0, 0, 50, 100)
  rotationObject2.x, rotationObject2.y = display.contentCenterX + 1200, display.contentCenterY + 150
  physics.addBody(rotationObject2, "static", {isSensor = true})
  rotationObject2.myName = "rotationObject"
  rotationObject2.alpha = 0
  
  chest = display.newImageRect(mainGroup, imageSheetChest, 1, 90, 66)
  chest.x, chest.y = display.contentCenterX + 1000, display.contentHeight - 220
  physics.addBody(chest, "static", {radius = 100, isSensor = true})
  chest.myName = "chest"
  
  -- eventListeners
  jumpControl:addEventListener("touch", jump)
  rightControl:addEventListener("touch", moveRight)
  leftControl:addEventListener("touch", moveLeft)
  
  camera:add(background, 3, false)
  camera:add(platform1, 2, false)
  camera:add(platform2, 2, false)
  camera:add(leftWall, 2, false)
  camera:add(rightWall, 2, false)
  camera:add(floor, 2, false)
  camera:add(rotationObject1, 1, false)
  camera:add(rotationObject2, 1, false)
  camera:add(chest, 2, false)
  camera:add(enemy, 1, false)
  camera:add(king, 1, true)
  
  camera:setBounds(0, display.contentWidth, 0, display.contentHeight)
  
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
    camera:track()
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
    
    physics.start()
    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame", enemyMovement)
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
    camera:destroy()
    Runtime:removeEventListener("collision", onCollision)
    Runtime:removeEventListener("enterFrame", enemyMovement)
    physics.pause()
    king:pause()
    composer.removeScene("game")
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

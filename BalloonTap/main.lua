-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local tapCount = 0

-- Background

local background = display.newImageRect("background.png", 360, 570)
background.x = display.contentCenterX
background.y = display.contentCenterY

local counterText = display.newText(tapCount, display.contentCenterX, 20, native.systemFont, 40)
counterText:setFillColor(1, 1, 1) -- default settings is (1, 1, 1)

local platform = display.newImageRect("platform.png", 319, 50)
platform.x = display.contentCenterX
platform.y = display.contentHeight + 19

local platformLeft = display.newImageRect("platform.png" , 500, 50)
platformLeft.x = - 25
platformLeft.y = display.contentCenterY
platformLeft.rotation = 90

local platformRight = display.newImageRect("platform.png" , 500, 50)
platformRight.x = display.contentWidth + 25
platformRight.y = display.contentCenterY
platformRight.rotation = 90

local platformRoof = display.newImageRect("platform.png" , 319, 50)
platformRoof.x = display.contentCenterX
platformRoof.y = display.contentHeight - 570

local balloon = display.newImageRect("balloon.png", 112, 112)
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
--balloon.alpha = 0.8 -- opacity of the object, 1 = 100% opacity


-- Physics

local physics = require("physics") -- loads the Box2D physics engine into the app
physics.start()
physics.setGravity(0, 7.5)

physics.addBody(platform, "static")
physics.addBody(balloon, "dynamic", {radius = 70, bounce = 0.2})
physics.addBody(platformLeft, "static")
physics.addBody(platformRight, "static")
physics.addBody(platformRoof, "static")

local function pushBalloon ()
  local randomDirection = math.random(-1, 1)
  balloon:applyLinearImpulse(randomDirection, -2, balloon.x, balloon.y) 
  -- last two parameters = where to apply the force
  tapCount = tapCount + 1
  counterText.text = tapCount -- update property of text object and not the object itself
end

balloon:addEventListener("tap", pushBalloon)







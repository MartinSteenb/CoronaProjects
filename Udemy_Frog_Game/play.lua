local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- local forward references should go here --

local frogJumpSpeed = 600

local pads = {}
local idx = 0
local frog
local fly

local snake
local slithering = false

local scoreLabel
local scoreObj
local score = 0

local function buttonHit(parm)
  audio.stop()
	storyboard.gotoScene ( "menu", { effect = "slideDown" } )
end

local function snakeCollision (event)
    local phase = event.phase
    --local obj1 = event.object1
    --local obj2 = event.object2
    
    if (phase == "began") then
        frog:setSequence("die")
        frog:play()
        slithering = false
    end
end

local function makeSnake(group)
	
	local sheetData = { width=100, height=250, numFrames=8, border=0, sheetContentWidth=512, sheetContentHeight=512 }

	local imageSheet = graphics.newImageSheet( "images/snakes.png", sheetData )

	local sequenceData = { { name="slither", start=1, count=8, time=650 } }
	
	snake = display.newSprite( imageSheet, sequenceData )
	snake:scale(.4, .4)
	snake.x = -100
	snake.y = -100
	snake:setSequence("slither")
	snake:play()
	group:insert(snake)
	physics.addBody( snake, "dynamic", { radius=15, isSensor=true } )

end

function startSnake()
	
	local startX = -50
	local startY = -50
	local endX = display.contentWidth + 50	
	local endY = display.contentHeight + 50	
	local travelTime = 4000
	
	if math.random(1,2) == 1 then
		--go down the screen
		startX = math.random(display.screenOriginX + 50, display.contentWidth - 100 )
		endX = startX
		snake.rotation = 180
		travelTime = 3000
	else
		--go across the screen
		startY = math.random ( display.screenOriginY + 50, display.contentHeight - 100 )
		endY = startY
		snake.rotation = 90
	end
	
	if slithering then
		snake.x = startX
		snake.y = startY
		transition.to( snake, { time=travelTime, x=endX, y=endY, onComplete=startSnake } )
	end
	
end

local function addToScore(num)
	score = score + num
	scoreObj.text = score
	scoreObj.anchorX = 0
	scoreObj.x = scoreLabel.x + (scoreLabel.width/2)
end

local function resetScore()
	score = 0
	addToScore(0)
end

local function hopDone(obj)
  frog:setSequence("sit")
  frog:play()
	local function killPad()
		display.remove( pads[1] )
	end
	transition.to ( pads[1], {time=2000, alpha=0, xScale=.01, yScale=.01, rotation=360, onComplete=killPad} )
end

local function frogTapped(event)
	print("Croak!")
	transition.to ( event.target, { rotation=360, delta=true } )
end

local function padTouched(event)
  
  if (slithering == false) then
      slithering = true
      startSnake()
  end
  
	local pad = event.target
	if event.phase == "ended" then
		local angleBetween = math.ceil(math.atan2( (pad.y - frog.y), (pad.x - frog.x) ) * 180 /  math.pi ) + 90
		frog.rotation = angleBetween
		
    local function doneHopping()
        frog:setSequence("sit")
        frog:play()
		end
		transition.to ( frog, { time=frogJumpSpeed, x=pad.x, y=pad.y, transition=easing.inOutQuad, onComplete=doneHopping } )
		
    local function hopSound()
        playSFX(sndJump)
		end
      timer.performWithDelay( frogJumpSpeed / 4, hopSound)
      addToScore(10)
      frog:setSequence("hop")
      frog:play()
	end
end

local function flyTouched(event)
	local obj = event.target
	
	if event.phase == "began" then
    

		
		display.getCurrentStage():setFocus(obj)
		obj.startMoveX = obj.x
		obj.startMoveY = obj.y
		
	elseif event.phase == "moved" then
	
		obj.x = (event.x - event.xStart) + obj.startMoveX
		obj.y = (event.y - event.yStart) + obj.startMoveY
	
	elseif event.phase == "ended" or event.phase == "cancelled" then
		display.getCurrentStage():setFocus(nil)
	
	end
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
        local group = self.view

        local bg = display.newImageRect("images/bg_iPhone.png", 480, 320)
        bg.x = centerX
        bg.y = centerY
        group:insert(bg)
        
        makeSnake(group)
        
        level = {
          3,1,1,1,0,0,
          0,0,1,0,0,0,
          4,0,1,2,0,0,
          0,1,1,1,0,0
        }
    
        local levIdx = 0
        
        for y = 1, 4 do
          for x = 1, 6 do
            levIdx = levIdx + 1
            local imgNum = level[levIdx]
            if (imgNum > 0) then
                local pad = display.newImageRect(levelImages[imgNum].picFile, 64, 64)
                pad:rotate( math.random ( 0, 360 ) )
                pad.x = (x * 75) - 23
                pad.y = y * 70
                local sizer = 1 + math.random(-1, 1) / 10
                pad:scale ( sizer, sizer )
                pad:addEventListener ( "touch", padTouched )
                group:insert(pad)
                pads[levIdx] = pad
                pads[levIdx].kind = levelImages[imgNum].kind
                pads[levIdx].visible = true
                pads[levIdx].lit = false
            else
                pads[levIdx] = {}
                pads[levIdx].kind = "empty" 
            end
            pads[levIdx].idx = levIdx
          end
        end
        
        
        local sheetData = { width=64, height=95, numFrames=8, sheetContentWidth=256, sheetContentHeight=256 }
        local imageSheet = graphics.newImageSheet( "images/frogs.png", sheetData )
        local sequenceData = {
          { name="sit", start=1, count=1 },
          { name="hop", start=1, count=7, time=650 },
          { name="die", start=8, count=1 }
        }
        
        frog = display.newSprite( imageSheet, sequenceData )
        frog.x = 52
        frog.y = 70
        frog:setSequence("sit")
        frog:play()
        group:insert(frog)
        physics.addBody(frog, "dynamic", {radius=30, isSensor=true})
        
        fly = display.newImageRect ( "images/fly.png", 32, 22 )
        fly.x = centerX
        fly.y = 15
        fly:addEventListener ( "touch", flyTouched )
        group:insert(fly)

        scoreLabel = display.newText( "Score: ", 0, 0, native.systemFont, 18 )
        scoreLabel.x = 380
        scoreLabel.y = 20
        scoreLabel:addEventListener ( "tap", resetScore )
        group:insert(scoreLabel)

        scoreObj = display.newText( tostring(score), 0, 0, native.systemFont, 18 )
        --scoreObj:setReferencePoint(display.CenterLeftReferencePoint)
        scoreObj.anchorX = 0
        scoreObj.x = scoreLabel.x + (scoreLabel.width/2)
        scoreObj.y = scoreLabel.y
        group:insert(scoreObj)
        
        makeButton("Back", 40, 20, buttonHit, "back", group)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view
        
        Runtime:addEventListener("collision", snakeCollision)
        playMusic()

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view

        Runtime:removeEventListener("collision", snakeCollision)
        
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
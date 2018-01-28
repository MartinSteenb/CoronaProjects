-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

-- Seed the random number generator
math.randomseed(os.time())

--Hide statusbar
display.setStatusBar(display.HiddenStatusBar)

-- Image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local imageSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

-- Initialize variables
local lives = 3
local score = 0
local died = false
 
local asteroidsTable = {}
 
local ship
local gameLoopTimer
local livesText
local scoreText

-- Display groups
local backgroundGroup = display.newGroup()
local mainObjectsGroup = display.newGroup()
local uiGroup = display.newGroup()

--Loading the background
local background = display.newImageRect(backgroundGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

--Loading the ship
ship = display.newImageRect(mainObjectsGroup, imageSheet, 4, 98, 79)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, {radius = 30, isSensor = true}) 
-- isSensor = has collision detection but does not produce a physical response like bouncing
ship.myName = "ship"
-- This property will be used later to help determine what types of collisions are happening in the game (like a tag in Unity).

-- Display UI
livesText = display.newText(uiGroup, "Lives left: ".. lives, 220, 50, native.systemFont, 36)
scoreText = display.newText(uiGroup, "Score: ".. score, 580, 50, native.systemFont, 36)

function updateText ()
    livesText.text = "Lives left: " .. lives
    scoreText.text = "Score: " .. score
end

function createAsteroid ()
    local newAsteroid = display.newImageRect(mainObjectsGroup, imageSheet, 1, 102, 85)
    table.insert(asteroidsTable, newAsteroid)
    physics.addBody(newAsteroid, "dynamic", {radius = 40, bounce = 0.8})
    newAsteroid.myName = "asteroid"
    
    local spawnLocation = math.random(3)
    
    if (spawnLocation == 1) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif (spawnLocation == 2) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif (spawnLocation == 3) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end
    
    --rotation
    newAsteroid:applyTorque(-10, 10)
end

local function fireLaser ()   
    local newLaser = display.newImageRect(mainObjectsGroup, imageSheet, 5, 14, 40)
    physics.addBody(newLaser, "dynamic", {isSensor = true})
    newLaser.isBullet = true
    newLaser.myName = "laser"
    
    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack() --moves it to layer behind the ship
    
    transition.to(newLaser, {y = -40, time = 500, 
        onComplete = function () 
            display.remove(newLaser) 
        end 
      })
    
    -- Those with a keen eye will notice that the function specified after onComplete = doesn't have a name. In Lua, this is known as an anonymous      --function. These are useful as "temporary" functions, for functions needed as a parameter to another function, etc. Although we could write a --dedicated function to remove the lasers and call it via the onComplete callback, it's easier to use an anonymous function in this case.
end

ship:addEventListener("tap", fireLaser)

-- Ship movement
-- (event) this parameter tells us what object the user is touching/dragging, the location of the touch in content space, and a few other pieces of information
local function moveShip (event) 
    local ship = event.target
    local phase = event.phase
    
    if ("began" == phase) then
        -- Set touch focus on the ship
        display.currentStage:setFocus(ship)
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
    elseif ("moved" == phase) then
        ship.x = event.x - ship.touchOffsetX
    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        display.currentStage:setFocus(nil)
    end
    
    return true  -- Prevents touch propagation to underlying objects
    
    -- In this conditional case, we set the touch focus on the ship — essentially, this means that the ship object will "own" the touch event throughout its duration. While focus is on the ship, no other objects in the game will detect events from this specific touch:
end

ship:addEventListener("touch", moveShip)


-- Game Loop
local function gameLoop ()
    createAsteroid()
    
    -- Remove asteroids which have drifted off screen, # counts the elements in the table 1 = stops at 1
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
        if (thisAsteroid.x < -100 or
            thisAsteroid.x > display.contentWidth + 100 or
            thisAsteroid.y < -100 or
            thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove(thisAsteroid) -- removes from screen
            table.remove(asteroidsTable, i) -- removes reference from table
        end
    end
end

--local randomSpawnTimer = math.random(2000, 5000)
gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)


-- Ship respawn
local function respawnShip ()
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    })
end

-- Collisions
local function onGlobalCollision (event)
    if (event.phase == "began") then
        local obj1 = event.object1
        local obj2 = event.object2
        
        if(obj1.myName == "laser" and obj2.myName == "asteroid" or
           obj1.myName == "asteroid" and obj2.MyName == "laser")
        then
            display.remove(obj1)
            display.remove(obj2)
            
                 -- destroy collided asteroid
            for i = #asteroidsTable, 1, -1 do
                if (asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
                    table.remove(asteroidsTable, i)
                    break
                end
            end
            
            -- Score for destroying asteroid
            score = score + 100
            scoreText.text = "Score: " .. score
        
        
        elseif(obj1.myName == "ship" and obj2.myName == "asteroid" or
               obj1.myName == "asteroid" and obj2.myName == "ship")
        then
            if (died == false) then
                died = true
 
                -- Update lives
                lives = lives - 1
                livesText.text = "Lives left: " .. lives
 
                if (lives == 0) then
                    display.remove(ship)
                else
                    ship.alpha = 0
                    timer.performWithDelay( 1000, respawnShip )
                end
            end
        end
    end
end

Runtime:addEventListener("collision", onGlobalCollision)




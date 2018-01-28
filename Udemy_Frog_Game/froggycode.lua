-- Project: GameDev-07-ReadingWriting
-- Copyright 2012-2014 Three Ring Ranch
-- http://MasteringCoronaSDK.com


local GGData = require("GGData")

display.setStatusBar(display.HiddenStatusBar)

centerX = display.contentWidth * .5
centerY = display.contentHeight * .5

local prefs = GGData:new("preferences")

musicIsPlaying = true
sfxIsPlaying = true

local frogJumpSpeed = 600

local pads = {}
local idx = 0
local frog
local fly

local scoreLabel
local scoreObj
local score = 0

local function loadPrefs()
	prefs:load()
	musicIsPlaying = prefs.musicIsPlaying
	sfxIsPlaying = prefs.sfxIsPlaying
end

local function savePrefs()
	prefs.musicIsPlaying = musicIsPlaying
	prefs.sfxIsPlaying = sfxIsPlaying
	prefs:save()
end

local function addToScore(num)
	score = score + num
	scoreObj.text = score
	--scoreObj:setReferencePoint(display.CenterLeftReferencePoint)
	scoreObj.anchorX = 0
	scoreObj.x = scoreLabel.x + (scoreLabel.width/2)
end

local function resetScore()
	score = 0
	addToScore(0)
end

audio.reserveChannels(1)

sndChanMusic = 1

sndJump = audio.loadSound("audio/boing2.mp3")
sndMusic = audio.loadStream("audio/HappyPants.wav")

function playSFX(audioHandle, opt)
	local options = opt or {}
	local loopNum = options.loop or 0
	local channel = options.channel or 0
	local chanUsed = nil
	if sfxIsPlaying then
		print("DOOODOOO")
		chanUsed = audio.play( audioHandle, { channel=channel, loops=loopNum } )
	end
	return chanUsed
end

function playMusic()
	if musicIsPlaying then
		audio.play( sndMusic, {channel = sndChanMusic, loops=-1 } )
		audio.setVolume ( .15 ,{ channel=sndChanMusic } )
	end
end

local function hopDone(obj)
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
	local pad = event.target
	if event.phase == "ended" then
		local angleBetween = math.ceil(math.atan2( (pad.y - frog.y), (pad.x - frog.x) ) * 180 /  math.pi ) + 90
     transition.to ( frog, {time=400, rotation=angleBetween,transition=easing.inOutQuad } )
    local function frogMove ()
        transition.to ( frog, { time=frogJumpSpeed, x=pad.x, y=pad.y, transition=easing.inOutQuad } )
        addToScore(10)
    end
    timer.performWithDelay(500, frogMove)
		
		local function hopSound()
			playSFX(sndJump)
		end
		timer.performWithDelay( frogJumpSpeed / 4, hopSound)
		
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

loadPrefs()

local bg = display.newImageRect("images/bg_iPhone.png", 480, 320)
bg.x = centerX
bg.y = centerY

for y = 1, 4 do
	for x = 1, 6 do
		idx = idx + 1
		local pad = display.newImageRect("images/lilypad_green.png", 64, 64)
		pad:rotate( math.random ( 0, 360 ) )
		pad.x = (x * 75) - 23
		pad.y = y * 70
		local sizer = 1 + math.random(-1, 1) / 10
		pad:scale ( sizer, sizer )
		pad:addEventListener ( "touch", padTouched )
		pads[idx] = pad
		pads[idx].idx = idx
	end
end

frog = display.newImage("images/frog.png", 64, 95)
frog.x = 52
frog.y = 70
frog:addEventListener ( "tap", frogTapped )

fly = display.newImageRect ( "images/fly.png", 32, 22 )
fly.x = centerX
fly.y = 15
fly:addEventListener ( "touch", flyTouched )

playMusic()

scoreLabel = display.newText( "Score: ", 0, 0, native.systemFont, 18 )
scoreLabel.x = 380
scoreLabel.y = 10
scoreLabel:addEventListener ( "tap", resetScore )

scoreObj = display.newText( tostring(score), 0, 0, native.systemFont, 18 )
--scoreObj:setReferencePoint(display.CenterLeftReferencePoint)
scoreObj.anchorX = 0
scoreObj.x = scoreLabel.x + (scoreLabel.width/2)
scoreObj.y = scoreLabel.y

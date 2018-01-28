-- Project: GameDev-05-Audio
-- Copyright 2012-2014 Three Ring Ranch
-- http://MasteringCoronaSDK.com

-- UPDATE use widgets instead of buttoncode
local widget = require("widget")

display.setStatusBar(display.HiddenStatusBar)

centerX = display.contentWidth * .5
centerY = display.contentHeight * .5

local audioIsPlaying = true

audio.reserveChannels( 1 )

sndChanMusic = 1
sndChanSFX = 2

local sndBuhBuh = audio.loadSound ( "audio/bubububuh.mp3" )
local sndWhip = audio.loadSound ( "audio/whip.mp3" )
local sndYipYip = audio.loadSound ( "audio/yipyip.mp3" )
local sndWhoo = audio.loadSound ( "audio/whoo.mp3" )
local sndJump = audio.loadSound ( "audio/boing.mp3" )

local sndMusic = audio.loadStream ( "audio/HappyPants.wav" )

local allSFX = { sndBuhBuh, sndWhip, sndYipYip, sndWhoo, sndJump }

local function playSound(audioObj, chn)

	local chanUsed = nil

    if audioIsPlaying then
		chanUsed = audio.play( audioObj, { channel=chn } ) 
    end
    return chanUsed
end

local function resetMusic(event)
	if event.completed == false and event.phase == "stopped" then
		audio.setVolume ( 1, { channel=sndChanMusic } )
		audio.rewind ( sndMusic )
	end
end

-- UPDATE pass in event, get action from that
local function playMusic(event)
    local action = event.target.action
    
    if action == "play" then
        if audioIsPlaying then
            audio.play(sndMusic, {channel=sndChanMusic, onComplete=resetMusic} )
        end
    elseif action == "stop" then
        audio.stop ( sndChanMusic )
        audio.rewind ( sndChanMusic )
    elseif action == "fade out" then
        audio.fadeOut ( {channel=sndChanMusic, time=3000} )
    end
end

-- UPDATE new function
local function makeButton(title, xPos, yPos, listener, action)
   local btn = widget.newButton( {label=title, onRelease=listener} )
   btn.action = action
   btn.x = xPos
   btn.y = yPos
end

makeButton("Play Music", centerX-100, 80, playMusic, "play")
makeButton("Stop & Rewind", centerX-100, 120, playMusic, "stop")
makeButton("Fade Out", centerX-100, 160, playMusic, "fade out")

local function playSFX(event)
	local snd = event.target.action
	playSound(snd, 0)  -- 0 = corona automatticaly chooses the next channel if multiple sndfx are used 
end

for x = 1, #allSFX do
	makeButton("Play SFX", centerX+100, 40 + (40 * x), playSFX, allSFX[x])
end


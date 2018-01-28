-- Project: GameDev-08-Storyboard
-- Copyright 2012 Three Ring Ranch
-- http://MasteringCoronaSDK.com

--test

local storyboard = require("storyboard")
GGData = require("GGData")
local prefs = GGData:new("preferences")
widget = require("widget")
--widget.setTheme("widget_theme_ios")
local physics = require("physics")

math.randomseed( os.time() )

physics.start()
physics.setGravity(0, 0)
physics.setDrawMode("normal") --debug, hybrid, normal

display.setStatusBar(display.HiddenStatusBar)

centerX = display.contentWidth * .5
centerY = display.contentHeight * .5

musicIsPlaying = true
sfxIsPlaying = true

levelImages = {
    {picFile="images/lilypad_green.png", kind="lilypad"},
    {picFile="images/rock.png", kind="rock"},
    {picFile="images/lilypad_teal.png", kind="lilypad"},
    {picFile="images/lilypad_orange.png", kind="lilypad"}
}

local function loadPrefs()
	prefs:load()
	musicIsPlaying = prefs.musicIsPlaying
	sfxIsPlaying = prefs.sfxIsPlaying
end

function savePrefs()
	prefs.musicIsPlaying = musicIsPlaying
	prefs.sfxIsPlaying = sfxIsPlaying
	prefs:save()
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



function makeButton(title, xPos, yPos, listener, action, grp)
   local btn = widget.newButton( {label=title, labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }, onRelease=listener} )
   btn.x = xPos
   btn.y = yPos
   btn.action = action
   if grp then
   	grp:insert(btn)
   end
   
end

loadPrefs()

storyboard.gotoScene ( "play", { effect = "slideUp" } )
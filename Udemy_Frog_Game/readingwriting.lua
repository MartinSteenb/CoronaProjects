-- Project: GameDev-07-ReadingWriting
-- Copyright 2012 Three Ring Ranch
-- http://MasteringCoronaSDK.com

display.setStatusBar(display.HiddenStatusBar)

centerX = display.contentWidth * .5
centerY = display.contentHeight * .5

--[[ =========================================

system.DocumentsDirectory - for files that need to persist between application sessions
system.TemporaryDirectory - for temporary files during application session
system.ResourceDirectory - for application assets - never create, modify, or add files here

--==========================================]]

local path
local file

local data = "Unless you have definite precise, clearly set goals, you are not going to realize the maximum potential that lies within you. - Zig Ziglar"
local score = 147

--======== write data to file

--path = system.pathForFile ( "highscore.txt",  system.DocumentsDirectory )
--
--file = io.open(path, "a")
--file:write(score .. "\n")
--io.close(file)


--======== read data from file

local savedData

path = system.pathForFile ( "story.txt",  system.ResourceDirectory )

file = io.open ( path, "r" )
savedData = file:read("*a")
io.close(file)

local myText = display.newText(savedData, 10, 10, display.contentWidth-20, 0, native.systemFont, 16)

----print(savedData)
--
--path = system.pathForFile ( "highscore.txt",  system.DocumentsDirectory )
--file = io.open(path, "r")
--local idx = 1
--for x in file:lines() do
--	--display.newText( tostring(x), 100, 40 * idx, "Helvetica", 24 )
--	idx = idx + 1
--end
--io.close ( file )
--
--========= using a loadfile routine

-- load a text file and return it as a string
local function loadTextFile( fname, base )
	base = base or system.ResourceDirectory
	local path = system.pathForFile( fname, base )
	local txtData
	local file = io.open( path, "r" )
	if file then
	   txtData = file:read( "*a" )
	   io.close( file )
	end
	return txtData
end

savedData = loadTextFile("story.txt")

--print(savedData)


--========= using a 3rd-party library - GGData

local GGData = require("GGData")

local scores = GGData:new("gamescores")

--scores.playername = "Jay"
--
--local gameScores = {345, 219, 200, 195, 12}
--
--scores.highscores = gameScores
--
--scores:save()
--
--print(scores.playername)

local myData = scores.highscores

print(myData[1], myData[2], myData[5])



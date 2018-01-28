-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")

-- Hide status bars
display.setStatusBar(display.HiddenStatusBar)
 
-- Seed the random number generator
math.randomseed(os.time())

composer.gotoScene("menu")
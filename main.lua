Class = require "class"
Input = require "Input"
Lsystem = require "Lsystem"
Turtle = require "Turtle"

lg = love.graphics
random = math.random

function love.load()
    lg.setBackgroundColor(0.06, 0.1, 0.15)
    
    -- Exit
    Input:keypress("escape", love.event.push, "quit")

    triangle = sierpinski(6):play()
    Input:keypress("s", function() triangle:finish() end)
    Input:keypress("space", function() triangle:reset():play() end)
end

function sierpinski(iterations)
    -- Rules adapted from https://en.wikipedia.org/wiki/L-system

    -- Creating system
    local system = Lsystem():axiom("F-F-F")
    system:rule("F", "F-G+F+G-F"):rule("G", "GG")

    local turtle = Turtle(40, 100):speed(500):ht()
    local angle  = 120
    local step   = 10
    local hue    = 0
    local str    = system:applyRules(iterations)

    for char in str:gmatch(".") do
        if char == "F" or char == "G" then
            turtle:fd(step):color(HSL(hue, 0.8, 0.7))
            hue = hue + 0.01
            if hue > 1 then hue = 0 end
        elseif char == "+" then
            turtle:lt(angle)
        elseif char == "-" then
            turtle:rt(angle)
        end
    end

   return turtle 
end

function love.update(dt)
    Input:update(dt)
    triangle:update(dt)
end

function love.draw()
    triangle:draw()

    lg.setColor(0.5, 0.9, 0.2)
    lg.printf("Press space to restart the animation and s to skip it", 0, lg.getHeight() * 0.95, lg.getWidth(), "center")
end

function love.keypressed(key)
    Input:keypressed(key)	
end

function love.keyreleased(key)
    Input:keyreleased(key)
end

-- Source: https://love2d.org/wiki/HSL_color
function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h*6, s, l
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return r+m, g+m, b+m, a
end

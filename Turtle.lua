-- Shorthands
local sin, cos, rad = math.sin, math.cos, math.rad
local lg = love.graphics

local vec2 = require "vec2"

---------------------------------------------- CLASS MODULE ----------------------------------------------
local classMetatable = {
    __index = function(self, key) return self.__baseClass[key] end,
    __call = function(self, ...) return self:new(...) end
}
local Class = setmetatable( { __baseClass = {}, __type = "class"}, classMetatable)

function Class:new(...)
    local prototype = setmetatable({__baseClass = self}, getmetatable(self))
    local arguments = {...}
    if type(arguments[1]) == "function" then
        prototype.init = arguments[1]
    end
    if prototype.init then prototype:init(...)end
    return prototype
end

----------------------------------------------- NODE MODULE ----------------------------------------------
local Node = Class()
function Node:init(position, length, angle, color, size, dot, beginFill, endFill)
    self.position  = position:clone()
    self.length    = length
    self.angle     = angle
    self.color     = color
    self.size      = size
    self.dot       = dot or false
    self.beginFill = beginFill or false
    self.endFill   = endFill or false

    self.progress = 0
end

-- Resets node animation
function Node:reset() self.progress = 0 end

-- Finishes node animation
function Node:finish() self.progress = 1 end

-- Calculates and returns the vertices that make up a node
function Node:getVertices()
    -- Calculating where this node ends
    local x = self.position.x + (self.length * self.progress) * cos(self.angle)
    local y = self.position.y + (self.length * self.progress) * sin(self.angle)
    return self.position.x, self.position.y, x, y
end

---------------------------------------------- TURTLE MODULE ----------------------------------------------
local turtle = Class()
function turtle:init(x, y)
    self.position    = vec2(x, y)
    self._home       = vec2(x, y)
    self.angle       = 0
    self.visible     = true
    self.nodes       = {}
    self._drawTurtle = function(x, y)
        lg.setColor(1, 1, 1, 1)
        lg.circle("fill", x, y, 5)
    end
    self._onComplete = function() end
    
    self.pen = {
        color = {1, 1, 1, 1},
        size = 1,
        down = true
    }

    self.animation = {
        node = 1,
        speed = 1,
        playing = false
    }
    return self
end

function turtle:tp(x)
    self.position.x = self.position.x + x * cos(self.angle)
    self.position.y = self.position.y + x * sin(self.angle)
    return self
end

-- Move turtle forward x pixels
function turtle:forward(x)
    if self.pen.down then self.nodes[#self.nodes + 1] = Node(self.position, x, self.angle, self.pen.color, self.pen.size) end

    self.position.x = self.position.x + x * cos(self.angle)
    self.position.y = self.position.y + x * sin(self.angle)
    return self
end
turtle.fd = turtle.forward

-- Move turtle backward x pixels
function turtle:backward(x)
    if self.pen.down then self.nodes[#self.nodes + 1] = Node(self.position, x, self.angle, self.pen.color, self.pen.size) end

    self.position.x = self.position.x - x * cos(self.angle)
    self.position.y = self.position.y - x * sin(self.angle)
    return self
end
turtle.bk = turtle.backward
-- Move the turtle to the starting position
function turtle:home()
    if self.pen.down then 
        self.nodes[#self.nodes + 1] = Node(self.position, vec2.distance(self.position, self._home), vec2.angle(self.position, self._home), self.pen.color, self.pen.size) 
    end

    self.position = self._home:clone()
    return self
end

function turtle:goto(x, y)
    local destination = vec2(x, y)
    if self.pen.down then 
        self.nodes[#self.nodes + 1] = Node(self.position, vec2.distance(self.position, destination), vec2.angle(self.position, destination), self.pen.color, self.pen.size) 
    end

    self.position = self.destination:clone()
    return self
end

function turtle:dot()
    if self.pen.down then self.nodes[#self.nodes + 1] = Node(self.position, self.pen.size, self.angle, self.pen.color, self.pen.size, true) end
    return self
end

-- Turn right by x degrees
function turtle:right(x)
    self.angle = self.angle + rad(x)
    return self
end
turtle.rt = turtle.right

-- Turn left by x degrees
function turtle:left(x)
    self.angle = self.angle - rad(x)
    return self
end
turtle.lt = turtle.left

function turtle:setHeading(x)
    self.angle = rad(x)
end

function turtle:setPosition(x, y)
    self.position:set(x, y)
end

function turtle:penSize(x)
    self.pen.size = x or 1
    return self
end
turtle.ps = turtle.penSize

function turtle:beginFill()
    if self.pen.down then self.nodes[#self.nodes + 1] = Node(self.position, 0, 0, self.pen.color, self.pen.size, false, true) end
    return self
end
turtle.bf = turtle.beginFill

function turtle:endFill()
    if self.pen.down then self.nodes[#self.nodes + 1] = Node(self.position, 0, 0, self.pen.color, self.pen.size, false, false, true) end
    return self
end
turtle.ef = turtle.endFill

function turtle:penDown()
    self.pen.down = true
    return self
end
turtle.pd = turtle.penDown

function turtle:penUp()
    self.pen.down = false
    return self
end
turtle.pu = turtle.penUp

function turtle:color(r, g, b, a)
    local color = {r, g, b, a or 1}
    if type(r) == "number" then
        if not g and not b and not a then
            color = {r, r, r, 1}
        end
    elseif type(r) == "table" then
        color = r
    end

    self.pen.color = color
    return self
end
turtle.c = turtle.color

function turtle:speed(x)
    self.animation.speed = x
    return self
end
turtle.sp = turtle.speed

function turtle:drawTurtle(fn)
    self._drawTurtle = fn 
    return self
end

function turtle:onComplete(fn)
    self._onComplete = fn
    return self
end

function turtle:showTurtle()
    self.visible = true
    return self
end
turtle.st = turtle.showTurtle

function turtle:hideTurtle()
    self.visible = false
    return self
end
turtle.ht = turtle.hideTurtle

function turtle:isVisible() return self.visible end

-- Reset turtle animation
function turtle:reset()
    self.animation.node = 1
    self.animation.playing = false
    for _, node in ipairs(self.nodes) do node:reset() end
    return self
end

function turtle:finish()
    self.animation.playing = false
    for _, node in ipairs(self.nodes) do node:finish() end
    return self
end

-- Play turtle animation
function turtle:play()
    if #self.nodes < 1 then return self end
    self.animation.playing = true
    return self
end

function turtle:pause() self.animation.playing = false end

function turtle:stop()
    self:reset()
    self.animation.playing = false
end

function turtle:update(dt)
    if self.animation.playing then
        for i=1, self.animation.speed do
            local node = self.nodes[self.animation.node]
            node.progress = node.progress + (1 / node.length) * dt
            if node.progress > 1 then
                node.progress = 1
                self.animation.node = self.animation.node + 1
                if self.animation.node > #self.nodes then
                    self.animation.node = #self.nodes
                    self._onComplete()
                    self.animation.playing = false
                end
            end
            local _, _, x, y = node:getVertices()
            self.position:set(x, y)
        end

    end
end

function turtle:draw()
    local shapeIndex = 0
    local fill = false
    local shapes = {}

    for _, node in ipairs(self.nodes) do
        local x, y, x2, y2 = node:getVertices()
        lg.setColor(node.color)

        if node.beginFill then
            fill = true
            shapeIndex = shapeIndex + 1
            shapes[shapeIndex] = {
                color = node.color,
                vertices = {}
            }
        elseif node.endFill then
            fill = false
        end

        if node.dot then
            lg.setLineWidth(1)
            lg.circle("fill", x, y, node.size * node.progress)
        else
            if fill and node.progress > 0 then
                shapes[shapeIndex].vertices[#shapes[shapeIndex].vertices + 1] = x2
                shapes[shapeIndex].vertices[#shapes[shapeIndex].vertices + 1] = y2

                if #shapes[shapeIndex].vertices > 5 then
                    lg.polygon("fill", shapes[shapeIndex].vertices)
                end
            else
                lg.setLineWidth(node.size)
                lg.line(x, y, x2, y2)
            end
        end
    end

    -- Turtle
    if self.visible then
        self._drawTurtle(self.position:get())
    end
end

return turtle

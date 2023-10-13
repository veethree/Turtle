local input = {
    bindings = {
        keypress = {},
        keyrelease = {},
        keydown = {},
        mousepress = {},
        mouserelease = {},
        mousedown = {}
    },
    keys = {},
    mouseButtons = {}
}

--::| Utility |::--
function input:newBinding(event, keys, fn, ...)
    if type(keys) == "string" or type(keys) == "number" then keys = {keys} end
    for _,key in ipairs(keys) do
        if not self.bindings[event][key] then self.bindings[event][key] = {} end
        self.bindings[event][key][#self.bindings[event][key]+1] = {
            fn = fn,
            args = {...}
        }
    end
end

function input:trigger(event, key)
    if self.bindings[event][key] then
        for _, binding in ipairs(self.bindings[event][key]) do
            local mx, my = love.mouse:getPosition()
            if event == "mousepress" or event == "mouserelease" or event == "mousedown" then
                binding.fn(mx, my, unpack(binding.args))
            else
                binding.fn(unpack(binding.args))
            end
        end
    end
end

--::| Keyboard |::--
function input:keypress(keys, fn, ...)
    self:newBinding("keypress", keys, fn, ...)
end

function input:keyrelease(keys, fn, ...)
    self:newBinding("keyrelease", keys, fn, ...)
end

function input:keydown(keys, fn, ...)
    self:newBinding("keydown", keys, fn, ...)
end

--::| Mouse |::--
function input:mousepress(keys, fn, ...)
    self:newBinding("mousepress", keys, fn, ...)
end

function input:mouserelease(keys, fn, ...)
    self:newBinding("mouserelease", keys, fn, ...)
end

function input:mousedown(keys, fn, ...)
    self:newBinding("mousedown", keys, fn, ...)
end

--::| CALLBACKS |::--
function input:keypressed(key)
    self:trigger("keypress", key)
    self.keys[key] = key
end

function input:keyreleased(key)
    self:trigger("keyrelease", key)
    self.keys[key] = nil
end

function input:mousepressed(x, y, key)
    self:trigger("mousepress", key)
    self.mouseButtons[key] = key
end

function input:mousereleased(x, y, key)
    self:trigger("mouserelease", key)
    self.mouseButtons[key] = nil
end

function input:update()
    for _,key in pairs(self.keys) do
        self:trigger("keydown", key)
    end
    for _,key in pairs(self.mouseButtons) do
        self:trigger("mousedown", key)
    end
end

return setmetatable(input, {__index = input})

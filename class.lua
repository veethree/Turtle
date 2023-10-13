local classMetatable = {
    __index = function(self, key) return self.__baseClass[key] end,
    __call = function(self, ...) return self:new(...) end
}
local class = setmetatable( { __baseClass = {}, __type = "class"}, classMetatable)

function class:new(...)
    local prototype = setmetatable({__baseClass = self}, getmetatable(self))
    local arguments = {...}
    if type(arguments[1]) == "function" then
        prototype.init = arguments[1]
    end
    if prototype.init then prototype:init(...)end
    return prototype
end

function class.extend(parent, ...)
    local prototype = setmetatable({__baseClass = parent, __super = parent}, getmetatable(parent))
    return prototype
end

return class
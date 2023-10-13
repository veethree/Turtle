local lsystem = Class()

function lsystem:init()
    self._axiom = ""
    self.rules = {}
    return self
end

function lsystem:axiom(axiom)
    self._axiom = axiom
    return self
end

function lsystem:rule(target, substitute)
    self.rules[#self.rules + 1] = {
        target = target, substitute = substitute
    }
    return self
end

function lsystem:applyRules(iteration, str)
    if iteration < 1 then return str end 

    local result = ""
    for char in (str or self._axiom):gmatch(".") do
        local newChar = char
        for _, rule in ipairs(self.rules) do
            if char == rule.target then
                newChar = rule.substitute
                break
            end
        end
        result = result .. newChar
    end


    return self:applyRules(iteration - 1, result)
end

return lsystem

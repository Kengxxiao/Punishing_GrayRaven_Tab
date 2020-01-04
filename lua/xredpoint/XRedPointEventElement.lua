--事件单元
local XRedPointEventElement = XClass()
--
function XRedPointEventElement:Ctor(id, args)
    self.EventId = id
    self.EventArgs = args
end

function XRedPointEventElement:Equal(id, arg)
    if self.EventId ~= id then
        return false
    end

    if not self.EventArgs then
        return true
    end

    for i, v in ipairs(self.EventArgs) do
        if v == arg then
            return true
        end
    end

    return false
end

return XRedPointEventElement
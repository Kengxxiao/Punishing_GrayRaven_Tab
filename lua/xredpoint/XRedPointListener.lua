
--[[
监听者个体类
XRedPointListener.listener 监听者
XRedPointListener.func 监听函数
]]--
local XRedPointListener = XClass()

function XRedPointListener:Ctor()
    
end 

function XRedPointListener:Release()
    self.listener = nil
    self.func = nil
end

function XRedPointListener:Call(result,args)
    if self.listener and self.func then
        self.func(self.listener,result,args)
    elseif self.func then
        self.func(result,args)
    end
end

return XRedPointListener

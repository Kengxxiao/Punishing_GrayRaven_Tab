local math = math

local mathFloor = math.floor
local mathCeil = math.ceil
local mathRandom = math.random

XMath = XMath or {}

function XMath.RandByWeights(weights)
    local weightSum = 0
    for i = 1, #weights do
        weightSum = weightSum + weights[i]
    end

    local rand = mathRandom(weightSum)
    local curWeight = 0
    for i = 1, #weights do
        local weight = weights[i]
        curWeight = curWeight + weight
        if rand < curWeight then
            return i
        end
    end
    
    return #weights
end

function XMath.Clamp(value, min, max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end


--==============================--
--desc: 转换成整数，浮点数四舍五入
--==============================--
XMath.ToInt = function(val)
    if not val then return end
    return mathFloor(val + 0.5)
end

--==============================--
--desc: 转换成整数，浮点数向下取整数
--==============================--
XMath.ToMinInt = function(val)
    if not val then return end
    return mathFloor(val)
end

--==============================--
--desc: 最大整数，与C#一致
--==============================--
XMath.IntMax = function()
    return 2147483647
end
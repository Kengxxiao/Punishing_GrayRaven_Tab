local XCharacterExpTemplate = {}

function XCharacterExpTemplate.New(itemTemplate)
    local extendObj = {
        UpType = itemTemplate.SubTypeParams[1],
        Exp = itemTemplate.SubTypeParams[2],
        UpPercentage = itemTemplate.SubTypeParams[3] / 100 - 100,
        UpMultiple = itemTemplate.SubTypeParams[3] / 10000
    }

    extendObj.GetExp = function(cardType)
        if cardType == extendObj.UpType then
            return XMath.ToMinInt(extendObj.Exp * extendObj.UpMultiple)
        end
        
        return extendObj.Exp
    end

    return setmetatable({}, {
        __metatable = "readonly table",
        __index = function(tab, k)
            if extendObj[k] ~= nil then
                return extendObj[k]
            else
                return itemTemplate[k]
            end
        end,
        __newindex = function(tab, k, v)
            XLog.Error("attempt to update a readonly table")
        end,
    })
end

return XCharacterExpTemplate
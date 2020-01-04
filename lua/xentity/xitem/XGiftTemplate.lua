local XGiftTemplate = {}

function XGiftTemplate.New(itemTemplate)
    local extendObj = {
        GiftType = itemTemplate.SubTypeParams[1],
        RewardId = itemTemplate.SubTypeParams[2],
        SelectCount = itemTemplate.SubTypeParams[3],
    }

    return setmetatable({}, {
        __metatable = false,
        __index = function(tab, k)
            if extendObj[k] ~= nil then
                return extendObj[k]
            else
                return itemTemplate[k]
            end
        end,
    })
end

return XGiftTemplate
local effectNode
local effects = {}
local playingEffect
local format = string.format

local Init = function(node)
    if not node then
        XLog.Warning("XUiDrawShowEffect: Init with nil.")
        return
    end
    if effectNode then
        XLog.Warning("XUiDrawShowEffect: Reset effectNode.")
    end
    effectNode = node
end

local PlayEffect = function(name)
    if not effectNode then
        XLog.Warning("XUiDrawShowEffect: Play effect without Init.")
        return
    end
    
    if not name or type(name) ~= "string" then
        XLog.Warning(format("XUiDrawShowEffect: Invalid name: %s.", name))
    end

    if not effects[name] then
        local effect = effectNode:Find(name)
        if effect then
            effects[name] = effect.gameObject
        else
            XLog.Warning(format("XUiDrawShowEffect: Effect not found. Name: %s", name))
            return
        end
    end
    
    if effects[name]:Exist() then
        if playingEffect and playingEffect:Exist() then
            playingEffect:SetActive(false)
        end
        effects[name]:SetActive(false)
        effects[name]:SetActive(true)
    else
        XLog.Warning(format("XUiDrawShowEffect: UnityObject has been destroyed. Name: %s", name))
        return
    end
end

local HideEffect = function(name)
    if not name or type(name) ~= "string" then
        XLog.Warning("XUiDrawShowEffect: Invalid name.")
    end

    if effects[name] and effects[name]:Exist() then
        effects[name]:SetActive(false)
    else
        XLog.Warning(format("XUiDrawShowEffect: Effect not found. Name: %s", name))
    end
end

local HideAll = function()
    for k, v in pairs(effects) do
        if v:Exist() then
            v:SetActive(false)
        else
            effects[k] = nil
        end
    end
end

local Dispose = function()
    effectNode = nil
    for k, v in pairs(effects) do
        effects[k] = nil
    end
    effects = {}
    effectNode = nil
end

local DrawShowEffect = {}

DrawShowEffect.Init = Init
DrawShowEffect.PlayEffect = PlayEffect
DrawShowEffect.HideEffect = HideEffect
DrawShowEffect.HideAll = HideAll
DrawShowEffect.Dispose = Dispose

return DrawShowEffect
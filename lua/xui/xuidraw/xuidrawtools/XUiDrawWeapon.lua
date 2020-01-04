local Object = CS.UnityEngine.Object
local Model
local node
local anim
local beginAnim = "WeaponShowBegan"
local resultAnim = "WeaponShowLoop"

local SetNode = function(weaponNode, animNode)
    node = weaponNode    
    anim = animNode:GetComponent("Animation")
end

local Load = function(equipId, refName)
    local modelConfig = XDataCenter.EquipManager.GetWeaponModelCfgByEquipId(equipId, refName)
    if modelConfig then
        XModelManager.LoadWeaponModel(modelConfig.ModelName, node, CS.XResourceRefType.Ui, modelConfig.TransfromConfig, function(model)
            Model = model
        end)
    end
end

local PlayAnim = function()
    if not anim then
        XLog.Warning("XUiDrawWeapon: Missing animation.")
        return
    end
    anim:Play(beginAnim)
end

local PlayResultAnim = function()
    if not anim then
        XLog.Warning("XUiDrawWeapon: Missing animation.")
        return
    end
    anim:Play(resultAnim)
end

local Destroy = function()
    if Model then
        Object.Destroy(Model.gameObject)
        Model = nil
    end
end

local XUiDrawWeapon = {}

XUiDrawWeapon.SetNode = SetNode
XUiDrawWeapon.Load = Load
XUiDrawWeapon.Destroy = Destroy
XUiDrawWeapon.PlayAnim = PlayAnim
XUiDrawWeapon.PlayResultAnim = PlayResultAnim

return XUiDrawWeapon
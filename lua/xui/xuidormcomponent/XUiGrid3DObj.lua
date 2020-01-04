local XUiGrid3DObj = XClass()

function XUiGrid3DObj:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGrid3DObj:RefreshEffect(effectId, bindWorldPos)
    if self.EffectId == effectId then 
        return
    end
    self.EffectId = effectId

    local effectConfig = XDormConfig.GetMoodEffectConfig(effectId)
    self.EffectObj = self.Transform:LoadPrefab(effectConfig.Path)
    self.EffectObj.transform:SetParent(self.PanelEffectObj, false)

    if bindWorldPos then
        self.PanelEffectObj.transform.position = bindWorldPos
    else
        local position = CS.UnityEngine.Vector3(0, effectConfig.Hight, 0)
        self.PanelEffectObj.transform.localPosition = position
    end
end

function XUiGrid3DObj:Show(characterId, effectId, transform, bindWorldPos)
    local styleConfig = XDormConfig.GetCharacterStyleConfigById(characterId)
    local position = CS.UnityEngine.Vector3(0, styleConfig.EffectWidgetHight, 0)
    self.Transform:SetParent(transform, false)
    self.Transform.localPosition = position
    self.GameObject:SetLayerRecursively(transform.gameObject.layer)

    self:RefreshEffect(effectId, bindWorldPos)
    self.BtnClick.gameObject:SetActive(false)
    self.GameObject:SetActive(true)
end

function XUiGrid3DObj:Hide()
    self.EffectObj = nil
    self.EffectId = 0
    self.GameObject:SetActive(false)
end

return XUiGrid3DObj
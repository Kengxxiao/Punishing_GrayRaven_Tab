local XUiGridCondition = XClass()

function XUiGridCondition:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridCondition:Refresh(conditionId, characterId)
    if not conditionId or conditionId == 0 then
        self.GameObject:SetActive(false)
        return true
    end
    self.GameObject:SetActive(true)

    local passed, desc = XConditionManager.CheckCondition(conditionId, characterId)
    self.TxtPass.text = desc
    self.TxtNotPass.text = desc
    self.TxtPass.gameObject:SetActive(passed)
    self.TxtNotPass.gameObject:SetActive(not passed)

    return passed
end

return XUiGridCondition
XUiStageFightControl = XClass()
--战力限制组件
function XUiStageFightControl:Ctor(ui, stageFightControlId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:UpdateInfo(stageFightControlId)
end

function XUiStageFightControl:UpdateInfo(stageFightControlId)
    self.StageFightControlId = stageFightControlId
    self.Extremely.gameObject:SetActive(false)
    self.Hard.gameObject:SetActive(false)
    self.Normal.gameObject:SetActive(false)
    self.GameObject:SetActiveEx(false)
    local data = XFubenConfigs.GetStageFightControl(self.StageFightControlId)
    if not data or data.RecommendFight <= 0 then
        return
    end
    local charlist = XDataCenter.CharacterManager.GetCharacterList()
    local maxAbility = 0
    for k, v in pairs(charlist) do
        if v.Ability and v.Ability > maxAbility then
            maxAbility = v.Ability
        end
    end
    maxAbility = math.floor(maxAbility)
    if data ~= nil then
        --极度困难
        if maxAbility < data.RecommendFight then
            self.Extremely.gameObject:SetActive(true)
            self.TxtExCurNum.text = maxAbility
            self.TxtExMaxNum.text = data.ShowFight
            self.GameObject:SetActiveEx(true)
            --困难
        elseif maxAbility >= data.RecommendFight and maxAbility < data.ShowFight then
            self.Hard.gameObject:SetActive(true)
            self.TxtHardCurNum.text = maxAbility
            self.TxtHardMaxNum.text = data.ShowFight
            self.GameObject:SetActiveEx(true)
            --普通（不显示）
        elseif maxAbility >= data.ShowFight then

        end
    end
end
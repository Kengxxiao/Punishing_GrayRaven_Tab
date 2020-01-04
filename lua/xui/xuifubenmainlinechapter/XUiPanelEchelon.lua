local MAX_ECHELON_NUM = 3

local XUiPanelEchelon = XClass()
 
function XUiPanelEchelon:Ctor(ui,stageId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId

    XTool.InitUiObject(self)
    self:Refresh()
end

function XUiPanelEchelon:Refresh()
    local groupId = XDataCenter.BfrtManager.GetGroupIdByBaseStage(self.StageId)

    local fightInfoList = XDataCenter.BfrtManager.GetFightInfoIdList(groupId)
    local echelonNum = #fightInfoList
    for i = 1, echelonNum do
        self["ImgEchelon" .. i].gameObject:SetActive(true)
    end
    for i = echelonNum + 1, MAX_ECHELON_NUM do
        self["ImgEchelon" .. i].gameObject:SetActive(false)
    end
    
    local logisticsInfoList = XDataCenter.BfrtManager.GetLogisticsInfoIdList(groupId)
    local logisticsNum = #logisticsInfoList
    for i = 1, logisticsNum do
        self["ImgEchelonLogiistics" .. i].gameObject:SetActive(true)
    end
    for i = logisticsNum + 1, MAX_ECHELON_NUM do
        self["ImgEchelonLogiistics" .. i].gameObject:SetActive(false)
    end
end

return XUiPanelEchelon

local XUiPanelRewardTips = XClass()

function XUiPanelRewardTips:Ctor(ui,parent,stageId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.StageId = stageId
    self:InitAutoScript()
    self:Refresh()
end

function XUiPanelRewardTips:Refresh()
    local stageCfg = XDataCenter.FubenManager.GetstageCfg(self.StageId)
    local rewardTipId = stageCfg.RewardTipId
    local rewardTipIcon, rewardTipQuality = self:GetIconById(rewardTipId)
    if rewardTipIcon then
        self.RImgIcon:SetRawImage(rewardTipIcon)
        XUiHelper.SetQualityIcon(self.Parent, self.ImgQuality, rewardTipQuality)
    end
end

function XUiPanelRewardTips:GetIconById(id)
    if not id or id == 0 then return nil end
    return XGoodsCommonManager.GetGoodsIcon(id), XGoodsCommonManager.GetGoodsDefaultQuality(id)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelRewardTips:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelRewardTips:AutoInitUi()
    self.RImgIcon = self.Transform:Find("RImgIcon"):GetComponent("RawImage")
    self.ImgQuality = self.Transform:Find("ImgQuality"):GetComponent("Image")
end

function XUiPanelRewardTips:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelRewardTips:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelRewardTips:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelRewardTips:AutoAddListener()
end
-- auto

return XUiPanelRewardTips

XUiPanelNewbieActive = XClass()

local normalSize =  CS.XGame.ClientConfig:GetInt("NewPlayerTaskSmallSize")
local specialSize =  CS.XGame.ClientConfig:GetInt("NewPlayerTaskBigSize")

function XUiPanelNewbieActive:Ctor(ui, rootUi, index, stageInfo)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.RootUi = rootUi
    self.Index = index
    self.TxtValue.text = stageInfo
    self.ImgActiveRect = self.GridCommon:GetComponent("RectTransform")
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelNewbieActive:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelNewbieActive:AutoInitUi()
    self.BtnActive = self.Transform:Find("BtnActive"):GetComponent("Button")
    self.TxtValue = self.Transform:Find("TxtValue"):GetComponent("Text")
    self.PanelEffect = self.Transform:Find("PanelEffect")
    self.ImgRe = self.Transform:Find("ImgRe"):GetComponent("Image")
    self.GridCommon = self.Transform:Find("Grid128")
end

function XUiPanelNewbieActive:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelNewbieActive:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelNewbieActive:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelNewbieActive:AutoAddListener()
    self:RegisterClickEvent(self.BtnActive, self.OnBtnActiveClick)
end
-- auto

function XUiPanelNewbieActive:UpdateNewbieActiveView(currentActiveness, maxActiveness)
    self.CurrentActiveness = currentActiveness
    self.MaxActiveness = maxActiveness
    local newbieActiveness = XTaskConfig.GetTaskNewbieActivenessTemplate()
    local rewardId = newbieActiveness.RewardId[self.Index or 1]
    local count = #newbieActiveness.RewardId
    local data = XRewardManager.GetRewardList(rewardId)

    if #data >= 1 then
        if not self.GridComp then
            self.GridComp = XUiGridCommon.New(self.RootUi, self.GridCommon)
        end
        self.GridComp:Refresh(data[1])
        self.GridComp:ShowCount(false)
    end
    local adjustSizeX = (self.Index == count) and specialSize or normalSize
    self.ImgActiveRect.sizeDelta = CS.UnityEngine.Vector2(adjustSizeX, adjustSizeX)

    local newbieActiveness = XTaskConfig.GetTaskNewbieActivenessTemplate()
    local activeness = newbieActiveness.Activeness[self.Index or 1]

    if XDataCenter.TaskManager.CheckNewbieActivenessRecord(activeness) then
        self:ChangeActiveState(true, false)
    else
        if currentActiveness >= activeness then
            self:ChangeActiveState(false, true)
        else
            self:ChangeActiveState(false, false)
        end
    end
end

function XUiPanelNewbieActive:ChangeActiveState(imgRe, effect)
    self.ImgRe.gameObject:SetActive(imgRe)
    self.PanelEffect.gameObject:SetActive(effect)
end

function XUiPanelNewbieActive:OnBtnActiveClick(eventData)
    if self.CurrentActiveness and self.MaxActiveness then
        local newbieActiveness = XTaskConfig.GetTaskNewbieActivenessTemplate()
        local activeness = newbieActiveness.Activeness[self.Index or 1]
        local templateId = newbieActiveness.RewardId[self.Index or 1]
        local rewardList = XRewardManager.GetRewardList(templateId)

        if XDataCenter.TaskManager.CheckNewbieActivenessRecord(activeness) then--已经领取
            self:ShowTipsByType(rewardList)
        else
            if self.CurrentActiveness >= activeness then--可领取
                XDataCenter.TaskManager.GetNewPlayerRewardReq(activeness, rewardList, function()
                    self.RootUi:RefreshBottomView()
                end)
            else--还不能领取
                self:ShowTipsByType(rewardList)
            end
        end
    end

end

function XUiPanelNewbieActive:ShowTipsByType(rewardList)
    for k, v in pairs(rewardList or {}) do
        local templateId = v.TemplateId
        local goodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(templateId)
        if goodsShowParams.RewardType == XRewardManager.XRewardType.Character then
            if self.RootUi.Ui.UiData.UiType == CsXUiType.Tips then
                self.RootUi:Close()
            end
            XLuaUiManager.Open("UiCharacterDetail", templateId)
        elseif goodsShowParams.RewardType == XRewardManager.XRewardType.Equip then
            if self.RootUi.Ui.UiData.UiType == CsXUiType.Tips then
                self.RootUi:Close()
            end
            XLuaUiManager.Open("UiEquipDetail", templateId, true)
        else
            XLuaUiManager.Open("UiTip", templateId)
        end
        break
    end
    
end

return XUiPanelNewbieActive

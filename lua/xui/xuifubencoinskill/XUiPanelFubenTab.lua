XUiPanelFubenTab = XClass()

function XUiPanelFubenTab:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelFubenTab:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelFubenTab:AutoInitUi()
    self.RImgFuben = self.Transform:Find("RImgFuben"):GetComponent("RawImage")
    self.PanelFubenTitle = self.Transform:Find("PanelFubenTitle")
    self.TxtFubenName = self.Transform:Find("PanelFubenTitle/TxtFubenName"):GetComponent("Text")
    self.PanelChallenge = self.Transform:Find("PanelChallenge")
    self.TxtChallenge = self.Transform:Find("PanelChallenge/TxtChallenge"):GetComponent("Text")
    self.TxtChallengeCount = self.Transform:Find("PanelChallenge/TxtChallengeCount"):GetComponent("Text")
    self.TxtReward = self.Transform:Find("TxtReward"):GetComponent("Text")
    self.BtnFuben = self.Transform:Find("BtnFuben"):GetComponent("Button")
    self.ImgRewardUp = self.Transform:Find("ImgRewardUp"):GetComponent("Image")
end

function XUiPanelFubenTab:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelFubenTab:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelFubenTab:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelFubenTab:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnFuben, self.OnBtnFubenClick)
end
-- auto

function XUiPanelFubenTab:OnBtnFubenClick(...)
    self.RootUi:OnFubenSelected(self.TypeId)
end

--初始化数据
function XUiPanelFubenTab:SetData(sectionData)
    self.TypeId = sectionData.Type
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(sectionData.StageId)
    self.RImgFuben:SetRawImage(stageCfg.Icon)
    self.TxtFubenName.text = stageCfg.Name .. (sectionData.Difficulty or "")
    self:UpdateData(sectionData)
end

--更新数据
function XUiPanelFubenTab:UpdateData(sectionData)
    self.TxtChallengeCount.text = CS.XTextManager.GetText("UiFubenCoinSkillChallenge", sectionData.ColorChallenge, sectionData.LeftCount)
    self.TxtReward.text = CS.XTextManager.GetText("UiFubenCoinSkillReward", sectionData.ColorReward, XDataCenter.FubenResourceManager.GetTopRewardByTypeId(self.TypeId))

    local value = XDataCenter.FubenResourceManager.CheckRewradChange(self.TypeId)
    self.ImgRewardUp.gameObject:SetActive(value)
end

return XUiPanelFubenTab

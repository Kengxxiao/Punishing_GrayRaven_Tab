XUiPanelChallengeTab = XClass()

function XUiPanelChallengeTab:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()

    self.BtnGroupList = {}
    table.insert(self.BtnGroupList, self.BtnChallengeTab)
    self.BtnGroup:Init(self.BtnGroupList, function() self:OnTabsClick(i) end)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelChallengeTab:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelChallengeTab:AutoInitUi()
    self.ScrollView = self.Transform:Find("ScrollView"):GetComponent("Scrollbar")
    self.BtnGroup = self.Transform:Find("ScrollView/Viewport/Content"):GetComponent("XUiButtonGroup")
    self.BtnChallengeTab = self.Transform:Find("ScrollView/Viewport/Content/BtnChallengeTab"):GetComponent("XUiButton")
end

function XUiPanelChallengeTab:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelChallengeTab:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelChallengeTab:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelChallengeTab:AutoAddListener()
end
-- auto

-- [策划需求只有一个tab]
function XUiPanelChallengeTab:UpdateTabs(coverDatas)
    self.Cover = coverDatas
    self.BtnChallengeTab:SetName(CS.XTextManager.GetText("PrequelChallangeTab"))
    self.BtnGroup:SelectIndex(1)
end

function XUiPanelChallengeTab:OnTabsClick()
    if not self.RootUi:IsChallengeAnimPlaying() then
        self.RootUi:PlayAnimation("AniChallengeModeSwitch")
    end
end

return XUiPanelChallengeTab

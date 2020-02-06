local XUiPanelGroupInfo = XClass()

function XUiPanelGroupInfo:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.GridBosList = {}
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self:Init()
end

function XUiPanelGroupInfo:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelGroupInfo:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelGroupInfo:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelGroupInfo:AutoAddListener()
    self:RegisterClickEvent(self.BtnBlock, self.OnBtnBlockClick)
    self:RegisterClickEvent(self.BtnTanchuangClose, self.OnBtnBlockClick)
end

function XUiPanelGroupInfo:Init()
    self.GridBoss.gameObject:SetActiveEx(false)
end

function XUiPanelGroupInfo:ShowBossGroupInfo(groupId)
    self.RootUi:PlayAnimation("GroupInfoEnable")
    local groupInfo = XFubenBossSingleConfigs.GetBossSingleGroupById(groupId)
    self.TxtGroupName.text = groupInfo.GroupName

    for _, grid in pairs(self.GridBosList) do
        grid.gameObject:SetActiveEx(false)
    end

    local now = XTime.GetServerNowTimestamp()
    for i = 1, #groupInfo.SectionId do
        local sectionCfg = XDataCenter.FubenBossSingleManager.GetBossSectionCfg(groupInfo.SectionId[i])
        -- 判断关闭时间
        local closeTime = XTime.ParseToTimestamp(sectionCfg.ClosedTime)
        if not closeTime or now < closeTime then
            local grid = self.GridBosList[i]
            if not grid then
                grid = CS.UnityEngine.Object.Instantiate(self.GridBoss)
                grid.transform:SetParent(self.PanelScoreContent, false)
                self.GridBosList[i] = grid
            end
            
            local headIcon = XUiHelper.TryGetComponent(grid.transform, "RImgBossIcon", "RawImage")
            local nickname = XUiHelper.TryGetComponent(grid.transform, "TxtBoosName", "Text")
            local sossStageCfg = XDataCenter.FubenBossSingleManager.GetBossStageCfg(sectionCfg.StageId[1])
            headIcon:SetRawImage(sectionCfg.BossHeadIcon)
            nickname.text = sossStageCfg.BossName

            grid.gameObject:SetActiveEx(true)
        end
    end

    self.GameObject:SetActiveEx(true)
end

function XUiPanelGroupInfo:OnBtnBlockClick(...)
    self:HidePanel()
end

function XUiPanelGroupInfo:HidePanel()
    self.GameObject:SetActiveEx(false)
end

return XUiPanelGroupInfo
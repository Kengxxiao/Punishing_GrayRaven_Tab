local XUiPanelMyTeam = XClass()

local XUiGridArenaMyTeamMember = require("XUi/XUiArenaTeam/XUiArenaTeamCommon/XUiGridArenaMyTeamMember")

function XUiPanelMyTeam:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()

    self.RootUi = rootUi
    self.IsShow = false
    self.GameObject:SetActive(false)

    self.Member1 = XUiGridArenaMyTeamMember.New(self.GridMyTeamMember1, self.RootUi)
    self.Member2 = XUiGridArenaMyTeamMember.New(self.GridMyTeamMember2, self.RootUi)
    self.Member3 = XUiGridArenaMyTeamMember.New(self.GridMyTeamMember3, self.RootUi)

    self.MemberList = {}
    table.insert(self.MemberList, self.Member1)
    table.insert(self.MemberList, self.Member2)
    table.insert(self.MemberList, self.Member3)
end

function XUiPanelMyTeam:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelMyTeam:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelMyTeam:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelMyTeam:AutoAddListener()
    self:RegisterClickEvent(self.BtnLeaveTeam, self.OnBtnLeaveTeamClick)
    self:RegisterClickEvent(self.BtnJoinTeam, self.OnBtnJoinTeamClick)
    self:RegisterClickEvent(self.BtnCreateTeam, self.OnBtnCreateTeamClick)
end

function XUiPanelMyTeam:OnBtnLeaveTeamClick(eventData)
    XUiManager.DialogTip("", CS.XTextManager.GetText("ArenaTeamLeveTeamConfirm"), XUiManager.DialogType.Normal, nil, function()
        XDataCenter.ArenaManager.RequestLeaveTeam(function()
            if self.IsShow and not XTool.UObjIsNil(self.GameObject) then
                self:Refresh()
            end
        end)
    end)
end

function XUiPanelMyTeam:OnBtnJoinTeamClick(eventData)
    self.RootUi:JumpToHallPanel()
end

function XUiPanelMyTeam:OnBtnCreateTeamClick(eventData)
    XDataCenter.ArenaManager.RequestCreateTeam(function()
        if self.IsShow and not XTool.UObjIsNil(self.GameObject) then
            self:Refresh()
        end
    end)
end

function XUiPanelMyTeam:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    XEventManager.AddEventListener(XEventId.EVENT_ARENA_TEAM_CHANGE, self.Refresh, self)
    self:Refresh()
end

function XUiPanelMyTeam:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
    XEventManager.RemoveEventListener(XEventId.EVENT_ARENA_TEAM_CHANGE, self.Refresh, self)
end

function XUiPanelMyTeam:Refresh()
    if not self.GameObject:Exist() then
        return
    end

    local teamId = XDataCenter.ArenaManager.GetTeamId()
    -- 没有队伍
    if teamId == 0 then
        self.PanelInTeam.gameObject:SetActive(false)
        self.PanelOutTeam.gameObject:SetActive(true)
        return
    end

    -- 有队伍
    self.PanelInTeam.gameObject:SetActive(true)
    self.PanelOutTeam.gameObject:SetActive(false)

    -- 刷新队伍成员信息
    local teamMembers = XDataCenter.ArenaManager.GetMyTeamMemberList()
    for i, member in ipairs(self.MemberList) do
        local info = teamMembers[i]
        member:Refresh(info)
    end
end

return XUiPanelMyTeam

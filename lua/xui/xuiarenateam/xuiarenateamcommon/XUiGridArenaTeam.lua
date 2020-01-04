local XUiGridArenaTeam = XClass()

local XUiGridArenaTeamMember = require("XUi/XUiArenaTeam/XUiArenaTeamCommon/XUiGridArenaTeamMember")

function XUiGridArenaTeam:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()

    self.Member1 = XUiGridArenaTeamMember.New(self.GridTeamMember1)
    self.Member2 = XUiGridArenaTeamMember.New(self.GridTeamMember2)
    self.Member3 = XUiGridArenaTeamMember.New(self.GridTeamMember3)

    self.MemberList = {}
    table.insert(self.MemberList, self.Member1)
    table.insert(self.MemberList, self.Member2)
    table.insert(self.MemberList, self.Member3)
end

function XUiGridArenaTeam:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaTeam:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaTeam:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridArenaTeam:AutoAddListener()
    self:RegisterClickEvent(self.BtnJoinTeam, self.OnBtnJoinTeamClick)
end

function XUiGridArenaTeam:OnBtnJoinTeamClick(eventData)
    if not self.Data then
        return
    end

    if self.Data.Apply == 1 then
        return
    end

    local teamId = XDataCenter.ArenaManager.GetTeamId()
    if teamId > 0 then
        XUiManager.TipError(CS.XTextManager.GetText("ArenaTeamAlreadyHaveTeam"))
        return
    end

    XDataCenter.ArenaManager.RequestApplyTeam(self.Data.Info.TeamId, function()
        self:Refresh()
    end)
end

function XUiGridArenaTeam:ResetData(data, rootUi)
    self.RootUi = rootUi
    self.Data = data
    self:Refresh()
end

function XUiGridArenaTeam:Refresh()
    if not self.Data then
        return
    end

    local isApplied = self.Data.Apply == 1
    self.BtnJoinTeam.interactable = not isApplied
    self.TxtIsApplied.gameObject:SetActive(isApplied)
    self.TxtJoin.gameObject:SetActive(not isApplied)

    for i, member in ipairs(self.MemberList) do
        local info = self.Data.Info.ShowList[i]
        member:SetData(info, self.Data.Info.Captain, self.RootUi)
    end
end

return XUiGridArenaTeam

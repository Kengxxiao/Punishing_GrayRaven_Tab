local XUiGuildMain = XLuaUiManager.Register(XLuaUi, "UiGuildMain")
local GuildManager

local XUiGuildViewInformation = require("XUi/XUiGuild/XUiChildView/XUiGuildViewInformation")
local XUiGuildViewMember = require("XUi/XUiGuild/XUiChildView/XUiGuildViewMember")
local XUiGuildViewChallenge = require("XUi/XUiGuild/XUiChildView/XUiGuildViewChallenge")
local XUiGuildViewWelfare = require("XUi/XUiGuild/XUiChildView/XUiGuildViewWelfare")

function XUiGuildMain:OnAwake()
    GuildManager = XDataCenter.GuildManager
    self:InitChildView()
end

function XUiGuildMain:OnStart(defaultIndex)
    self.BtnTapGroup:SelectIndex(defaultIndex or GuildManager.GuildFunctional.Info)
end

function XUiGuildMain:OnEnable()

end

function XUiGuildMain:OnDisable()

end

function XUiGuildMain:OnDestroy()

end

function XUiGuildMain:OnGetEvents()
    return {  }
end

function XUiGuildMain:OnNotify(evt, ...)
    
end

-- custom method

function XUiGuildMain:InitChildView()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnHelp.CallBack = function() self:OnBtnHelpClick() end

    self.btnTabs = {}
    self.btnTabs[GuildManager.GuildFunctional.Info] = self.BtnTabInformation
    self.btnTabs[GuildManager.GuildFunctional.Member] = self.BtnTabMember
    self.btnTabs[GuildManager.GuildFunctional.Challenge] = self.BtnTabChallenge
    self.btnTabs[GuildManager.GuildFunctional.Welfare] = self.BtnTabGift
    self.BtnTapGroup:Init(self.btnTabs, function(index) self:OnBtnTabListClick(index) end)

    self.tabViews = {}
    self.tabViews[GuildManager.GuildFunctional.Info] = XUiGuildViewInformation.New(self.PanelInformation, self)
    self.tabViews[GuildManager.GuildFunctional.Member] = XUiGuildViewMember.New(self.PanelMemberInfo, self)
    self.tabViews[GuildManager.GuildFunctional.Challenge] = XUiGuildViewChallenge.New(self.PanelChallengeList, self)
    self.tabViews[GuildManager.GuildFunctional.Welfare] = XUiGuildViewWelfare.New(self.PanelWelfareList, self)
end

function XUiGuildMain:OnBtnBackClick()
    self:Close()
end

function XUiGuildMain:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiGuildMain:OnBtnHelpClick()

end

function XUiGuildMain:OnBtnTabListClick(index)
    if self.LastSelect and self.tabViews[self.LastSelect] then
        self.tabViews[self.LastSelect]:OnDisable()
    end
    self.tabViews[index]:OnEnable()
    self.LastSelect = index
end



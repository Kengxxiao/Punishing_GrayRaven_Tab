local XUiArena = XLuaUiManager.Register(XLuaUi, "UiArena")

local XUiPanelActive = require("XUi/XUiArena/XUiPanelActive")
local XUiPanelPrepare = require("XUi/XUiArena/XUiPanelPrepare")

function XUiArena:OnAwake()
    self:AutoAddListener()
end

function XUiArena:OnStart(...)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.ActivePanel = XUiPanelActive.New(self.PanelActive, self)
    self.PreparePanel = XUiPanelPrepare.New(self.PanelPrepare, self)
end

function XUiArena:OnEnable()
    self:Refresh()

    -- 刷新任务红点
    if self.ActivePanel then
        self.ActivePanel:CheckRedPoint()
    end
end

function XUiArena:OnDestroy()
    self.ActivePanel:UnBindTimer()
end

function XUiArena:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
end

function XUiArena:OnBtnBackClick(eventData)
    self:Close()
end

function XUiArena:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiArena:OnBtnHelpClick(eventData)
    XUiManager.ShowHelpTip("Arena")
end

function XUiArena:Refresh()
    if not self.GameObject:Exist() then
        return
    end

    local status = XDataCenter.ArenaManager.GetArenaActivityStatus()
    if status == XArenaActivityStatus.Fight then
        self.ActivePanel:Show()
        self.PreparePanel:Hide()
    else
        self.PreparePanel:Show()
        self.ActivePanel:Hide()
    end
end
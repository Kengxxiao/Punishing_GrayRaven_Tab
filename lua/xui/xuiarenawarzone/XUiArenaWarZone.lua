local XUiArenaWarZone = XLuaUiManager.Register(XLuaUi, "UiArenaWarZone")

local XUiGridZone = require("XUi/XUiArenaWarZone/ArenaWarZoneCommon/XUiGridZone")

function XUiArenaWarZone:OnAwake()
    self:AutoAddListener()
end


function XUiArenaWarZone:OnStart(...)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.GridList = {}
    for i = 1, 5 do
        local trans = self["GridZone" .. i]
        local grid = XUiGridZone.New(trans, self)
        table.insert(self.GridList, grid)
    end
end


function XUiArenaWarZone:OnEnable()
    XDataCenter.ArenaManager.RequestAreaData()
    self:Refresh()
end

function XUiArenaWarZone:OnGetEvents()
    return { XEventId.EVENT_ARENA_REFRESH_AREA_INFO, XEventId.EVENT_ARENA_UNLOCK_AREA }
end

function XUiArenaWarZone:OnNotify(evt,...)
    if evt == XEventId.EVENT_ARENA_REFRESH_AREA_INFO then
        self:Refresh()
    elseif evt == XEventId.EVENT_ARENA_UNLOCK_AREA then
        self:RefreshUnlockCount()
    end
end

function XUiArenaWarZone:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self.BtnHelpCourse.CallBack = function()
        self:OnBtnHelpCourseClick()
    end
end

function XUiArenaWarZone:OnBtnBackClick(eventData)
    self:Close()
end

function XUiArenaWarZone:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiArenaWarZone:OnBtnHelpCourseClick(...)
    XUiManager.ShowHelpTip("Arena")
end

function XUiArenaWarZone:Refresh()
    local point = XDataCenter.ArenaManager.GetArenaAreaTotalPoint()
    self.TxtTotalPoint.text = point
    self:RefreshUnlockCount()

    local challengeCfg = XDataCenter.ArenaManager.GetCurChallengeCfg()
    for i, grid in ipairs(self.GridList) do
        grid:SetMetaData(challengeCfg.AreaId[i])
    end
end

function XUiArenaWarZone:RefreshUnlockCount()
    local remainCount = XDataCenter.ArenaManager.GetUnlockArenaAreaCount()
    self.TxtRemainUnlockTime.text = remainCount
end
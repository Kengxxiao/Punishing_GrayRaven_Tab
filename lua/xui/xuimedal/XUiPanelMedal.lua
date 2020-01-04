local XUiPanelMedal = XLuaUiManager.Register(XLuaUi, "UiPanelMedal")
-----------------------------Public------------------------------------
-----------------------------------------------------------------------
local TextManager = CS.XTextManager
local UiButtonState = CS.UiButtonState

local AnimListEnable = "MedalListEnable"
local AnimDetailEnable = "MdealDetailsEnable"


function XUiPanelMedal:OnStart(base,playerMedal)
    self.Base = base
    
    if playerMedal then 
        self.SkipMedalId = playerMedal.SkipMedalId
        self.DetailInfos = playerMedal.DetailInfos
        self.InType = playerMedal.InType
    else
        self.DetailInfos = XPlayer.UnlockedMedalInfos
        self.InType = XDataCenter.MedalManager.InType.Normal
    end
    
    self.MedalPrefab = self.GridMedal.gameObject
    self.CurrMedalId = {}
    self.Base.MedalDetailClose = function() 
        self:OpenMedalDetail(false)
        end
    self.BtnWear.CallBack = function() 
        self:OnBtnWear()
    end
    self.BtnUnload.CallBack = function() 
        self:OnBtnUnload()
    end
    XEventManager.AddEventListener(XEventId.EVENT_MEDAL_NOTIFY, self.ShowPanelMdeal, self)
    
end

function XUiPanelMedal:OnEnable()
    
    self:InitDynamicTable()
    self:ShowPanelMdeal()
    if self.SkipMedalId then
        self:GoSkipDetail()
    else
        self:OpenMedalDetail(false)
        if not XDataCenter.MedalManager.CheakMedalStoryIsPlayed() then
            CS.Movie.XMovieManager.Instance:PlayById(XDataCenter.MedalManager.MedalStroyId)
            XDataCenter.MedalManager.MarkMedalStory()
        end
    end
end

function XUiPanelMedal:GoSkipDetail()
    self:OpenMedalDetail(true)
    self:SetDetail(self.SkipMedalId)
    self.SkipMedalId = nil
end

function XUiPanelMedal:OpenMedalDetail(IsOpen)
    self.PanelMedalList.gameObject:SetActiveEx(not IsOpen)
    self.PanelMdealDetails.gameObject:SetActiveEx(IsOpen)
    self.Base.TabBtnGroup.gameObject:SetActiveEx(not IsOpen)
    self.Base.IsMedalDetailOpen = IsOpen

    local medalAnimation = IsOpen and AnimDetailEnable or AnimListEnable
    self:PlayAnimation(medalAnimation)
end

function XUiPanelMedal:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_MEDAL_NOTIFY, self.ShowPanelMdeal, self)
end

---------------------------MeadalWall----------------------------------
-----------------------------------------------------------------------
function XUiPanelMedal:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelMedalScroll)
    self.DynamicTable:SetProxy(XUiGridMedal)
    self.DynamicTable:SetDelegate(self)
    self.GridMedal.gameObject:SetActiveEx(false)
end

function XUiPanelMedal:SetupDynamicTable(index)
    self.PageDatas = XDataCenter.MedalManager.GetMedals()
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(index and index or 1)
end

function XUiPanelMedal:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateGrid(self.PageDatas[index],self)
        self:SetMedalRedPoint(grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then 
    end
end

function XUiPanelMedal:SetMedalCount()
    local maxCount = 0
    local nowCount = 0
    local medalsList = XDataCenter.MedalManager.GetMedals()
    for k,v in pairs(medalsList or {}) do
        maxCount = maxCount + 1
        if XPlayer.IsMedalUnlock(v.Id) then
            nowCount = nowCount + 1
        end
    end
    self.TxtAchvGetCount.text = nowCount.." / "..maxCount
end

function XUiPanelMedal:SetMedalRedPoint(grid)
    grid:ShowRedPoint(XDataCenter.MedalManager.CheakIsNewMedalById(grid.MedalId))
end

function XUiPanelMedal:ShowPanelMdeal()
    self:SetupDynamicTable()
    self:SetMedalCount()
end

---------------------------MeadalDetail----------------------------------
-------------------------------------------------------------------------
function XUiPanelMedal:SetDetail(selectMedalId)
    local detailInfo = nil
    local detailData = XMedalConfigs.GetMeadalConfigById(selectMedalId)
    local IsLock = true
    self.SelectMedalId = selectMedalId
    
    for k,v in pairs(self.DetailInfos) do
        if v.Id == selectMedalId then
            detailInfo = v
        end
    end
    
    if detailInfo then
        IsLock = false
    end
    
    if self.InType ~= XDataCenter.MedalManager.InType.OtherPlayer then
        XDataCenter.MedalManager.SetMedalForOld(self.SelectMedalId)
    end
    
    self:SetDetailInfo(detailInfo)
    self:SetDetailData(detailData)
    self:ShowLock(IsLock)
end

function XUiPanelMedal:ShowLock(IsLock)
    self.ImgLock.gameObject:SetActiveEx(IsLock)
    self.ImgConditionUnlock.gameObject:SetActiveEx(not IsLock)
    self.DisableHavent.gameObject:SetActiveEx(IsLock)
    self.DisableUsed.gameObject:SetActiveEx(not IsLock)
    self.PanelUnlock.gameObject:SetActiveEx(not IsLock)
    self.BtnWear.gameObject:SetActiveEx(true)
    self.BtnUnload.gameObject:SetActiveEx(false)
    
    if self.InType ~= XDataCenter.MedalManager.InType.OtherPlayer then
        if IsLock then
            self.BtnWear:SetButtonState(UiButtonState.Disable)
        else
            if XPlayer.CurrMedalId == self.SelectMedalId then
                self.BtnWear.gameObject:SetActiveEx(false)
                self.BtnUnload.gameObject:SetActiveEx(true)  
            end
            self.BtnWear:SetButtonState(UiButtonState.Normal)
        end
    else
        self.BtnWear.gameObject:SetActiveEx(false)
    end
    
end

function XUiPanelMedal:SetDetailInfo(detailInfo)
    if detailInfo then
        --self.TxtUnlock.text = TextManager.GetText("MedalNumber",detailInfo.Num)
        self.TxtUnlock.gameObject:SetActiveEx(false)
        self.TxtUnlockTime.text = TextManager.GetText("DayOfGetMedal",CS.XDate.FormatTime(detailInfo.Time))
    end
end

function XUiPanelMedal:SetDetailData(detailData)
    if detailData then
        self.TxtMedalName.text = detailData.Name
        self.TxtMedaDetails.text = detailData.Desc
        self.TxtCondition.text = detailData.UnlockDesc
        if detailData.MedalImg ~= nil then
            self.RawImage:SetRawImage(detailData.MedalImg)
        end
    end
end

function XUiPanelMedal:OnBtnWear()
    if self.BtnWear.ButtonState == UiButtonState.Disable then
        return
    end
    XPlayer.ChangeMedal(self.SelectMedalId, function()
            self:ShowLock(false)
            self:ShowPanelMdeal()
        end)
end

function XUiPanelMedal:OnBtnUnload()
    XPlayer.ChangeMedal(0, function()
            self:ShowLock(false)
            self:ShowPanelMdeal()
        end)
end
local XUiPanelChapterBfrt = require("XUi/XUiFubenMainLineBanner/XUiPanelChapterBfrt")

local XUiFubenMainLineBanner = XLuaUiManager.Register(XLuaUi, "UiFubenMainLineBanner")

local TAB_BTN_INDEX = {
    MAINLINE = 1,
    DZ = 2,
    BFRT = 3,
}

function XUiFubenMainLineBanner:OnAwake()
    self:InitAutoScript()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelChapterList)
    self.DynamicTable:SetProxy(XUiGridMainLineBanner)
    self.DynamicTable:SetDelegate(self)
    self.GridMainLineBanner.gameObject:SetActive(false)
    self.ChapterDz = XUiPanelChapterDz.New(self.PanelChapterDz, self)
    self.ChapterBfrt = XUiPanelChapterBfrt.New(self.PanelChapterBfrt, self.ParentUi)
    self.IsShowDifficultPanel = false
    XEventManager.AddEventListener(XEventId.EVENT_NOTICE_SELECTCOVER_CHANGE, self.OnCoverChapterChanged, self)
    self:InitTabBtnGroup()
end

function XUiFubenMainLineBanner:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_NOTICE_SELECTCOVER_CHANGE, self.OnCoverChapterChanged)
end

function XUiFubenMainLineBanner:OnDisable()
    self:SaveScrollPos()
end

function XUiFubenMainLineBanner:OnEnable()
    self.CurDiff = XDataCenter.FubenMainLineManager.GetCurDifficult()
    self:Refresh(false)
    self:PlayAnimation("QIEHuan")
end

function XUiFubenMainLineBanner:OnStart(defaultTab)
    self.PanelTab:SelectIndex(defaultTab or TAB_BTN_INDEX.MAINLINE)
end

function XUiFubenMainLineBanner:Refresh(playAnimation)
    if self.CurrentSelect == TAB_BTN_INDEX.MAINLINE then
        self:RefreshMainLine(playAnimation)
    elseif self.CurrentSelect == TAB_BTN_INDEX.DZ then
        self:RefreshPrequel(playAnimation)
    elseif self.CurrentSelect == TAB_BTN_INDEX.BFRT then
        self:RefreshBfrt(playAnimation)
    end

    -- 难度toggle
    self:UpdateDifficultToggles()
end

function XUiFubenMainLineBanner:OnCoverChapterChanged(chooseInfo)
    if self.ChapterDz then
        self.ChapterDz:OnCoverChanged(chooseInfo)
    end
end

--动态列表事件
function XUiFubenMainLineBanner:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateChapterGrid(self.PageDatas[index], self.CurDiff)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:ClickChapterGrid(self.PageDatas[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        --自动滚动到上一次记录的地方
        if not XDataCenter.GuideManager.CheckIsInGuide() then
            self:AutoScroll()
        end
    end
end

--设置动态列表
function XUiFubenMainLineBanner:SetupDynamicTable(index)
    if not self.CurDiff then return end
    self.PageDatas = XDataCenter.FubenMainLineManager.GetChapterMainTemplates(self.CurDiff)
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(index)
end

--自动滚动到上一次记录的地方
function XUiFubenMainLineBanner:AutoScroll()
    local keyX = "DynamicTable_MainLineChapterPosX" .. tostring(XPlayer.Id)
    if CS.UnityEngine.PlayerPrefs.HasKey(keyX) then
        local PosX = CS.UnityEngine.PlayerPrefs.GetFloat(keyX)
        local rt = self.PanelChapterContent:GetComponent("RectTransform")
        rt:DOAnchorPosX(PosX, 0.5)
    end
end

function XUiFubenMainLineBanner:SaveScrollPos()
    local keyX = "DynamicTable_MainLineChapterPosX" .. tostring(XPlayer.Id)
    local rt = self.PanelChapterContent:GetComponent("RectTransform")
    CS.UnityEngine.PlayerPrefs.SetFloat(keyX, rt.anchoredPosition.x)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenMainLineBanner:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenMainLineBanner:AutoInitUi()
    self.PanelChapterList = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelChapterList")
    self.PanelChapterContent = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelChapterList/Viewport/PanelChapterContent")
    self.GridMainLineBanner = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelChapterList/Viewport/GridMainLineBanner")
    self.PanelChapterDz = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelChapterDz")
    self.BtnCloseDifficult = self.Transform:Find("FullScreenBackground/MainLineChapter3d/BtnCloseDifficult"):GetComponent("Button")
    self.PanelTopDifficult = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult")
    self.BtnNormal = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult/BtnNormal"):GetComponent("Button")
    self.PanelNormalOn = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult/BtnNormal/PanelNormalOn")
    self.PanelNormalOff = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult/BtnNormal/PanelNormalOff")
    self.BtnHard = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult/BtnHard"):GetComponent("Button")
    self.PanelHardOn = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult/BtnHard/PanelHardOn")
    self.PanelHardOff = self.Transform:Find("FullScreenBackground/MainLineChapter3d/PanelTopDifficult/BtnHard/PanelHardOff")
end

function XUiFubenMainLineBanner:AutoAddListener()
    self:RegisterClickEvent(self.BtnCloseDifficult, self.OnBtnCloseDifficultClick)
    self:RegisterClickEvent(self.BtnNormal, self.OnBtnNormalClick)
    self:RegisterClickEvent(self.BtnHard, self.OnBtnHardClick)
end
-- auto
function XUiFubenMainLineBanner:InitTabBtnGroup()
    local tabGroup = {
        self.BtnTabZX,
        self.BtnTabDZ,
        self.BtnTabJD,
    }
    self.BtnTabDZ:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Prequel))
    self.BtnTabJD:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenNightmare))
    self.PanelTab:Init(tabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)

end

function XUiFubenMainLineBanner:OnClickTabCallBack(tabIndex)
    if self.CurrentSelect and self.CurrentSelect == tabIndex then
        return
    end
    
    if tabIndex == TAB_BTN_INDEX.MAINLINE then
        self:RefreshMainLine(true)
    elseif tabIndex == TAB_BTN_INDEX.DZ then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Prequel) then
            return
        end
        self:RefreshPrequel(true)
    elseif tabIndex == TAB_BTN_INDEX.BFRT then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenNightmare) then
            return
        end
        self:RefreshBfrt(true)
    end
    self.CurrentSelect = tabIndex
end

-- 断章
function XUiFubenMainLineBanner:RefreshPrequel(playAnimation)
    self.PanelTopDifficult.gameObject:SetActive(false)
    self.PanelChapterList.gameObject:SetActive(false)
    self.PanelChapterBfrt.gameObject:SetActive(false)
    self.PanelChapterDz.gameObject:SetActive(true)
    self.ChapterDz:SetupCoverDatas(self.DefaultCoverId, self.DefaultChpaterId)
    if playAnimation and (not self.DefaultCoverId) then
        self:PlayAnimation("DzQieHuanEnable")
    end
    self.DefaultCoverId = nil
    self.DefaultChpaterId = nil
end

function XUiFubenMainLineBanner:RefreshBfrt(playAnimation)
    self.PanelTopDifficult.gameObject:SetActive(false)
    self.PanelChapterList.gameObject:SetActive(false)
    self.PanelChapterDz.gameObject:SetActive(false)
    self.PanelChapterBfrt.gameObject:SetActive(true)
    self.ChapterBfrt:SetupBfrtChpaters()
end

function XUiFubenMainLineBanner:RefreshMainLine(playAnimation)
    self.PanelTopDifficult.gameObject:SetActive(true)
    self.PanelChapterList.gameObject:SetActive(true)
    self.PanelChapterBfrt.gameObject:SetActive(false)
    self.PanelChapterDz.gameObject:SetActive(false)
    self:SetupDynamicTable()
    if playAnimation then
        self:PlayAnimation("ListQieHuanEnable")
    end
end

function XUiFubenMainLineBanner:OnBtnCloseDifficultClick(eventData)
    self:UpdateDifficultToggles()
end

function XUiFubenMainLineBanner:OnBtnNormalClick(eventData)
    if self.IsShowDifficultPanel then
        if self.CurDiff ~= XDataCenter.FubenManager.DifficultNormal then
            self.CurDiff = XDataCenter.FubenManager.DifficultNormal
            XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
            self:RefreshForChangeDiff()
        end
        self:UpdateDifficultToggles()
    else
        self:UpdateDifficultToggles(true)
    end
end

function XUiFubenMainLineBanner:OnBtnHardClick(eventData)
    if self.IsShowDifficultPanel then
        if self.CurDiff ~= XDataCenter.FubenManager.DifficultHard then
            -- 检查困难开启
            if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenDifficulty) then
                return
            end

            self.CurDiff = XDataCenter.FubenManager.DifficultHard
            XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
            self:RefreshForChangeDiff()
        end
        self:UpdateDifficultToggles()
    else
        self:UpdateDifficultToggles(true)
    end
end

-- 选中一个 chapter grid，需要设置层级、状态
function XUiFubenMainLineBanner:ClickChapterGrid(chapterMain)
    local chapter = XDataCenter.FubenMainLineManager.GetChapterCfgByChapterMain(chapterMain.Id, self.CurDiff)
    local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfoByChapterMain(chapterMain.Id, self.CurDiff)

    if chapterInfo.Unlock then
        self.ParentUi:PushUi(function()
            XLuaUiManager.Open("UiFubenMainLineChapter", chapter)
        end)
    elseif chapterInfo.IsActivity then
        local ret, desc = XDataCenter.FubenMainLineManager.CheckActivityCondition(chapterMain.Id)
        if not ret then
            XUiManager.TipError(desc)
        end
    else
        if self.CurDiff == XDataCenter.FubenManager.DifficultNightmare then
            XUiManager.TipMsg(CS.XTextManager.GetText("BfrtChapterUnlockCondition"))
        else
            self:ChapterLockTipMsg(chapterInfo)
        end
    end
end

function XUiFubenMainLineBanner:ChapterLockTipMsg(chapterInfo)
    local tipMsg = XDataCenter.FubenManager.GetFubenOpenTips(chapterInfo.FirstStage)
    XUiManager.TipMsg(tipMsg)
end

function XUiFubenMainLineBanner:UpdateDifficultToggles(showAll)
    if showAll then
        self:SetBtnTogleActive(true, true, true)
        self.BtnCloseDifficult.gameObject:SetActive(true)
    else
        if self.CurDiff == XDataCenter.FubenManager.DifficultNormal then
            self:SetBtnTogleActive(true, false, false)
            self.BtnNormal.transform:SetAsFirstSibling()
        elseif self.CurDiff == XDataCenter.FubenManager.DifficultHard then
            self:SetBtnTogleActive(false, true, false)
            self.BtnHard.transform:SetAsFirstSibling()
        else
            self:SetBtnTogleActive(false, false, true)
        end
        self.BtnCloseDifficult.gameObject:SetActive(false)
    end

    self.IsShowDifficultPanel = showAll
end

function XUiFubenMainLineBanner:SetBtnTogleActive(isNormal, isHard, isNightmare)
    self.BtnNormal.gameObject:SetActive(isNormal)

    self.BtnHard.gameObject:SetActive(isHard)
    if isHard then
        local hardOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenDifficulty)
        self.PanelHardOn.gameObject:SetActive(hardOpen)
        self.PanelHardOff.gameObject:SetActive(not hardOpen)
    end
end

function XUiFubenMainLineBanner:RefreshForChangeDiff()
    self:PlayAnimation("ListQieHuanEnable")
    self:Refresh(true)
end

function XUiFubenMainLineBanner:OnGetEvents()
    return { XEventId.EVENT_FUBEN_PREQUEL_AUTOSELECT, XEventId.EVENT_FUBEN_MAINLINE_TAB_SELECT, XEventId.EVENT_FUBEN_MAINLINE_DIFFICUTY_SELECT }
end

function XUiFubenMainLineBanner:OnNotify(evt, ...)
    local args = { ... }
    
    if evt == XEventId.EVENT_FUBEN_PREQUEL_AUTOSELECT then
        self.DefaultCoverId = args[1]
        self.DefaultChpaterId = args[2]
        self.PanelTab:SelectIndex(TAB_BTN_INDEX.DZ)

    elseif evt == XEventId.EVENT_FUBEN_MAINLINE_TAB_SELECT then
        self.PanelTab:SelectIndex(args[1])

    elseif evt == XEventId.EVENT_FUBEN_MAINLINE_DIFFICUTY_SELECT then
        self.CurrentSelect = nil
        self.CurDiff = XDataCenter.FubenManager.DifficultHard
        XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
        self.PanelTab:SelectIndex(TAB_BTN_INDEX.MAINLINE)
        self:UpdateDifficultToggles()
    end
end
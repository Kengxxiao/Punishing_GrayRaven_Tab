XUiGridTreasureGrade = XClass()

function XUiGridTreasureGrade:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.GridCommonItem = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent/GridCommon")
    self.GridCommonItem.gameObject:SetActive(false)
    self.GridList = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTreasureGrade:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridTreasureGrade:AutoInitUi()
    self.ImgGradeLine = self.Transform:Find("ImgGradeLine"):GetComponent("Image")
    self.TxtGrade = self.Transform:Find("TxtGrade"):GetComponent("Text")
    self.TxtGradeStarNums = self.Transform:Find("TxtGradeStarNums"):GetComponent("Text")
    self.ImgGradeStarActive = self.Transform:Find("ImgGradeStarActive"):GetComponent("Image")
    self.ImgGradeStarUnactive = self.Transform:Find("ImgGradeStarUnactive"):GetComponent("Image")
    self.BtnReceive = self.Transform:Find("BtnReceive"):GetComponent("Button")
    self.ImgCannotReceive = self.Transform:Find("ImgCannotReceive"):GetComponent("Image")
    self.ImgAlreadyReceived = self.Transform:Find("ImgAlreadyReceived"):GetComponent("Image")
    self.PanelTreasureList = self.Transform:Find("PanelTreasureList")
    self.PanelTreasureContent = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent")
    self.GridCommon = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent/GridCommon")
    self.RImgIcon = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent/GridCommon/RImgIcon"):GetComponent("RawImage")
    self.ImgQuality = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent/GridCommon/ImgQuality"):GetComponent("Image")
    self.BtnClick = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent/GridCommon/BtnClick"):GetComponent("Button")
    self.TxtCount = self.Transform:Find("PanelTreasureList/Viewport/PanelTreasureContent/GridCommon/TxtCount"):GetComponent("Text")
end

function XUiGridTreasureGrade:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridTreasureGrade:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridTreasureGrade:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridTreasureGrade:AutoAddListener()
    self:RegisterClickEvent(self.BtnReceive, self.OnBtnReceiveClick)
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto

function XUiGridTreasureGrade:OnBtnClickClick(eventData)

end

function XUiGridTreasureGrade:OnBtnReceiveClick(...)
    if self.CurStars < self.TreasureCfg.RequireStar then
        return
    end

    local _this = self
    XDataCenter.FubenMainLineManager.ReceiveTreasureReward(function (reward)
        XUiManager.OpenUiObtain(reward, CS.XTextManager.GetText("Award"))
        _this:Refresh()
    end, self.TreasureCfg.TreasureId)
end

function XUiGridTreasureGrade:UpdateGradeGrid(curStars, treasureCfg, chapterId)
    self.CurStars = curStars
    self.TreasureCfg = treasureCfg
    self.ChapterId = chapterId
    self:Refresh()
end

function XUiGridTreasureGrade:Refresh()
    local requireStars = self.TreasureCfg.RequireStar
    local curStars = self.CurStars > requireStars and requireStars or self.CurStars
    self.TxtGradeStarNums.text = CS.XTextManager.GetText("GradeStarNum", curStars, requireStars) 
    if requireStars > 0 and self.CurStars >= requireStars then
        self:SetStarsActive(true)
        local isGet = XDataCenter.FubenMainLineManager.IsTreasureGet(self.TreasureCfg.TreasureId, self.ChapterId)
        if isGet then
            self:SetBtnAlreadyReceive()
        else
            self:SetBtnActive()
        end
    else
        self:SetStarsActive(false)
        self:SetBtnCannotReceive()
    end
end

function XUiGridTreasureGrade:SetBtnActive()
    self.BtnReceive.gameObject:SetActive(true)
    self.ImgAlreadyReceived.gameObject:SetActive(false)
    self.ImgCannotReceive.gameObject:SetActive(false)
end

function XUiGridTreasureGrade:SetBtnCannotReceive()
    self.BtnReceive.gameObject:SetActive(false)
    self.ImgAlreadyReceived.gameObject:SetActive(false)
    self.ImgCannotReceive.gameObject:SetActive(true)
end

function XUiGridTreasureGrade:SetBtnAlreadyReceive()
    self.BtnReceive.gameObject:SetActive(false)
    self.ImgAlreadyReceived.gameObject:SetActive(true)
    self.ImgCannotReceive.gameObject:SetActive(false)
end

function XUiGridTreasureGrade:SetStarsActive(flag)
    self.ImgGradeStarActive.gameObject:SetActive(flag)
    self.ImgGradeStarUnactive.gameObject:SetActive(not flag)
end

-- 初始化 treasure grid panel，填充数据
function XUiGridTreasureGrade:InitTreasureList()
    if self.TreasureCfg == nil or self.TreasureCfg.RewardId == 0 then
        XLog.Error("treasure have no RewardId ")
        return
    end

    local rewards = XRewardManager.GetRewardList(self.TreasureCfg.RewardId)
    for i, item in ipairs(rewards) do
        local grid
        if self.GridList[i] then
            grid = self.GridList[i]
        else
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCommonItem)
            grid = XUiGridCommon.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelTreasureContent, false)
            self.GridList[i] = grid
        end
        grid:Refresh(item)
        grid.GameObject:SetActive(true)
        i = i + 1
    end

    for j = 1, #self.GridList do
        if j > #rewards then
            self.GridList[j].GameObject:SetActive(false)
        end
    end
end

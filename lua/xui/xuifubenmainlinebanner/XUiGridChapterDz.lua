XUiGridChapterDz = XClass()

function XUiGridChapterDz:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiGridChapterDz:InitRoot(rootUi)
    self.RootUi = rootUi
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridChapterDz:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridChapterDz:AutoInitUi()
    self.RImgDz = self.Transform:Find("RImgDz"):GetComponent("RawImage")
    self.TxtProgress = self.Transform:Find("TxtProgress"):GetComponent("Text")
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.Txt3 = self.Transform:Find("Txt3"):GetComponent("Text")
    self.Txt4 = self.Transform:Find("Txt4"):GetComponent("Text")
    self.ImgActivityTab = self.Transform:Find("ImgActivityTab"):GetComponent("Image")
    self.BtnUnlockCover = self.Transform:Find("BtnUnlockCover"):GetComponent("Button")
    self.TxtUnlockCondition = self.Transform:Find("BtnUnlockCover/TxtUnlockCondition"):GetComponent("Text")
end

function XUiGridChapterDz:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridChapterDz:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridChapterDz:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridChapterDz:AutoAddListener()
    self:RegisterClickEvent(self.BtnUnlockCover, self.OnBtnUnlockCoverClick)
end
-- auto

function XUiGridChapterDz:OnBtnUnlockCoverClick(eventData)
    if self.CoverInfo then
        XUiManager.TipMsg(XDataCenter.PrequelManager.GetChapterUnlockDescription(self.CoverInfo.ShowChapter))
    end
end

function XUiGridChapterDz:RefreshDatas(coverDatas)
    self.CoverInfo = coverDatas
    local coverInfo = XPrequelConfigs.GetPrequelCoverInfoById(coverDatas.CoverId)
    
    local showChapterInfo = XPrequelConfigs.GetPrequelChapterById(coverDatas.ShowChapter)
    self.TxtName.text = showChapterInfo.ChapterName
    -- self.RootUi:SetUiSprite(self.ImgDz, coverInfo.CoverBg)
    self.RImgDz:SetRawImage(showChapterInfo.Bg)

    local finishedNum, totalNum = XDataCenter.PrequelManager.GetChapterProgress(coverDatas.ShowChapter)
    self.TxtProgress.text = CS.XTextManager.GetText("PrequelCompletion", finishedNum, totalNum)
    
    self.ImgActivityTab.gameObject:SetActive(false)
    -- 全部未解锁，优先级低于活动
    local unlockDescription = XDataCenter.PrequelManager.GetChapterUnlockDescription(coverDatas.ShowChapter)
    self.BtnUnlockCover.gameObject:SetActive(unlockDescription ~= nil)
    self.TxtUnlockCondition.text = unlockDescription
    -- 有活动
    if coverDatas.IsActivity or coverDatas.IsActivityNotOpen then
        self.ImgActivityTab.gameObject:SetActive(true)
        if coverDatas.IsActivityNotOpen then
            self.TxtUnlockCondition.text = unlockDescription
        end
    end
end

return XUiGridChapterDz

local XUiFubenExploreChapter = XLuaUiManager.Register(XLuaUi, "UiFubenExploreChapter")
function XUiFubenExploreChapter:OnAwake()
    self.CurChapterId = 0
    self.GridRecordList = {}
    self.ChapterTabBtnList = {}
    self:AddListener()
    self:InitTabBtn()
    self.TabBtnGroup:SelectIndex(XDataCenter.FubenExploreManager.GetNewestChapterId())
end

function XUiFubenExploreChapter:OnStart()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset,
    XDataCenter.ItemManager.ItemId.FreeGem,
    XDataCenter.ItemManager.ItemId.ActionPoint,
    XDataCenter.ItemManager.ItemId.Coin)
end

function XUiFubenExploreChapter:OnEnable()
    self:InitTabBtn()
    local chapterId = XDataCenter.FubenExploreManager.GetNewestChapterId()
    if chapterId ~= nil then
        self.TabBtnGroup:SelectIndex(chapterId)
    else
        self.TabBtnGroup:SelectIndex(1)
    end
end

function XUiFubenExploreChapter:UpdateInfo()
    self.TxtTitle.text = self.CurChapterData.Name
    local progress = XDataCenter.FubenExploreManager.GetExploreProgress(self.CurChapterId)
    local progressInt = math.floor(progress * 100)
    self.TxtExplorNumber.text = string.format("%d%%", progressInt)
    self.ImgProgress.fillAmount = 0
    --CS.DG.Tweening.DOTween.To(self.ImgProgress.fillAmount,self.ImgProgress.fillAmount,progress, 0.5)
    self.ImgProgress:DOFillAmount(progress, 0.5)
    --self.ImgProgress.fillAmount = progress
    self.RImgBigBg:SetRawImage(self.CurChapterData.BgPic)
    self:UpdateRecord()
end

function XUiFubenExploreChapter:UpdateRecord()
    local allRecordData = XDataCenter.FubenExploreManager.GetChapterStoryText(self.CurChapterId)
    for i = 1, #allRecordData do
        if self.GridRecordList[i] == nil then
            local tempGridRecord = CS.UnityEngine.Object.Instantiate(self.GridRecord)
            tempGridRecord.transform:SetParent(self.PanelContent, false)
            tempGridRecord.gameObject:SetActive(true)

            table.insert(self.GridRecordList, tempGridRecord)
        else
            self.GridRecordList[i].gameObject:SetActive(true)
        end
        --setdata
        local uiObj = self.GridRecordList[i]:GetComponent(typeof(CS.UiObject))
        uiObj:GetObject("TxtSubtitle").text = allRecordData[i].Title
        uiObj:GetObject("TxtContent").text = allRecordData[i].Text
    end

    if #XFubenExploreConfigs.GetChapterStoryText(self.CurChapterId) ~= #allRecordData then
        self.GridExploring.gameObject.transform:SetAsLastSibling()
        self.GridExploring.gameObject:SetActive(true)
    else
        self.GridExploring.gameObject:SetActive(false)
    end

    for i = #allRecordData + 1, #self.GridRecordList do
        self.GridRecordList[i].gameObject:SetActive(false)
    end
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelContent)
end

function XUiFubenExploreChapter:InitTabBtn()
    local allChapterData = XFubenExploreConfigs.GetExploreChapterCfg()
    for i = 1, #allChapterData do
        if self.ChapterTabBtnList[i] == nil then
            local tempChapterTabBtn = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("BtnExploreChapter"))
            tempChapterTabBtn.transform:SetParent(self.ChapterTabGroup, false)
            table.insert(self.ChapterTabBtnList, tempChapterTabBtn)
        end
    end
    self.TabBtnGroup = XUiTabBtnGroup.New(self.ChapterTabBtnList,
    function(index) self:OnBtnChapterClick(index) end,
    function(tabId) return self:TabBtnClickCheck(tabId) end,
    nil,
    XUiTabBtnGroup.TabBtnType.Chapter)
    for i = 1, #allChapterData do
        --setdata
        self.TabBtnGroup.TabBtnList[i]:SetName(allChapterData[i].Name, CS.XTextManager.GetText("ExploreChapterName", i))
        self.TabBtnGroup.TabBtnList[i]:SetPic(allChapterData[i].Icon)
        self.TabBtnGroup.TabBtnList[i]:SetRedPoint(XDataCenter.FubenExploreManager.IsChapterRedPoint(allChapterData[i].Id))
        if i ~= 1 and allChapterData[i].PreId > 0 and XDataCenter.FubenExploreManager.GetExploreProgress(allChapterData[i].PreId) ~= 1 then
            self.TabBtnGroup:LockIndex(i)
        else
            self.TabBtnGroup:UnLockIndex(i)
        end
    end
end

function XUiFubenExploreChapter:TabBtnClickCheck(index)
    local result = false
    local allChapterData = XFubenExploreConfigs.GetExploreChapterCfg()
    if index ~= 1 and XDataCenter.FubenExploreManager.GetExploreProgress(allChapterData[index - 1].Id) ~= 1 then
        result = false
        XUiManager.TipError(CS.XTextManager.GetText("ExploreNotOpenError"))
    else
        result = true
    end
    return result
end

function XUiFubenExploreChapter:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
    self.BtnHelpCourse.CallBack = function()
        self:OnBtnHelpCourseClick()
    end
end

function XUiFubenExploreChapter:OnBtnHelpClick(...)
    XUiManager.UiFubenDialogTip("", CS.XTextManager.GetText("ExploreExplain") or "")
end

function XUiFubenExploreChapter:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFubenExploreChapter:OnBtnBackClick(...)
    self:Close()
end

function XUiFubenExploreChapter:OnBtnEnterClick(...)
    XLuaUiManager.Open("UiFubenExploreLevel", self.CurChapterId)
end

function XUiFubenExploreChapter:OnBtnHelpCourseClick(...)
    XUiManager.ShowHelpTip("Explore")
end


function XUiFubenExploreChapter:OnBtnChapterClick(chapterId)
    self:PlayAnimation("AnimQieHuan")
    self.CurChapterId = chapterId
    XDataCenter.FubenExploreManager.SetCurChapterId(self.CurChapterId)
    self.CurChapterData = XFubenExploreConfigs.GetChapterData(self.CurChapterId)
    self:UpdateInfo()
end
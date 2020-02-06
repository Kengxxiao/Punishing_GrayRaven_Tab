local XUiFubenPractice = XLuaUiManager.Register(XLuaUi, "UiFubenPractice")

local ChildDetailUi = "UiPracticeSingleDetail"

function XUiFubenPractice:OnAwake()
    self:InitViews()
    self:AddBtnsListeners()

    XEventManager.AddEventListener(XEventId.EVENT_PRACTICE_ON_DATA_REFRESH, self.RefreshSelectPanel, self)
    self.CurrentSelect = XPracticeConfigs.PracticeMode.Basics
end

function XUiFubenPractice:AddBtnsListeners()
    self.BtnHelp.CallBack = function() XUiManager.ShowHelpTip("Practice") end
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnMaskDetail.CallBack = function() self:OnBtnMaskDetailClick() end
end

function XUiFubenPractice:InitViews()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    self.PracticeBasics = XUiPanelPracticeBasics.New(self, self.PanelBasics)
    self.PracticeAdvanced = XUiPanelPracticeAdvanced.New(self, self.PanelAdvanced)
    self.PracticeCharacter = XUiPanelPracticeCharacter.New(self, self.PanelCharacter)

    -- 初始化tabGroup
    self.BtnTabList = {}
    self.ChapterDetailList = XPracticeConfigs.GetPracticeChapterDetails()
    for id, chapterDetail in pairs(self.ChapterDetailList) do
        local chapter = XPracticeConfigs.GetPracticeChapterById(id)
        if not self.BtnTabList[id] then
            local tabGo = CS.UnityEngine.Object.Instantiate(self.BtnTabShortNew.gameObject)
            tabGo.transform:SetParent(self.UiContent, false)
            self.BtnTabList[id] = tabGo.transform:GetComponent("XUiButton")
        end
        self.BtnTabList[id].gameObject:SetActive(chapter.IsOpen == 1)
        self.BtnTabList[id]:SetNameByGroup(0, chapterDetail.Name)
    end
    self.BtnTabShortNew.gameObject:SetActive(false)

    self.BtnGroupList:Init(self.BtnTabList, function(index) self:SelectPanel(index) end)

end

function XUiFubenPractice:OnStart(tabType)
    self:CheckTabConditions()
    self:SetAssetPanelActive(true)
    self.BtnGroupList:SelectIndex(tabType or self:GetFirstOpen())
    self.AnimEnable:PlayTimelineAnimation()
end

function XUiFubenPractice:SetAssetPanelActive(isActive)
    self.AssetPanel.GameObject:SetActiveEx(isActive)
end

function XUiFubenPractice:GetFirstOpen()
    local chapterDetailList = XPracticeConfigs.GetPracticeChapterDetails()
    local default = XPracticeConfigs.PracticeMode.Basics
    for id, chapterDetail in ipairs(chapterDetailList) do
        local chapter = XPracticeConfigs.GetPracticeChapterById(id)
        if chapter.IsOpen == 1 then
            default = id
            break
        end
    end
    return default
end

function XUiFubenPractice:OnEnable()
end

function XUiFubenPractice:OnDisable()
    if not self.CurrentSelect then return end
    self:OnPracticeDetailClose()
end

function XUiFubenPractice:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_PRACTICE_ON_DATA_REFRESH, self.RefreshSelectPanel, self)
end

function XUiFubenPractice:OnBtnBackClick(...)
    self:Close()
end

function XUiFubenPractice:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFubenPractice:OnBtnMaskDetailClick(...)
    self:CloseStageDetail()
end

function XUiFubenPractice:CheckTabConditions()
    if not self.ChapterDetailList then return end
    for id, chapterDetail in pairs(self.ChapterDetailList) do
        local conditionId = XPracticeConfigs.GetPracticeChapterConditionById(id)
        self.BtnTabList[id]:SetButtonState(CS.UiButtonState.Normal)
        if conditionId ~= nil and conditionId > 0 then
            local ret, desc = XConditionManager.CheckCondition(conditionId)
            if not ret then
                self.BtnTabList[id]:SetButtonState(CS.UiButtonState.Disable)
            end
        end
    end
end

function XUiFubenPractice:SelectPanel(index)
    local chapterDetail = self.ChapterDetailList[index]
    if chapterDetail then
        local conditionId = XPracticeConfigs.GetPracticeChapterConditionById(chapterDetail.Id)
        if conditionId ~= nil and conditionId > 0 then
            local ret, desc = XConditionManager.CheckCondition(conditionId)
            if not ret then
                XUiManager.TipMsg(desc)
                return 
            end
        end
    end

    self:CloseStageDetail()
    self.CurrentSelect = index
    self.PracticeBasics:SetPanelActive(index == XPracticeConfigs.PracticeMode.Basics)
    self.PracticeAdvanced:SetPanelActive(index == XPracticeConfigs.PracticeMode.Advanced)
    self.PracticeCharacter:SetPanelActive(index == XPracticeConfigs.PracticeMode.Character)
end

function XUiFubenPractice:RefreshSelectPanel()
    if not self.CurrentSelect then return end
    if XPracticeConfigs.PracticeMode.Basics == self.CurrentSelect then
        self.PracticeBasics:ShowPanelDetail()

    elseif XPracticeConfigs.PracticeMode.Advanced == self.CurrentSelect then
        self.PracticeAdvanced:ShowPanelDetail()
    
    elseif XPracticeConfigs.PracticeMode.Character == self.CurrentSelect then
        self.PracticeCharacter:ShowPanelDetail()

    end
end

function XUiFubenPractice:OpenStageDetail(stageId)
    self:OpenOneChildUi(ChildDetailUi, self)
    self:FindChildUiObj(ChildDetailUi):Refresh(stageId)
    self:SetAssetPanelActive(false)
end

function XUiFubenPractice:CloseStageDetail()
    if XLuaUiManager.IsUiShow(ChildDetailUi) then
        self:FindChildUiObj(ChildDetailUi):CloseWithAnimation()
        self:OnPracticeDetailClose()
        self:SetAssetPanelActive(true)
    end
end

function XUiFubenPractice:OnPracticeDetailClose()
    if XPracticeConfigs.PracticeMode.Basics == self.CurrentSelect then
        self.PracticeBasics:OnPracticeDetailClose()

    elseif XPracticeConfigs.PracticeMode.Advanced == self.CurrentSelect then
        self.PracticeAdvanced:OnPracticeDetailClose()
    
    elseif XPracticeConfigs.PracticeMode.Character == self.CurrentSelect then
        self.PracticeCharacter:OnPracticeDetailClose()

    end
end

function XUiFubenPractice:SwitchBg(mode)
    local details = XPracticeConfigs.GetPracticeChapterDetailById(mode)
    if not details then return end
    self.RImgBg:SetRawImage(details.BgPath)
end
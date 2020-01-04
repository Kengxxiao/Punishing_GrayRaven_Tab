XUiPanelFavorabilityDocument = XClass()

local DocumentTypeSize = 4
local DocumentType = {
    DocFile = 1,
    DocInfo = 2,
    DocRumor = 3,
    DocAudo = 4,
}

function XUiPanelFavorabilityDocument:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    XTool.InitUiObject(self)
    self:InitUiAfterAuto()

    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    self.RedPointInfoId = XRedPointManager.AddRedPointEvent(self.ImgRedDotB, nil, self, { XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_INFO }, { CharacterId = characterId })
    self.RedPointRumorId = XRedPointManager.AddRedPointEvent(self.ImgRedDotC, nil, self, { XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_RUMOR }, { CharacterId = characterId })
    self.RedPointAudioId = XRedPointManager.AddRedPointEvent(self.ImgRedDotD, nil, self, { XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT_AUDIO }, { CharacterId = characterId })
end

-- [资料标签页trigger]
function XUiPanelFavorabilityDocument:CheckDataReddot()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    XRedPointManager.Check(self.RedPointInfoId, {CharacterId = characterId})
end

-- [异闻标签页trigger]
function XUiPanelFavorabilityDocument:CheckRumorReddot()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    XRedPointManager.Check(self.RedPointRumorId, {CharacterId = characterId})
end

-- [语音标签页trigger]
function XUiPanelFavorabilityDocument:CheckAudioReddot()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    XRedPointManager.Check(self.RedPointAudioId, {CharacterId = characterId})
end

function XUiPanelFavorabilityDocument:InitUiAfterAuto()
    self.FavorabilityFile = XUiPanelFavorabilityFile.New(self.PanelFavorabilityFile, self.UiRoot, self)
    self.FavorabilityInfo = XUiPanelFavorabilityInfo.New(self.PanelFavorabilityInfo, self.UiRoot, self)
    self.FavorabilityRumors = XUiPanelFavorabilityRumors.New(self.PanelFavorabilityRumors, self.UiRoot, self)
    self.FavorabilityAudio = XUiPanelFavorabilityAudio.New(self.PanelFavorabilityAudio, self.UiRoot, self)

    self.Tabs = {}
    self.Tabs[DocumentType.DocFile] = {}
    self.Tabs[DocumentType.DocFile].reddot = self.ImgRedDotA
    self.Tabs[DocumentType.DocFile].view = self.FavorabilityFile
    self.Tabs[DocumentType.DocInfo] = {}
    self.Tabs[DocumentType.DocInfo].reddot = self.ImgRedDotB
    self.Tabs[DocumentType.DocInfo].view = self.FavorabilityInfo
    self.Tabs[DocumentType.DocRumor] = {}
    self.Tabs[DocumentType.DocRumor].reddot = self.ImgRedDotC
    self.Tabs[DocumentType.DocRumor].view = self.FavorabilityRumors
    self.Tabs[DocumentType.DocAudo] = {}
    self.Tabs[DocumentType.DocAudo].reddot = self.ImgRedDotD
    self.Tabs[DocumentType.DocAudo].view = self.FavorabilityAudio

    self.TabsList = {}
    self.TabsList[DocumentType.DocFile] = self.BtnTog0
    self.TabsList[DocumentType.DocInfo] = self.BtnTog1
    self.TabsList[DocumentType.DocRumor] = self.BtnTog2
    self.TabsList[DocumentType.DocAudo] = self.BtnTog3
    self.DocumentBtnGroup:Init(self.TabsList, function(index) self:OnBtnTabsListClick(index) end)
end

function XUiPanelFavorabilityDocument:RefreshDatas()
    self.DocumentBtnGroup:SelectIndex(self.LastSelectTab or DocumentType.DocFile)
    self:CheckDataReddots()
end

function XUiPanelFavorabilityDocument:CheckDataReddots()
    self:CheckDataReddot()
    self:CheckRumorReddot()
    self:CheckAudioReddot()
end

function XUiPanelFavorabilityDocument:OnBtnTabsListClick(index)
    for i=1, DocumentTypeSize do
        self.Tabs[i].view:SetViewActive(index == i)
    end
    if self.LastSelectTab then
        self.UiRoot:PlaySubTabAnim()
    end
    self.LastSelectTab = index
end

function XUiPanelFavorabilityDocument:OnClose()
    self.FavorabilityAudio:OnClose()
end

function XUiPanelFavorabilityDocument:SetViewActive(isActive)
    self.GameObject:SetActive(isActive)
    if isActive then
        self:RefreshDatas()
    else
        self:OnClose()
    end
end

return XUiPanelFavorabilityDocument

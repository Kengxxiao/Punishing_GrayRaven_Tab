local XUiExhibition = XLuaUiManager.Register(XLuaUi, "UiExhibition")

local XUiGridCharacterIcon = require("XUi/XUiExhibition/XUiGridCharacterIcon")
local XUiGridCharacterName = require("XUi/XUiExhibition/XUiGridCharacterName")
local XUiGridGroupIcon = require("XUi/XUiExhibition/XUiGridGroupIcon")
local XUiGridGroupName = require("XUi/XUiExhibition/XUiGridGroupName")
local XUiPanelCollection = require("XUi/XUiExhibition/XUiPanelCollection")
local Vector3 = CS.UnityEngine.Vector3
function XUiExhibition:OnAwake()
    self:AddBtnListener()
end

function XUiExhibition:OnStart(isSelf)
    self.IsSelf = isSelf
    self.CharacterIconGridList = {}
    self.CharacterNameGridList = {}
    self.GroupIconGridList = {}
    self.GroupNameGridList = {}
    local behaviour = self.Transform.gameObject:AddComponent(typeof(CS.XLuaBehaviour))
    if self.Update then
        behaviour.LuaUpdate = function() self:Update() end
    end
    self.CurCharacterId = nil
    self.CurIndex = nil
    self.Focusing = false
    self.ShowDetailMinScale = CS.XGame.ClientConfig:GetFloat("ExhibitionShowDetailMinScale")
    self.DetailFadeTime = CS.XGame.ClientConfig:GetFloat("ExhibitionDetailFadeTime")
    self.DetailZoomTime = CS.XGame.ClientConfig:GetFloat("ExhibitionDetailZoomTime")
    self.CollectionInfoPanel = XUiPanelCollection.New(self.PanelCollection, self)
end

function XUiExhibition:OnEnable()
    self:RefreshExhibitionInfo()
end

function XUiExhibition:OnDestroy()
    XDataCenter.ExhibitionManager.SetCharacterInfo(XDataCenter.ExhibitionManager.GetSelfGatherRewards())
end

function XUiExhibition:AddBtnListener()
    self.BtnHelp.CallBack = function() self:OnBtnHelpClick() end
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnOpenCollection, self.OnBtnOpenCollectionClick)
    self:RegisterClickEvent(self.BtnCloseCollection, self.OnBtnCloseCollectionClick)
end

function XUiExhibition:RefreshExhibitionInfo()
    self.ShowName = false
    local exhibitionConfig = XExhibitionConfigs.GetExhibitionConfig()
    local exhibitionGroupNameConfig = XExhibitionConfigs.GetExhibitionGroupNameConfig()
    local exhibitionGroupLogoConfig = XExhibitionConfigs.GetExhibitionGroupLogoConfig()

    for _, config in pairs(exhibitionConfig) do
        local portId = config.Port
        local iconGrid
        local nameGrid
        local iconParent = self.PanelCharacterIcon:Find(portId)
        iconParent.gameObject:SetActive(true)
        if self.CharacterIconGridList[portId] ~= nil then
            iconGrid = self.CharacterIconGridList[portId]
            iconGrid:Refresh(config.CharacterId)
        else
            local iconGo = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("ExhibitionCharacterIcon"))
            iconGo.transform:SetParent(iconParent, false)
            if iconGo == nil or not iconGo:Exist() then
                return
            end

            iconGrid = XUiGridCharacterIcon.New(self, portId, iconGo, config.CharacterId)
            self.CharacterIconGridList[portId] = iconGrid
        end

        if self.CharacterNameGridList[portId] ~= nil then
            nameGrid = self.CharacterNameGridList[portId]
            nameGrid:Refresh(config.CharacterId)
        else
            local nameParent = self.PanelCharacterName:Find(portId)
            nameParent.gameObject:SetActive(true)
            local nameGo = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("ExhibitionCharacterName"))
            nameGo.transform:SetParent(nameParent, false)
            if nameGo == nil or not nameGo:Exist() then
                return
            end

            nameGrid = XUiGridCharacterName.New(self, portId, nameGo, config.CharacterId)
            self.CharacterNameGridList[portId] = nameGrid
        end

        nameGrid:ResetPosition(iconGrid.Transform.position)
    end

    for groupId, _ in pairs(exhibitionGroupNameConfig) do
        local iconGrid
        local nameGrid

        if self.GroupIconGridList[groupId] ~= nil then
            iconGrid = self.GroupIconGridList[groupId]
        else
            local iconParent = self.PanelGroupIcon:Find(groupId)
            iconParent.gameObject:SetActive(true)
            local iconGo = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("ExhibitionGroupIcon"))
            iconGo.transform:SetParent(iconParent, false)
            if iconGo == nil or not iconGo:Exist() then
                return
            end
            iconGrid = XUiGridGroupIcon.New(iconGo, exhibitionGroupLogoConfig[groupId], groupId)
            self.GroupIconGridList[groupId] = iconGrid
        end

        if self.GroupNameGridList[groupId] ~= nil then
            nameGrid = self.GroupNameGridList[groupId]
        else
            local nameParent = self.PanelGroupName:Find(groupId)
            nameParent.gameObject:SetActive(true)
            local nameGo = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("ExhibitionGroupName"))
            nameGo.transform:SetParent(nameParent, false)
            if nameGo == nil or not nameGo:Exist() then
                return
            end
            nameGrid = XUiGridGroupName.New(nameGo, exhibitionGroupNameConfig[groupId])
            self.GroupNameGridList[groupId] = nameGrid
        end

        nameGrid:ResetPosition(iconGrid.Transform.position)
    end

    self:RefreshCollectionInfo()
end

function XUiExhibition:Update()
    if self.Focusing then
        return
    end
    local curScale = self.PanelCharacter.localScale.x
    if curScale > self.ShowDetailMinScale and not self.ShowName then
        self.ShowName = true
        self:ShowNameLayer()
    elseif curScale < self.ShowDetailMinScale and self.ShowName then
        self.ShowName = false
        self:HideNameLayer()
    end
end

function XUiExhibition:ShowNameLayer()
    self.LayerNameCanvasGroup:DOFade(1, self.DetailFadeTime)
end

function XUiExhibition:HideNameLayer()
    self.LayerNameCanvasGroup:DOFade(0, self.DetailFadeTime)  
end

function XUiExhibition:StartFocus(index, characterId)

    -- self.Focusing = true
    -- self.CurIndex = index
    -- self.CurGridCanvasGroup = self.CharacterIconGridList[index].GameObject:AddComponent(typeof(CS.UnityEngine.CanvasGroup))
    -- self.CurGridCanvasGroup.ignoreParentGroups = true
    -- self:PlayAnimation("AnimPanelTaskHide")

    -- local offset = CS.UnityEngine.Vector3(self.IconPosition.position.x, 0, 0)
    -- self.DragArea:StartFocus(self.CharacterIconGridList[index].Transform.position, 1.0, self.DetailZoomTime, offset, true)
    self:ShowExhibitionInfo(characterId)
end

function XUiExhibition:EndFocus()
    self:PlayAnimation("AnimPanelTaskShow", function ()
        CS.UnityEngine.GameObject.Destroy(self.CurGridCanvasGroup)
    end)
    self.DragArea:EndFocus(function ()
        self.Focusing = false
    end)
end

function XUiExhibition:ShowExhibitionInfo(characterId)
    self.CurCharacterId = characterId
    XLuaUiManager.Open("UiExhibitionInfo", characterId)
end

function XUiExhibition:OnBtnOpenCollectionClick()
    self.CollectionInfoPanel:Show()
    self:PlayAnimation("AnimPanelCollectionEnable")
end

function XUiExhibition:OnBtnCloseCollectionClick()
    self:PlayAnimation("AnimPanelCollectionDisable", function ()
        self.CollectionInfoPanel:Hide()
    end)
end

function XUiExhibition:OnBtnHelpClick()
    XUiManager.UiFubenDialogTip("", CS.XTextManager.GetText("ExhibitionExplain") or "")
end

-- function XUiExhibition:HandleCharacterGrowUp()
--     self.CharacterIconGridList[self.CurIndex]:CharacterGrowUp()
--     self:RefreshCollectionInfo()
-- end

function XUiExhibition:RefreshCollectionInfo()
    local collectionRate = XDataCenter.ExhibitionManager.GetCollectionRate()
    self.TxtCollectionRate.text = math.floor(collectionRate * 100)
    self.ImgRate.fillAmount = collectionRate
end

function XUiExhibition:OnBtnBackClick()
    self:Close()
end

function XUiExhibition:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiExhibition:OnGetEvents()
    return { XEventId.EVENT_CHARACTER_EXHIBITION_AUTOSELECT }
end

function XUiExhibition:OnNotify(evt, ...)
    local args = { ... }
    
    if evt == XEventId.EVENT_CHARACTER_EXHIBITION_AUTOSELECT then
        if not args[1] then return end
        local selectGrid = nil
        for k, v in pairs(self.CharacterIconGridList or {}) do
            if v.CharacterId == args[1] then
                selectGrid = v
                break
            end
        end
        if not selectGrid then return end
        selectGrid:BtnSelectClick()
    end
end

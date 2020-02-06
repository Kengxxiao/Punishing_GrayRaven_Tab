
local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")

local XUiCharacterOwnedInfo = XLuaUiManager.Register(XLuaUi, "UiCharacterOwnedInfo")

function XUiCharacterOwnedInfo:OnAwake()
    self:AddListener()
end

function XUiCharacterOwnedInfo:OnStart(forbidGotoEquip, clickCb)
    self.ForbidGotoEquip = forbidGotoEquip
    self.ClickCb = clickCb
    self.BtnLevelUp.gameObject:SetActive(not forbidGotoEquip)
    self.BtnJoin.gameObject:SetActive(forbidGotoEquip)
    self:RegisterRedPointEvent()
end

function XUiCharacterOwnedInfo:OnEnable()
    self:UpdateView(self.CharacterId)
end

function XUiCharacterOwnedInfo:PreSetCharacterId(characterId)
    self.CharacterId = characterId
end

function XUiCharacterOwnedInfo:RegisterRedPointEvent()
    local characterId = self.CharacterId
    self.RedPointId = XRedPointManager.AddRedPointEvent(self.ImgRedPoint, self.OnCheckCharacterRedPoint, self, { XRedPointConditions.Types.CONDITION_CHARACTER }, characterId)
end

function XUiCharacterOwnedInfo:OnCheckCharacterRedPoint(count, args)
    self.ImgRedPoint.gameObject:SetActive(count >= 0)
end

function XUiCharacterOwnedInfo:UpdateView(characterId)
    self.CharacterId = characterId

    local charConfig = XCharacterConfigs.GetCharacterTemplate(characterId)
    self.TxtName.text = charConfig.Name
    self.TxtNameOther.text = charConfig.TradeName

    local character = XDataCenter.CharacterManager.GetCharacter(characterId)
    self.RImgTypeIcon:SetRawImage(XCharacterConfigs.GetNpcTypeIcon(character.Type))
    self.TxtLv.text = math.floor(character.Ability)

    self.WeaponGrid = self.WeaponGrid or XUiGridEquip.New(self.GridWeapon, nil, self)
    local usingWeaponId = XDataCenter.EquipManager.GetCharacterWearingWeaponId(characterId)
    self.WeaponGrid:Refresh(usingWeaponId)

    self.WearingAwarenessGrids = self.WearingAwarenessGrids or {}
    for _, equipSite in pairs(XEquipConfig.EquipSite.Awareness) do
        self.WearingAwarenessGrids[equipSite] = self.WearingAwarenessGrids[equipSite] or XUiGridEquip.New(CS.UnityEngine.Object.Instantiate(self.GridAwareness), nil, self)
        self.WearingAwarenessGrids[equipSite].Transform:SetParent(self["PanelAwareness" .. equipSite], false)

        local equipId = XDataCenter.EquipManager.GetWearingEquipIdBySite(characterId, equipSite)
        if not equipId then
            self.WearingAwarenessGrids[equipSite].GameObject:SetActive(false)
            self["PanelNoAwareness" .. equipSite].gameObject:SetActive(true)
        else
            self.WearingAwarenessGrids[equipSite].GameObject:SetActive(true)
            self["BtnAwarenessReplace" .. equipSite].transform:SetAsLastSibling()
            self["PanelNoAwareness" .. equipSite].gameObject:SetActive(false)
            self.WearingAwarenessGrids[equipSite]:Refresh(equipId)
        end
    end

    local detailConfig = XCharacterConfigs.GetCharDetailTemplate(characterId)
    local elementList = detailConfig.ObtainElementList
    for i = 1, 3 do
        local rImg = self["RImgCharElement" .. i]
        if elementList[i] then
            rImg.gameObject:SetActive(true)
            local elementConfig = XCharacterConfigs.GetCharElment(elementList[i])
            rImg:SetRawImage(elementConfig.Icon)
        else
            rImg.gameObject:SetActive(false)
        end
    end

    XRedPointManager.Check(self.RedPointId, characterId)
end

function XUiCharacterOwnedInfo:AddListener()
    self:RegisterClickEvent(self.BtnLevelUp, self.OnBtnLevelUpClick)
    self:RegisterClickEvent(self.BtnAwarenessReplace6, self.OnBtnAwarenessReplace6Click)
    self:RegisterClickEvent(self.BtnAwarenessReplace5, self.OnBtnAwarenessReplace5Click)
    self:RegisterClickEvent(self.BtnAwarenessReplace4, self.OnBtnAwarenessReplace4Click)
    self:RegisterClickEvent(self.BtnAwarenessReplace3, self.OnBtnAwarenessReplace3Click)
    self:RegisterClickEvent(self.BtnAwarenessReplace2, self.OnBtnAwarenessReplace2Click)
    self:RegisterClickEvent(self.BtnAwarenessReplace1, self.OnBtnAwarenessReplace1Click)
    self:RegisterClickEvent(self.BtnWeaponReplace, self.OnBtnWeaponReplaceClick)
    self:RegisterClickEvent(self.BtnJoin, self.OnBtnJoinClick)
    self:RegisterClickEvent(self.BtnCareerTips, self.OnBtnCareerTipsClick)
    self.BtnElementDetail.CallBack = function() self:OnBtnElementDetailClick() end
end

function XUiCharacterOwnedInfo:OnBtnAwarenessReplace5Click(eventData)
    self:OnAwarenessClick(5)
end

function XUiCharacterOwnedInfo:OnBtnAwarenessReplace4Click(eventData)
    self:OnAwarenessClick(4)
end

function XUiCharacterOwnedInfo:OnBtnAwarenessReplace3Click(eventData)
    self:OnAwarenessClick(3)
end

function XUiCharacterOwnedInfo:OnBtnAwarenessReplace2Click(eventData)
    self:OnAwarenessClick(2)
end

function XUiCharacterOwnedInfo:OnBtnAwarenessReplace1Click(eventData)
    self:OnAwarenessClick(1)
end

function XUiCharacterOwnedInfo:OnBtnAwarenessReplace6Click(eventData)
    self:OnAwarenessClick(6)
end

function XUiCharacterOwnedInfo:OnAwarenessClick(site)
    if self.ForbidGotoEquip then return end
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Equip) then
        return
    end
    XLuaUiManager.Open("UiEquipAwarenessReplace", self.CharacterId, site)
end

function XUiCharacterOwnedInfo:OnBtnCareerTipsClick(eventData)
    XLuaUiManager.Open("UiCharacterCarerrTips")
end

function XUiCharacterOwnedInfo:OnBtnWeaponReplaceClick(...)
    if self.ForbidGotoEquip then return end
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.Equip) then
        return
    end
    XLuaUiManager.Open("UiEquipReplaceNew", self.CharacterId)
end

function XUiCharacterOwnedInfo:OnBtnLevelUpClick()
    if self.ClickCb then self.ClickCb() end
end

function XUiCharacterOwnedInfo:OnBtnJoinClick()
    XDataCenter.AssistManager.ChangeAssistCharacterId(self.CharacterId, function(code)
        if (code == XCode.Success) then
            XLuaUiManager.Close("UiCharacter")
        end
    end)
end

function XUiCharacterOwnedInfo:OnBtnElementDetailClick(eventData)
    XLuaUiManager.Open("UiCharacterElementDetail", self.CharacterId)
end
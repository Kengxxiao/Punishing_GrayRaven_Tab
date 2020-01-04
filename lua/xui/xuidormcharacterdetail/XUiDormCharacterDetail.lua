local XUiGridDetailDormCharacter = require("XUi/XUiDormCharacterDetail/XUiGridDetailDormCharacter")
local XUiDormCharacterDetail = XLuaUiManager.Register(XLuaUi, "UiDormCharacterDetail")

function XUiDormCharacterDetail:OnAwake()
    self:AddListener()

    CS.XGlobalIllumination.SetSceneType(CS.XSceneType.Ui)

    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_MOOD_CHANGED, self.UpdateMoodInfo, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_VITALITY_CHANGED, self.UpdateVitalityInfo, self)

    --这里处理一下场景类型
end

function XUiDormCharacterDetail:OnDisable()
    XHomeDormManager.ShowOrHideBuilding(true)
    CS.XGlobalIllumination.SetSceneType(CS.XSceneType.Dormitory)
end


function XUiDormCharacterDetail:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_MOOD_CHANGED, self.UpdateMoodInfo, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_VITALITY_CHANGED, self.UpdateVitalityInfo, self)

    if self.Resource then
        self.Resource:Release()
     end

    if self.Model then
        CS.UnityEngine.Object.Destroy(self.Model)
    end
end

function XUiDormCharacterDetail:OnStart(characterId)
    XHomeDormManager.ShowOrHideBuilding(false)
    self.CharacterId = characterId
    XHomeCharManager.HideAllCharacter()
    self:InitStyleInfo()
    self:InitModelInfo()
    self:InitExpInfo()

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.DormCoin, XDataCenter.ItemManager.ItemId.FurnitureCoin)
end

function XUiDormCharacterDetail:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnLikeInfo, self.OnBtnLikeInfoClick)
    self:RegisterClickEvent(self.BtnFriendInfo, self.OnBtnFriendInfoClick)
end

function XUiDormCharacterDetail:OnBtnMainUiClick(...)
    XHomeCharManager.ShowAllCharacter()
    XHomeDormManager.SetIllumination()
    XLuaUiManager.RunMain()
end

function XUiDormCharacterDetail:OnBtnBackClick(...)
    XHomeCharManager.ShowAllCharacter()
    XHomeDormManager.SetIllumination()
    self:Close()
end

function XUiDormCharacterDetail:OnBtnLikeInfoClick(...)
    XLuaUiManager.Open("UiDormCharacterLikeInfo", self.CharacterId)
end

function XUiDormCharacterDetail:OnBtnFriendInfoClick(...)
    -- 暂未开放
    XUiManager.TipMsg(CS.XTextManager.GetText("ComingSoon"), XUiManager.UiTipType.Tip)
end

function XUiDormCharacterDetail:InitStyleInfo()
    self.GridHostelCharacter.gameObject:SetActive(false)

    local charConfig = XCharacterConfigs.GetCharacterTemplate(self.CharacterId)
    self.TxtName.text = charConfig.Name
    self.TxtLastName.text = charConfig.TradeName

    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(self.CharacterId)
    local loveTypeConfig = XFurnitureConfigs.GetDormFurnitureType(charStyleConfig.LoveType)
    local likeTypeConfig = XFurnitureConfigs.GetDormFurnitureType(charStyleConfig.LikeType)

    self:SetUiSprite(self.ImgLove, loveTypeConfig.TypeIcon)
    self:SetUiSprite(self.ImgLike, likeTypeConfig.TypeIcon)

    self.TxtLove.text = CS.XTextManager.GetText("DormHight", loveTypeConfig.Color, loveTypeConfig.TypeName)
    self.TxtLike.text = CS.XTextManager.GetText("DormMiddle", likeTypeConfig.Color, likeTypeConfig.TypeName)

    for i = 1, #charStyleConfig.LikeCharIds do
        local grid = CS.UnityEngine.Object.Instantiate(self.GridHostelCharacter)
        local gridDormCharacter = XUiGridDetailDormCharacter.New(grid)
        gridDormCharacter:Refresh(charStyleConfig.LikeCharIds[i], true)
        grid.transform:SetParent(self.PanelLikeConent, false)
        gridDormCharacter.GameObject:SetActive(true)
    end

    for i = 1, #charStyleConfig.HateCharIds do
        local grid = CS.UnityEngine.Object.Instantiate(self.GridHostelCharacter)
        local gridDormCharacter = XUiGridDetailDormCharacter.New(grid)
        gridDormCharacter:Refresh(charStyleConfig.HateCharIds[i], false)
        grid.transform:SetParent(self.PanelHateConent, false)
        gridDormCharacter.GameObject:SetActive(true)
    end
end

function XUiDormCharacterDetail:InitModelInfo()
    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(self.CharacterId)
    local root = self:GetSceneRoot().transform
    local target = root:FindTransform("PanelRoleModel")

    self.Resource = CS.XResourceManager.Load(charStyleConfig.Model)
    self.Model = CS.UnityEngine.Object.Instantiate(self.Resource.Asset)
    self.Model.transform:SetParent(target, false)
    self.Model.gameObject:SetLayerRecursively(target.gameObject.layer)
    self.PanelDrag.Target = self.Model.transform

    local animator = self.Model:GetComponent("Animator")
    animator:SetInteger("State", 1)
end

function XUiDormCharacterDetail:InitExpInfo()
    local characterData = XDataCenter.DormManager.GetCharacterDataByCharId(self.CharacterId)

    self.ImgHpExp.fillAmount = characterData.Vitality / XDormConfig.DORM_VITALITY_MAX_VALUE
    self.ImgMoodExp.fillAmount = characterData.Mood / XDormConfig.DORM_MOOD_MAX_VALUE
    self.TxtHpCount.text = CS.XTextManager.GetText("DormCharacterHpLeft", characterData.Vitality, XDormConfig.DORM_VITALITY_MAX_VALUE)

    self.TxtMoodState.text = XDormConfig.GetMoodStateDesc(characterData.Mood)
    self.ImgMoodExp.color = XDormConfig.GetMoodStateColor(characterData.Mood)

    XDataCenter.DormManager.GetDormitoryRecoverSpeed(self.CharacterId, function(moodSpeed, vitalitySpeed)
        self.TxtMoodRecover.text = CS.XTextManager.GetText("DormCharacterMoodSpeed", moodSpeed)
        self.TxtHpRecover.text = CS.XTextManager.GetText("DormCharacterHpSpeed", vitalitySpeed)
    end)
end

function XUiDormCharacterDetail:UpdateMoodInfo(characterId, changeVaule)
    if not self.CharacterId or self.CharacterId ~= characterId then
        return
    end

    local characterData = XDataCenter.DormManager.GetCharacterDataByCharId(self.CharacterId)

    self.ImgMoodExp.fillAmount = characterData.Mood / XDormConfig.DORM_MOOD_MAX_VALUE
    self.TxtMoodState.text = XDormConfig.GetMoodStateDesc(characterData.Mood)
    self.ImgMoodExp.color = XDormConfig.GetMoodStateColor(characterData.Mood)
end

function XUiDormCharacterDetail:UpdateVitalityInfo(characterId)
    if not self.CharacterId or self.CharacterId ~= characterId then
        return
    end

    local characterData = XDataCenter.DormManager.GetCharacterDataByCharId(self.CharacterId)

    self.ImgHpExp.fillAmount = characterData.Vitality / XDormConfig.DORM_VITALITY_MAX_VALUE
    self.TxtHpCount.text = CS.XTextManager.GetText("DormCharacterHpLeft", characterData.Vitality, XDormConfig.DORM_VITALITY_MAX_VALUE)
end
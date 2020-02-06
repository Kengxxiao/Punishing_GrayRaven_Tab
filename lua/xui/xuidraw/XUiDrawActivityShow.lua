local XUiDrawActivityShow = XLuaUiManager.Register(XLuaUi, "UiDrawActivityShow")
local drawShowWeapon = require("XUi/XUiDraw/XUiDrawTools/XUiDrawWeapon")
local drawShowEffect = require("XUi/XUiDraw/XUiDrawTools/XUiDrawShowEffect")
local drawScene = require("XUi/XUiDraw/XUiDrawTools/XUiDrawScene")

function XUiDrawActivityShow:OnAwake()
    self:InitAutoScript()
end

function XUiDrawActivityShow:OnStart()
    self.Animation = self.Transform:GetComponent("Animation")
    self:InitImgRewards()
end

function XUiDrawActivityShow:SetData(rewardList, resultCb, backGround)
    self.BackGround = backGround
    self.RewardList = rewardList
    self.ResultCb = resultCb

    self:ResetState()
    self:InitTools()
    self.ShowIndex = 1
    self.IsOpening = false
    self.CurLight = {}
    self.PlayBoxAnim = false
    self.BtnClick.gameObject:SetActiveEx(false)
    self:InitDrawBackGround()
    XUiHelper.SetDelayPopupFirstGet(true)
end

function XUiDrawActivityShow:OnDisable()
    self:HideAllEffect()
    XUiHelper.SetDelayPopupFirstGet()
end

function XUiDrawActivityShow:Update()
    if self.PlayBoxAnim then
        if self.PlayableDirector.time >= self.PlayableDirector.duration - 0.1 then
            self:BoxAnimEnd()
        end
    end
end

function XUiDrawActivityShow:InitImgRewards()
    self.ImgRewards = {}
    self.ImgRewards[XArrangeConfigs.Types.Character] = self.ImgCharacter
    self.ImgRewards[XArrangeConfigs.Types.Fashion] = self.ImgItem
    self.ImgRewards[XArrangeConfigs.Types.Item] = self.ImgItem
    self.ImgRewards[XArrangeConfigs.Types.Wafer] = self.ImgWafer
    self.ImgRewards[XArrangeConfigs.Types.Weapon] = self.ImgEquip
    self.ImgRewards[XArrangeConfigs.Types.Furniture] = self.ImgItem
    self.ImgRewards[XArrangeConfigs.Types.HeadPortrait] = self.ImgItem
end

function XUiDrawActivityShow:ResetState()
    self.ImgCharacter.gameObject:SetActiveEx(false)
    self.ImgItem.gameObject:SetActiveEx(false)
    self.ImgWafer.gameObject:SetActiveEx(false)
    self.ImgEquip.gameObject:SetActiveEx(false)
    self.ImageItemPack.gameObject:SetActiveEx(false)
    self.ImageWeaponPack.gameObject:SetActiveEx(false)
    self.ImageCharacterPack.gameObject:SetActiveEx(false)
    self.ImageWaferPack.gameObject:SetActiveEx(false)
end

function XUiDrawActivityShow:InitTools()
    --drawScene.AddObject(self.PanelWeapon, drawScene.Types.WEAPON)
    --drawShowWeapon.SetNode(self.PanelAnim, self.PanelWeapon)
    drawScene.SetActive(drawScene.Types.BOX, false)
    drawScene.SetActive(drawScene.Types.BG, false)
    XRTextureManager.SetTextureCahe(self.RImgDrawCardShow)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawActivityShow:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiDrawActivityShow:AutoInitUi()
    -- self.PanelDrawBackGround = self.Transform:Find("FullScreenBackground/PanelDrawBackGround")
    -- self.PanelResult = self.Transform:Find("SafeAreaContentPane/PanelResult")
    -- self.ImgItem = self.Transform:Find("SafeAreaContentPane/PanelResult/ImgItem"):GetComponent("RawImage")
    -- self.ImgCharacter = self.Transform:Find("SafeAreaContentPane/PanelResult/ImgCharacter"):GetComponent("RawImage")
    -- self.ImgWafer = self.Transform:Find("SafeAreaContentPane/PanelResult/ImgWafer"):GetComponent("RawImage")
    -- self.RImgDrawCardShow = self.Transform:Find("SafeAreaContentPane/RImgDrawCardShow"):GetComponent("RawImage")
    -- self.PanelEffect = self.Transform:Find("SafeAreaContentPane/PanelEffect")
    -- self.BtnClick = self.Transform:Find("SafeAreaContentPane/BtnClick"):GetComponent("Button")
    -- self.PanelAnim = self.Transform:Find("SafeAreaContentPane/ModelRoot/NearRoot/PanelAnim")
    -- self.PanelInfo = self.Transform:Find("SafeAreaContentPane/PanelInfo")
    -- self.TxtType = self.Transform:Find("SafeAreaContentPane/PanelInfo/TxtType"):GetComponent("Text")
    -- self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelInfo/TxtName"):GetComponent("Text")
    -- self.TxtQuality = self.Transform:Find("SafeAreaContentPane/PanelInfo/TxtQuality"):GetComponent("Text")
    -- self.ImgEquip = self.Transform:Find("SafeAreaContentPane/PanelResult/ImgEquip"):GetComponent("RawImage")
    -- self.BtnSkip = self.Transform:Find("SafeAreaContentPane/BtnSkip"):GetComponent("Button")
end

function XUiDrawActivityShow:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
    self:RegisterClickEvent(self.BtnSkip, self.OnBtnSkipClick)
end
-- auto
function XUiDrawActivityShow:OnBtnClickClick()
    if self.IsOpening then
        self:ShowResult()
    else
        self:HideAllEffect()
        self:NextPack()
    end
end

function XUiDrawActivityShow:OnBtnSkipClick()
    self:ClearLastModel()
    self:PlayEnd()
end

function XUiDrawActivityShow:ShowWeapon()
    drawScene.SetActive(drawScene.Types.WEAPON, true)
end

function XUiDrawActivityShow:ShowResult()
    XUiHelper.StopAnimation(false)

    local reward = self.RewardList[self.ShowIndex]
    local id = reward.Id and reward.Id > 0 and reward.Id or reward.TemplateId
    if reward.ConvertFrom > 0 then
        id = reward.ConvertFrom
    end
    local Type = XTypeManager.GetTypeById(id)
    local quality
    local templateIdData = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(id)
    if Type == XArrangeConfigs.Types.Wafer then
        quality = templateIdData.Star
    elseif Type == XArrangeConfigs.Types.Weapon then
        quality = templateIdData.Star
    elseif Type == XArrangeConfigs.Types.Character then
        quality = XCharacterConfigs.GetCharMinQuality(id)
    else
        quality = XTypeManager.GetQualityById(id)
    end
    local showTable = XDataCenter.DrawManager.GetDrawShow(Type)
    local skipEffect = string.gsub(showTable.PanelGachaOpenUp[quality], ".prefab", "Skip.prefab")
    self.CurPanelOpenUpEffect = self.PanelOpenUp:LoadPrefab(skipEffect)
    self.CurPanelOpenUpEffect.gameObject.name = skipEffect
    self.CurPanelOpenUpEffect.gameObject:SetActiveEx(true)

    local reward = self.RewardList[self.ShowIndex]
    local id = reward.Id and reward.Id > 0 and reward.Id or reward.TemplateId
    if reward.ConvertFrom > 0 then
        id = reward.ConvertFrom
    end

    local Type = XTypeManager.GetTypeById(id)
    local showTable = XDataCenter.DrawManager.GetDrawShow(Type)
    self.IsOpening = false
    self.Animation:Play(showTable.UiResultAnim)
    if Type == XArrangeConfigs.Types.Weapon then
        drawShowWeapon.PlayResultAnim()
    end

    self.ShowIndex = self.ShowIndex + 1
end

function XUiDrawActivityShow:ClearLastModel()
    if self.LastCharacterModel then
        self.LastCharacterModel.gameObject:SetActiveEx(false)
        self.LastCharacterModel = nil
    end

    if self.LastWeaponModel then
        self.LastWeaponModel.gameObject:SetActiveEx(false)
        self.LastWeaponModel = nil
    end
end

function XUiDrawActivityShow:NextPack()
    self.BtnClick.gameObject:SetActiveEx(false)
    self:ClearLastModel()
    if self.ShowIndex > #self.RewardList then
        self:PlayEnd()
        return
    end
    
    if self.CvInfo then
        self.CvInfo:Stop()
        self.CvInfo = nil
    end

    local reward = self.RewardList[self.ShowIndex]
    local id = reward.Id and reward.Id > 0 and reward.Id or reward.TemplateId
    if reward.ConvertFrom > 0 then
        id = reward.ConvertFrom
    end
    local Type = XTypeManager.GetTypeById(id)
    local quality
    local templateIdData = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(id)
    if Type == XArrangeConfigs.Types.Wafer then
        quality = templateIdData.Star
    elseif Type == XArrangeConfigs.Types.Weapon then
        quality = templateIdData.Star
    elseif Type == XArrangeConfigs.Types.Character then
        quality = XCharacterConfigs.GetCharMinQuality(id)
    else
        quality = XTypeManager.GetQualityById(id)
    end


    local soundType = XSoundManager.UiBasicsMusic.UiDrawCard_Type.Normal
    
    local needCharacterNameSound = false
    if quality then
        if quality == 5 then
            soundType = XSoundManager.UiBasicsMusic.UiDrawCard_Type.FiveStar
        elseif quality == 6 then
            soundType = XSoundManager.UiBasicsMusic.UiDrawCard_Type.SixStar
        end
    end

    local icon
    if Type == XArrangeConfigs.Types.Weapon or Type == XArrangeConfigs.Types.Furniture or Type == XArrangeConfigs.Types.HeadPortrait then
        local goodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(id)
        icon = goodsShowParams.BigIcon

        if Type ~= XArrangeConfigs.Types.Weapon then
            self.ImgRewards[Type]:SetRawImage(icon)
            self.BtnClick.gameObject:SetActiveEx(true)
        end
    else
        if Type == XArrangeConfigs.Types.Character then
            icon = XDataCenter.CharacterManager.GetCharHalfBodyImage(id)
            if quality < 3 then
                soundType = XSoundManager.UiBasicsMusic.UiDrawCard_Type.FiveStar
            elseif quality > 2 then
                soundType = XSoundManager.UiBasicsMusic.UiDrawCard_Type.SixStar
            end
            needCharacterNameSound = true
        elseif Type == XArrangeConfigs.Types.Wafer then
            local star = self.RewardList[self.ShowIndex].Star
            icon = XDataCenter.EquipManager.GetEquipLiHuiPath(id)
        elseif Type == XArrangeConfigs.Types.Item then
            icon = XDataCenter.ItemManager.GetItemBigIcon(id)
        elseif Type == XArrangeConfigs.Types.Fashion then
            icon = XDataCenter.FashionManager.GetFashionIcon(id)
        end

        if Type ~= XArrangeConfigs.Types.Character then
            self.ImgRewards[Type]:SetRawImage(icon)
            self.BtnClick.gameObject:SetActiveEx(true)
        end
    end
    local curShowNum = self.ShowIndex
    local showTable = XDataCenter.DrawManager.GetDrawShow(Type)
    self.IsOpening = true
    XUiHelper.StopAnimation(false)
    XUiHelper.PlayAnimation(self, showTable.UiAnim, nil, function()
        self.PanelCardShowOff.gameObject:SetActiveEx(true)
        if self.GameObject.activeInHierarchy then
            if curShowNum == self.ShowIndex then
                self.CurPanelOpenUpEffect = self.PanelOpenUp.transform:Find(showTable.PanelGachaOpenUp[quality])
                if self.CurPanelOpenUpEffect then
                    self.CurPanelOpenUpEffect.gameObject:SetActiveEx(true)
                else
                    self.CurPanelOpenUpEffect = self.PanelOpenUp:LoadPrefab(showTable.PanelGachaOpenUp[quality])
                    self.CurPanelOpenUpEffect.gameObject.name = showTable.PanelGachaOpenUp[quality]
                    self.CurPanelOpenUpEffect.gameObject:SetActiveEx(true)
                end
            end
            if Type == XArrangeConfigs.Types.Character then
                self:ShowCharacterModel(id)
            elseif Type == XArrangeConfigs.Types.Weapon then
                self:ShowWeaponModel(id)
            end
            XUiHelper.PlayAnimation(self, showTable.UiAnim .. "Item", nil, function()
                if curShowNum == self.ShowIndex then
                    self.IsOpening = false
                    self.ShowIndex = self.ShowIndex + 1
                end
            end)
        end
        
        CS.XAudioManager.PlaySound(soundType.Show)
    end)

    CS.XAudioManager.PlaySound(soundType.Start)

    local templeid = id
    if XArrangeConfigs.Types.Furniture == reward.RewardType then
        local cfg = XFurnitureConfigs.GetFurnitureReward(id)
        if cfg and cfg.FurnitureId then
            templeid = cfg.FurnitureId
        end
    end
    self.TxtName.text = XTypeManager.GetNameById(templeid)
    self.TxtType.text = showTable.TypeText
    self.TxtQuality.text = showTable.QualityText[quality]

    --effect
    self.PanelOpenUp.gameObject:SetActiveEx(true)
    self.PanelOpenDown.gameObject:SetActiveEx(true)
    -- self.PanelCardShowOff.gameObject:SetActiveEx(true)
    self.CurPanelOpenDownEffect = self.PanelOpenDown.transform:Find(showTable.PanelGachaOpenDown[quality])
    -- self.CurPanelCardShowOffEffect = self.PanelCardShowOff.transform:Find(showTable.PanelCardShowOff[quality])
    if self.CurPanelOpenDownEffect then
        self.CurPanelOpenDownEffect.gameObject:SetActiveEx(true)
    else
        self.CurPanelOpenDownEffect = self.PanelOpenDown:LoadPrefab(showTable.PanelGachaOpenDown[quality])
        self.CurPanelOpenDownEffect.gameObject.name = showTable.PanelGachaOpenDown[quality]
        self.CurPanelOpenDownEffect.gameObject:SetActiveEx(true)
    end
    -- if self.CurPanelCardShowOffEffect then
    --     self.CurPanelCardShowOffEffect.gameObject:SetActiveEx(true)
    -- else
    --     self.CurPanelCardShowOffEffect = self.PanelCardShowOff:LoadPrefab(showTable.PanelCardShowOff[quality])
    --     self.CurPanelCardShowOffEffect.gameObject.name = showTable.PanelCardShowOff[quality]
    --     self.CurPanelCardShowOffEffect.gameObject:SetActiveEx(true)
    -- end
end

function XUiDrawActivityShow:ShowWeaponModel(templateId)
    local modelConfig = XDataCenter.EquipManager.GetWeaponModelCfg(templateId, self.Name, 0)
    if modelConfig then
        XModelManager.LoadWeaponModel(modelConfig.ModelName, self.WeaponRoot, modelConfig.TransfromConfig, function(model)
            local rotate = self.WeaponRoot:GetComponent("XAutoRotation")
            if rotate then
                rotate.RotateSelf = false
                rotate.Inited = false
                rotate.Target = model.transform
            end

            model.gameObject:SetActiveEx(true)
            self.LastWeaponModel = model
            self.BtnClick.gameObject:SetActiveEx(true)
        end)
    end
end

function XUiDrawActivityShow:ShowCharacterModel(templateId)
    if not self.InitRoleMode then
        self.InitRoleMode = true
        self.RoleModelPanel = XUiPanelRoleModel.New(self.CharacterRoot, self.Name, true, false, false)
    end

    local fashtionId = XCharacterConfigs.GetCharacterTemplate(templateId).DefaultNpcFashtionId
    XDataCenter.DisplayManager.UpdateRoleModel(self.RoleModelPanel, templateId, nil, fashtionId)

    self.RoleModelPanel:UpdateCharacterModel(templateId, self.CharacterRoot, XModelManager.MODEL_UINAME.XUiDrawShow, function(model)
        CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiDrawCard_Chouka_Name)
        model.gameObject:SetActiveEx(true)

        local animeID = XDataCenter.DrawManager.GetDrawShowCharacter(templateId).AnimeID
        local voiceId = XDataCenter.DrawManager.GetDrawShowCharacter(templateId).VoiceId

        if animeID then
            self.RoleModelPanel:PlayAnima(animeID)
        end

        if voiceId then
            self.CvInfo = CS.XAudioManager.PlayCv(voiceId)
        end

        self.LastCharacterModel = model
        self.BtnClick.gameObject:SetActiveEx(true)
    end, nil, fashtionId)
end

function XUiDrawActivityShow:HideAllEffect()
    if not XTool.UObjIsNil(self.PanelOpenUp) then
        self.PanelOpenUp.gameObject:SetActiveEx(false)
    end
    if not XTool.UObjIsNil(self.PanelOpenDown) then
        self.PanelOpenDown.gameObject:SetActiveEx(false)
    end
    if not XTool.UObjIsNil(self.PanelCardShowOff) then
        self.PanelCardShowOff.gameObject:SetActiveEx(false)
    end
    if not XTool.UObjIsNil(self.CurPanelOpenUpEffect) then
        self.CurPanelOpenUpEffect.gameObject:SetActiveEx(false)
    end
    if not XTool.UObjIsNil(self.CurPanelOpenDownEffect) then
        self.CurPanelOpenDownEffect.gameObject:SetActiveEx(false)
    end
    if not XTool.UObjIsNil(self.CurPanelCardShowOffEffect) then
        self.CurPanelCardShowOffEffect.gameObject:SetActiveEx(false)
    end
end

function XUiDrawActivityShow:PlayEnd()
    XUiHelper.StopAnimation()

    self.BtnClick.gameObject:SetActiveEx(true)
    drawScene.SetActive(drawScene.Types.BOX, true)
    if self.CurStape_1 and not XTool.UObjIsNil(self.CurStape_1.gameObject) then
        self.CurStape_1.gameObject:SetActiveEx(false)
    end
    if self.CurStape_2 and not XTool.UObjIsNil(self.CurStape_2.gameObject) then
        self.CurStape_2.gameObject:SetActiveEx(false)
    end
    if self.CvInfo then
        self.CvInfo:Stop()
        self.CvInfo = nil
    end
    self:Close()
    self.ResultCb()
end

function XUiDrawActivityShow:OnDestroy()
    drawScene.DestroyObject(drawScene.Types.EFFECT)
    drawScene.DestroyObject(drawScene.Types.WEAPON)
    drawScene.DestroyObject(drawScene.Types.SHOWBG)
    drawShowEffect.Dispose()
end

--wind
function XUiDrawActivityShow:InitDrawBackGround(backgroundName)
    self.TxtType.text = ""
    self.TxtName.text = ""
    self.TxtQuality.text = ""
    self.PanelInfo.gameObject:GetComponent("CanvasGroup").alpha = 0

    self:PlayBoxAnimStart()
end

function XUiDrawActivityShow:PlayBoxAnimStart()
    self.PanelOpenUp = self.BackGround.transform:Find("ModelRoot/UiNearRoot/EffectRoot/PanelOpenUp")
    self.PanelOpenDown = self.BackGround.transform:Find("ModelRoot/UiNearRoot/EffectRoot/PanelOpenDown")
    self.PanelCardShowOff = self.BackGround.transform:Find("ModelRoot/UiNearRoot/EffectRoot/PanelCardShowOff")
    self.WeaponRoot = self.BackGround.transform:Find("ModelRoot/UiNearRoot/WeaponRoot")
    self.CharacterRoot = self.BackGround.transform:Find("ModelRoot/UiNearRoot/CharacterRoot")

    local behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    if self.Update then
        behaviour.LuaUpdate = function() self:Update() end
    end
    
    
    self.GachaShowStape_1 = self.BackGround.transform:Find("BoxEffect/Stape1")
    self.GachaShowStape_2 = self.BackGround.transform:Find("BoxEffect/Stape2")
    
    local effectsName = ""
    local effectsLevel = 1

    effectsName,effectsLevel = self:GetMaxQualityEffectName()
    
    if self.GachaShowStape_1 then
        self.CurStape_1 = self.GachaShowStape_1:LoadPrefab(XUiConfigs.GetComponentUrl("UiGachaSteap1"))
        self.CurStape_1.gameObject:SetActiveEx(true)
    end
    if self.GachaShowStape_2 then
        self.CurStape_2 = self.GachaShowStape_2:LoadPrefab(effectsName)
        self.CurStape_2.gameObject:SetActiveEx(true)
    end
    
    self.PlayableDirector = XUiHelper.TryGetComponent(self.BackGround.transform, "TimeLine/Level"..effectsLevel, "PlayableDirector")
    if self.PlayableDirector then
        self.PlayableDirector.gameObject:SetActiveEx(true)
        self.PlayableDirector:Play()
        self.PlayBoxAnim = true 
    end
end

function XUiDrawActivityShow:BoxAnimEnd()
    self.PlayBoxAnim = false
    self:NextPack()
end

function XUiDrawActivityShow:GetQuality(showIndex)
    local reward = self.RewardList[showIndex]
    local id = reward.Id and reward.Id > 0 and reward.Id or reward.TemplateId
    if reward.ConvertFrom > 0 then
        id = reward.ConvertFrom
    end
    local quality
    local templateIdData = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(id)
    local Type = XTypeManager.GetTypeById(id)
    if Type == XArrangeConfigs.Types.Wafer then
        quality = templateIdData.Star
    elseif Type == XArrangeConfigs.Types.Weapon then
        quality = templateIdData.Star
    elseif Type == XArrangeConfigs.Types.Character then
        quality = XCharacterConfigs.GetCharMinQuality(id)
    else
        quality = XTypeManager.GetQualityById(id)
    end
    return quality
end

function XUiDrawActivityShow:GetRewardType(showIndex)
    local reward = self.RewardList[showIndex]
    local id = reward.Id and reward.Id > 0 and reward.Id or reward.TemplateId
    if reward.ConvertFrom > 0 then
        id = reward.ConvertFrom
    end
    local type = XTypeManager.GetTypeById(id)
    return type
end

--获取最高品级效果，按类型取每一类最大值，最后比较大小得出最大的类型和值
function XUiDrawActivityShow:GetMaxQualityEffectName()
    local maxByType = {}

    for k, v in pairs(XArrangeConfigs.Types) do
        local maxQuality = 0
        for i = 1, #self.RewardList do
            if self:GetRewardType(i) == v then
                local tempQuality = self:GetQuality(i)
                if tempQuality > maxQuality then
                    maxQuality = tempQuality
                end
            end
        end
        maxByType[k] = maxQuality
    end
    local maxEffectLevel = 1
    local maxEffectPath
    for k, v in pairs(XArrangeConfigs.Types) do
        if maxByType[k] > 0 then
            local showTable = XDataCenter.DrawManager.GetDrawShow(v)
            if tonumber(string.sub(showTable.EffectOpenGacha[maxByType[k]], -8, -8)) > maxEffectLevel then
                maxEffectLevel = tonumber(string.sub(showTable.EffectOpenGacha[maxByType[k]], -8, -8))
                maxEffectPath = showTable.EffectOpenGacha[maxByType[k]] 
            end
        end
    end
    return maxEffectPath,maxEffectLevel
end

function XUiDrawActivityShow:SetWeaponPos(target, config)
    if not target or not config then
        return
    end
    target.transform.localPosition = CS.UnityEngine.Vector3(config.PositionX, config.PositionY, config.PositionZ)
    --检查数据 模型旋转
    target.transform.localEulerAngles = CS.UnityEngine.Vector3(config.RotationX, config.RotationY, config.RotationZ)
    --检查数据 模型大小
    target.transform.localScale = CS.UnityEngine.Vector3(
    config.ScaleX == 0 and 1 or config.ScaleX,
    config.ScaleY == 0 and 1 or config.ScaleY,
    config.ScaleZ == 0 and 1 or config.ScaleZ
    )
end
--windEnd
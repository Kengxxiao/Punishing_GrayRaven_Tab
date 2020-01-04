local XUiFunitureDetail = XLuaUiManager.Register(XLuaUi, "UiFurnitureDetail")
local attrRed = XFurnitureConfigs.AttrType.AttrA
local attrYellow = XFurnitureConfigs.AttrType.AttrB
local attrBule = XFurnitureConfigs.AttrType.AttrC

function XUiFunitureDetail:OnAwake()
    self:AddListener()
end

function XUiFunitureDetail:OnEnable()
    XEventManager.AddEventListener(XEventId.EVENT_DORM_CLOSE_DETAIL, self.OnBtnCloseClick, self)
end

function XUiFunitureDetail:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_CLOSE_DETAIL, self.OnBtnCloseClick, self)
end

function XUiFunitureDetail:OnStart(furnitureId, furnitureConfigId, furnitureRewardId, recycleCallBack, isCloseRecycle)
    self.FurnitureId = furnitureId
    self.FurnitureConfigId = furnitureConfigId
    self.FurnitureRewardId = furnitureRewardId
    self.RecycleCallBack = recycleCallBack

    -- 是否显示回收按钮
    if isCloseRecycle ~= nil and isCloseRecycle then
        self.BtnRecovery.gameObject:SetActive(false)
    end

    self:InitConfigInfo()

    if self.FurnitureId then
        self:InitOwerInfoByObjectId()
    else
        self:InitOwerInfoByConfigId()
    end
end

function XUiFunitureDetail:AddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnBg, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnSuitInfo, self.OnBtnSuitInfoClick)
    self:RegisterClickEvent(self.BtnRecovery, self.OnBtnRecoveryClick)
end

function XUiFunitureDetail:OnBtnCloseClick(...)
    self:Close()
end

function XUiFunitureDetail:OnBtnSuitInfoClick(...)
    local tp = XFurnitureConfigs.GetFurnitureTemplateById(self.FurnitureConfigId)
    XLuaUiManager.Open("UiDormFieldGuide", tp.SuitId)
    self:Close()
end

-- 确认回收
function XUiFunitureDetail:OnBtnRecoveryClick(...)
    local funitureRecycleList = { self.FurnitureId }

    -- 屏蔽使用中的家具
    for i = 1, #funitureRecycleList do
        local isUseing = XDataCenter.FurnitureManager.CheckFurnitureUsing(funitureRecycleList[i])
        if isUseing then
            XUiManager.TipText("DormFurnitureRecycelUsingTip")
            return
        end
    end

    XLuaUiManager.Open("UiFurnitureRecycleObtain", funitureRecycleList, function()
        XDataCenter.FurnitureManager.DecomposeFurniture(funitureRecycleList, function(rewardItems, successIds)
            -- 打开回收界面
            XLuaUiManager.Open("UiDormBagRecycle", successIds, rewardItems)

            -- 将分解成功的家具从缓存中移除
            for _, id in ipairs(successIds) do
                XDataCenter.FurnitureManager.RemoveFurniture(id)
            end

            -- 回收回调
            if self.RecycleCallBack then
                self.RecycleCallBack()
            end
        end)
    end)
end

function XUiFunitureDetail:InitConfigInfo()
    local furnitureConfig = XFurnitureConfigs.GetFurnitureTemplateById(self.FurnitureConfigId)
    local furnitureTypConfig = XFurnitureConfigs.GetFurnitureTypeById(furnitureConfig.TypeId)
    self.TxtName.text = CS.XTextManager.GetText("DormFurnitureName", furnitureConfig.Name, furnitureTypConfig.MinorName, furnitureTypConfig.CategoryName)
    self.TxtScore.text = "???"
    self.TxtFurnitureDesc.text = furnitureConfig.Desc
    local furnitureIcon = furnitureConfig.Icon
    if self.FurnitureId then
        furnitureIcon = XDataCenter.FurnitureManager.GetFurnitureIconById(self.FurnitureId, XDormConfig.DormDataType.Self)
    end
    self.RImgIcon:SetRawImage(furnitureIcon, nil, true)

    -- 套装
    local tp = XFurnitureConfigs.GetFurnitureTemplateById(self.FurnitureConfigId)
    self.BtnSuitInfo.gameObject:SetActive(tp.SuitId ~= nil and tp.SuitId > 0)

    local suitInfo = nil

    if tp.SuitId > 0 then
        suitInfo = XFurnitureConfigs.GetFurnitureSuitTemplatesById(tp.SuitId)
    end

    if tp.SuitId > 0 and suitInfo then
        self.TxtSuitName.text = suitInfo.SuitName
    else
        self.TxtSuitName.text = CS.XTextManager.GetText("DormFurnitureNotSuit")
    end

    -- 家具属性
    self.TxtRedScore.text = "??"
    self.TxtYellowScore.text = "??"
    self.TxtBlueScore.text = "??"

    -- 特殊效果
    self.TxtEffectDesc.text = "???"
    self.TxtEffectScore.gameObject:SetActive(false)
end

function XUiFunitureDetail:InitOwerInfoByObjectId()
    -- 记入已经查看过 new 标签
    -- local ids = {}
    -- table.insert(ids, self.FurnitureId)
    -- XDataCenter.FurnitureManager.AddNewHint(ids)
    local redTypeName = XFurnitureConfigs.GetDormFurnitureTypeName(attrRed)
    local yoellowTypeName = XFurnitureConfigs.GetDormFurnitureTypeName(attrYellow)
    local blueTypeName = XFurnitureConfigs.GetDormFurnitureTypeName(attrBule)

    local redTypeIcon = XFurnitureConfigs.GetDormFurnitureTypeIcon(attrRed)
    local yoellowTypeIcon = XFurnitureConfigs.GetDormFurnitureTypeIcon(attrYellow)
    local blueTypeIcon = XFurnitureConfigs.GetDormFurnitureTypeIcon(attrBule)

    self:SetUiSprite(self.ImgRed, redTypeIcon)
    self:SetUiSprite(self.ImgYellow, yoellowTypeIcon)
    self:SetUiSprite(self.ImgBlue, blueTypeIcon)

    local redScore = XDataCenter.FurnitureManager.GetFurnitureRedScore(self.FurnitureId)
    local yellowScore = XDataCenter.FurnitureManager.GetFurnitureYellowScore(self.FurnitureId)
    local blueScore = XDataCenter.FurnitureManager.GetFurnitureBlueScore(self.FurnitureId)

    local furnitureType = XDataCenter.FurnitureManager.GetFurnitureConfigByUniqueId(self.FurnitureId).TypeId
    local totalScore = XDataCenter.FurnitureManager.GetFurnitureScore(self.FurnitureId)
    local totalDesc = XFurnitureConfigs.GetFurnitureTotalAttrLevelDescription(furnitureType, totalScore)

    local redScoreDesc = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrRed, redScore)
    local yellowScoreDesc = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrYellow, yellowScore)
    local blueScoreDesc = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrBule, blueScore)

    self.TxtRedScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", redTypeName, redScoreDesc)
    self.TxtYellowScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", yoellowTypeName, yellowScoreDesc)
    self.TxtBlueScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", blueTypeName, blueScoreDesc)
    self.TxtScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", CS.XTextManager.GetText("DormTotalScore"), totalDesc)

    local additionId = XDataCenter.FurnitureManager.GetFurnitureById(self.FurnitureId).Addition
    local additionSocreDesc = ""
    if additionId > 0 then
        self.TxtEffectScore.gameObject:SetActive(true)
        additionSocreDesc = XFurnitureConfigs.GetAdditionalRandomEntry(additionId, true)
    end
    self.TxtEffectDesc.text = XDataCenter.FurnitureManager.GetFurnitureEffectDesc(self.FurnitureId)
    self.TxtEffectScore.text = additionSocreDesc

    local tp = XFurnitureConfigs.GetFurnitureTemplateById(self.FurnitureConfigId)
    self.TxtSuitEffectDesc.gameObject:SetActiveEx(false)

    if tp.SuitId > 0 then
        local suitBgmInfo = XDormConfig.GetDormSuitBgmInfo(tp.SuitId)
        if suitBgmInfo then
            self.TxtSuitEffectDesc.gameObject:SetActiveEx(true)
            self.TxtSuitEffectDesc.text = string.format(CS.XGame.ClientConfig:GetString("DormSuitBgmDesc"), suitBgmInfo.SuitNum, "\n", suitBgmInfo.Name)
            self.TxtSuit.text = CS.XGame.ClientConfig:GetString("DormSuitBgmTitleDesc")
        end
    end
end

function XUiFunitureDetail:InitOwerInfoByConfigId()
    local template = XFurnitureConfigs.GetFurnitureReward(self.FurnitureRewardId)
    if not template then
        return
    end

    local redScore, yellowScore, blueScore = XDataCenter.FurnitureManager.GetRewardFurnitureAttr(template.ExtraAttrId)
    if not redScore or not yellowScore or not blueScore then
        return
    end

    local redTypeName = XFurnitureConfigs.GetDormFurnitureTypeName(attrRed)
    local yoellowTypeName = XFurnitureConfigs.GetDormFurnitureTypeName(attrYellow)
    local blueTypeName = XFurnitureConfigs.GetDormFurnitureTypeName(attrBule)

    local redTypeIcon = XFurnitureConfigs.GetDormFurnitureTypeIcon(attrRed)
    local yoellowTypeIcon = XFurnitureConfigs.GetDormFurnitureTypeIcon(attrYellow)
    local blueTypeIcon = XFurnitureConfigs.GetDormFurnitureTypeIcon(attrBule)

    self:SetUiSprite(self.ImgRed, redTypeIcon)
    self:SetUiSprite(self.ImgYellow, yoellowTypeIcon)
    self:SetUiSprite(self.ImgBlue, blueTypeIcon)

    local furnitureType = XFurnitureConfigs.GetFurnitureTemplateById(self.FurnitureConfigId).TypeId
    local totalScore = XDataCenter.FurnitureManager.GetRewardFurnitureScore(self.FurnitureRewardId)
    local totalDesc = XFurnitureConfigs.GetFurnitureTotalAttrLevelDescription(furnitureType, totalScore)

    local redScoreDesc = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrRed, redScore)
    local yellowScoreDesc = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrYellow, yellowScore)
    local blueScoreDesc = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrBule, blueScore)


    self.TxtRedScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", redTypeName, redScoreDesc)
    self.TxtYellowScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", yoellowTypeName, yellowScoreDesc)
    self.TxtBlueScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", blueTypeName, blueScoreDesc)
    self.TxtBlueScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", blueTypeName, blueScoreDesc)
    self.TxtScore.text = CS.XTextManager.GetText("DormFurnitureScoreDesc", CS.XTextManager.GetText("DormTotalScore"), totalDesc)

    local additionId = XDataCenter.FurnitureManager.GetRewardFurnitureEffectId(self.FurnitureRewardId)
    local additionSocreDesc = ""
    if additionId and additionId > 0 then
        self.TxtEffectScore.gameObject:SetActive(true)
        additionSocreDesc = XFurnitureConfigs.GetAdditionalRandomEntry(additionId, true)
    end

    self.TxtEffectDesc.text = XFurnitureConfigs.GetAdditionalRandomIntroduce(additionId)
    self.TxtEffectScore.text = additionSocreDesc
end
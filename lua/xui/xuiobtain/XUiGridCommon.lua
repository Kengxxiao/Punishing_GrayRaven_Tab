local type = type

XUiGridCommon = Class("XUiGridCommon")

function XUiGridCommon:Ctor(rootUi, ui)
    if not ui then
        ui = rootUi
    else
        self.RootUi = rootUi
    end

    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.TextCount = XUiHelper.TryGetComponent(self.Transform, "TextCount", nil)
end

function XUiGridCommon:Init(rootUi)
    self.RootUi = rootUi
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridCommon:InitAutoScript()
    self:AutoInitUi()
    XTool.InitUiObject(self)
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridCommon:AutoInitUi()
    self.TxtCount = XUiHelper.TryGetComponent(self.Transform, "TxtCount", "Text")
    self.TxtName = XUiHelper.TryGetComponent(self.Transform, "TxtName", "Text")
    self.ImgNew = XUiHelper.TryGetComponent(self.Transform, "ImgNew", "Image")
    self.RImgIcon = XUiHelper.TryGetComponent(self.Transform, "RImgIcon", "RawImage")
    self.HeadIconEffect = XUiHelper.TryGetComponent(self.Transform, "RImgIcon/Effect", "XUiEffectLayer")
    self.ImgQuality = XUiHelper.TryGetComponent(self.Transform, "ImgQuality", "Image")
    self.PanelSite = XUiHelper.TryGetComponent(self.Transform, "PanelSite", nil)
    self.TxtSite = XUiHelper.TryGetComponent(self.Transform, "PanelSite/TxtSite", "Text")
    self.BtnClick = XUiHelper.TryGetComponent(self.Transform, "BtnClick", "Button")
    self.ImgUp = XUiHelper.TryGetComponent(self.Transform, "ImgUp", "Image")
    self.ImgRail = XUiHelper.TryGetComponent(self.Transform, "ImgRail", "Image")
    self.ImgReceived = XUiHelper.TryGetComponent(self.Transform, "ImgReceived", "Image")
    self.ImgQualityTag = XUiHelper.TryGetComponent(self.Transform, "ImgQualityTag", "Image")
    self.TxtStock = XUiHelper.TryGetComponent(self.Transform, "TxtStock", "Text")
    self.ImgNone = XUiHelper.TryGetComponent(self.Transform, "ImgNone", nil)
end

function XUiGridCommon:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridCommon:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridCommon:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridCommon:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnClick, self.OnBtnClickClick)
end
-- auto
function XUiGridCommon:OnBtnClickClick(...)
    if self.Disable then
        return
    end

    if self.GoodsShowParams.RewardType == XRewardManager.XRewardType.Character then
        --从Tips的ui跳转需要关闭Tips的UI
        if self.RootUi.Ui.UiData.UiType == CsXUiType.Tips then
            self.RootUi:Close()
        end

        -- 暂停自动弹窗
        XDataCenter.AutoWindowManager.StopAutoWindow()
        XLuaUiManager.Open("UiCharacterDetail", self.TemplateId)
    elseif self.GoodsShowParams.RewardType == XRewardManager.XRewardType.Equip then
        XLuaUiManager.Open("UiEquipDetail", self.TemplateId, true)
        --从Tips的ui跳转需要关闭Tips的UI
        if self.RootUi.Ui.UiData.UiType == CsXUiType.Tips then
            self.RootUi:Close()
        end

         -- 暂停自动弹窗
         XDataCenter.AutoWindowManager.StopAutoWindow()
    elseif self.GoodsShowParams.RewardType == XRewardManager.XRewardType.Furniture then
        local cfg = XFurnitureConfigs.GetFurnitureReward(self.TemplateId)
        local furnitureRewardId = self.TemplateId
        local configId = cfg.FurnitureId
        XLuaUiManager.Open("UiFurnitureDetail", self.Data.InstanceId, configId, furnitureRewardId, nil, true)
    else
        XLuaUiManager.Open("UiTip", self.Data and self.Data or self.TemplateId, self.HideSkipBtn)
    end
end

function XUiGridCommon:SetUiActive(ui, active)
    if not ui or not ui.gameObject then
        return
    end

    if ui.gameObject.activeSelf == active then
        return
    end

    ui.gameObject:SetActive(active)
end

function XUiGridCommon:ResetUi()
    self:SetUiActive(self.TxtCount, false)
    self:SetUiActive(self.TxtName, false)
    self:SetUiActive(self.ImgNew, false)
    self:SetUiActive(self.RImgIcon, false)
    self:SetUiActive(self.ImgQuality, false)
    self:SetUiActive(self.PanelSite, false)
    self:SetUiActive(self.ImgUp, false)
    self:SetUiActive(self.ImgRail, false)
    self:SetUiActive(self.ImgReceived, false)
    self:SetUiActive(self.ImgQualityTag, false)
end

-- data支持数据结构： XEquipData XItemData XCharacterData
-- tags可包含: { ShowUp, ShowNew }
function XUiGridCommon:Refresh(data, params, isBigIcon, hideSkipBtn,curCount)
    self.GameObject:SetActive(data)
    if not data then
        return
    end

    self:ResetUi()

    self.HideSkipBtn = hideSkipBtn

    local count, star

    if type(data) == "number" then
        self.TemplateId = data
    else
        self.Data = data
        self.TemplateId = (data.TemplateId and data.TemplateId > 0) and data.TemplateId or data.Id
        count = self.Data.Count
        star = self.Data.Star
    end

    self.GoodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId)

    params = params or {}

    -- 名字
    if self.TxtName and self.GoodsShowParams.Name then
        if self.GoodsShowParams.RewardType == XArrangeConfigs.Types.Character then
            self.TxtName.text = self.GoodsShowParams.TradeName
        else
            self.TxtName.text = self.GoodsShowParams.Name 
        end

        self:SetUiActive(self.TxtName, true)
    end

    -- 数量
    if self.TxtCount and count then
        self.TxtCount.text = CS.XTextManager.GetText("ShopGridCommonCount", count)
        self:SetUiActive(self.TxtCount, true)
    end

    -- 图标
    if self.RImgIcon then
        local icon = self.GoodsShowParams.Icon
        if isBigIcon and self.GoodsShowParams.BigIcon then
            icon = self.GoodsShowParams.BigIcon
        end

        if icon and #icon > 0 then
            --self.RootUi:SetUiSprite(self.RImgIcon, icon)
            self.RImgIcon:SetRawImage(icon)
            self:SetUiActive(self.RImgIcon, true)
        end
    end

    -- 特效
    if self.HeadIconEffect then
        local effect = self.GoodsShowParams.Effect
        if effect then
            self.HeadIconEffect.gameObject:LoadPrefab(effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    
    -- 品质底图
    if self.ImgQuality and self.GoodsShowParams.Quality then
        local qualityIcon = self.GoodsShowParams.QualityIcon

        if qualityIcon then
            self.RootUi:SetUiSprite(self.ImgQuality, qualityIcon)
        else
            XUiHelper.SetQualityIcon(self.RootUi, self.ImgQuality, self.GoodsShowParams.Quality)
        end

        self:SetUiActive(self.ImgQuality, true)
    end

    -- 品质底图（大）
    if self.ImgIconQuality and self.GoodsShowParams.Quality then
        XUiHelper.SetQualityIcon(self.RootUi, self.ImgIconQuality, self.GoodsShowParams.Quality)
        self:SetUiActive(self.ImgQuality, true)
    end

    -- 创世纪标签
    if self.ImgQualityTag and self.GoodsShowParams.QualityTag then
        self:SetUiActive(self.ImgQualityTag, true)
    end

    if self.GoodsShowParams.RewardType == XRewardManager.XRewardType.Equip then
        -- 星数
        if self.PanelStars then
            self:ShowStar(self.GoodsShowParams.Star, self.GoodsShowParams.Star)
        end
        -- 
        if self.PanelSite then
            self:SetUiActive(self.PanelSite, self.GoodsShowParams.Site ~= XEquipConfig.EquipSite.Weapon)
            self.TxtSite.text = "0" .. self.GoodsShowParams.Site
        end
    end

    -- 特殊 : Params
    -- Params.ShowUp
    if self.ImgUp then
        self:SetUiActive(self.ImgUp, params.ShowUp)
    end

    -- Params.ShowNew
    if self.ImgNew then
        self:SetUiActive(self.ImgNew, params.ShowNew)
    end

    -- Params.ShowReceived 已领取
    if self.ImgReceived then
        self:SetUiActive(self.ImgReceived, params.ShowReceived)
    end

    -- Params.Disable 不可点击
    self.Disable = params.Disable
    
    --特殊抽奖中奖品的剩余数
    if self.TxtStock and curCount then
        self.TxtStock.text = CS.XTextManager.GetText("ResidueStockText", curCount)
        self:SetUiActive(self.TxtName, false) 
    end
    
    --特殊抽奖中是否有库存的提示
    if self.ImgNone and curCount then
        self.ImgNone.gameObject:SetActive(curCount <= 0) 
    end
end

function XUiGridCommon:ShowCount(show)
    if (self.TxtCount) then
        self.TxtCount.gameObject:SetActive(show)
    end
    if self.TextCount then
        self.TextCount.gameObject:SetActive(show)
    end
end

function XUiGridCommon:ShowStar(count, max)
    local showStar = max > 0
    self.PanelStars.gameObject:SetActive(showStar)

    if not showStar then
        return
    end

    for i = 1, 6 do
        local starPanel = self["PanelStar" .. i]
        if starPanel then
            starPanel.gameObject:SetActive(i <= max)
        end

        local imgStar = self["ImgStar" .. i]
        if imgStar then
            imgStar.gameObject:SetActive(i <= count)
        end
    end
end

function XUiGridCommon:SetReceived(isReceive)
    if self.ImgReceived then
        self:SetUiActive(self.ImgReceived, isReceive)
    end
end

function XUiGridCommon:SetShowUp(isShow)
    if self.ImgUp then
        self:SetUiActive(self.ImgUp, isShow)
    end
end

function XUiGridCommon:SetClickCallback(callback)
    self.Callback = callback
end

function XUiGridCommon:GetQuality()
    return self.GoodsShowParams.Quality
end

return XUiGridCommon
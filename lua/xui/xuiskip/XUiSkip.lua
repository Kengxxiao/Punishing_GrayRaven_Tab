local XUiSkip = XLuaUiManager.Register(XLuaUi, "UiSkip")

function XUiSkip:OnAwake()
    self:InitAutoScript()
end

function XUiSkip:OnStart(templateId, skipCb, hideSkipBtn)
    self.SkipCb = skipCb
    self.HideSkipBtn = hideSkipBtn
    self.GridPool = {}
    local musicKey = self:GetAutoKey(self.BtnBack, "onClick")
    self.SpecialSoundMap[musicKey] = XSoundManager.UiBasicsMusic.Return
    self:Refresh(templateId)
    XUiHelper.PlayAnimation(self, "AniSkip")
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiSkip:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiSkip:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiSkip:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiSkip:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiSkip:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
end
-- auto
function XUiSkip:OnBtnBackClick(...)
    self:Close()
end

function XUiSkip:Refresh(templateId)
    self.GameObject:SetActive(templateId)

    if not templateId then
        return
    end

    local skipIdList = XGoodsCommonManager.GetGoodsSkipIdParams(templateId)
    if not skipIdList or #skipIdList <= 0 then
        self.GameObject:SetActive(false)
        return
    end

    local goodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(templateId)
    local icon = goodsShowParams.Icon
    if goodsShowParams.BigIcon then
        icon = goodsShowParams.BigIcon
    end

    self.RImgIcon:SetRawImage(icon)
    self.TxtIconName.text = goodsShowParams.Name
    self.TxtIconNum.text = XGoodsCommonManager.GetGoodsCurrentCount(templateId)

    if goodsShowParams.RewardType == XRewardManager.XRewardType.Equip then
        local equipSite = XDataCenter.EquipManager.GetEquipSiteByTemplateId(templateId)
        if equipSite and equipSite ~= XEquipConfig.EquipSite.Weapon then
            self.TxtSite.text = equipSite
            self.PanelSite.gameObject:SetActive(true)
        else
            self.PanelSite.gameObject:SetActive(false)
        end
    else
        self.PanelSite.gameObject:SetActive(false)
    end

    self.PanelGridSkip.gameObject:SetActive(false)
    local onCreate = function(grid, data)
        grid:Refresh(data, self.HideSkipBtn, function()
            self:Close()
            -- 暂停自动弹窗
            XDataCenter.AutoWindowManager.StopAutoWindow()
            if self.SkipCb then self.SkipCb() end
        end)
    end

    XUiHelper.CreateTemplates(self, self.GridPool, skipIdList, XUiGridSkip.New, self.PanelGridSkip, self.PanelContent, onCreate)
end
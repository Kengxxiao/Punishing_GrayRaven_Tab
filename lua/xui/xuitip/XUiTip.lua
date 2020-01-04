local type = type

local XUiTip = XLuaUiManager.Register(XLuaUi, "UiTip")

function XUiTip:OnAwake()
    self:InitAutoScript()
end

function XUiTip:OnStart(data, hideSkipBtn)
    local musicKey = self:GetAutoKey(self.BtnBack, "onClick")
    self.SpecialSoundMap[musicKey] = XSoundManager.UiBasicsMusic.Return
    self.HideSkipBtn = hideSkipBtn
    self.Data = data
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Tip_Big)
end

function XUiTip:OnEnable()
    self:Refresh(self.Data)
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiTip:InitAutoScript()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiTip:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiTip:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiTip:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiTip:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnGet, "onClick", self.OnBtnGetClick)
    self:RegisterListener(self.BtnOk, "onClick", self.OnBtnOkClick)
end
-- auto
function XUiTip:OnBtnBackClick(...)
    self:Close()
end

function XUiTip:OnBtnGetClick(...)
    XLuaUiManager.Open("UiSkip", self.TemplateId, function()
        self:Close()
    end, self.HideSkipBtn)
end

function XUiTip:OnBtnOkClick(...)
    self:Close()
end

function XUiTip:SetUiActive(ui, active)
    if not ui or not ui.gameObject then
        return
    end

    if ui.gameObject.activeSelf == active then
        return
    end

    ui.gameObject:SetActive(active)
end

function XUiTip:ResetUi()
    self:SetUiActive(self.TxtCount, false)
    self:SetUiActive(self.TxtName, false)
    self:SetUiActive(self.ImgQuality, false)
    self:SetUiActive(self.TxtWorldDesc, false)
    self:SetUiActive(self.TxtDescription, false)
    self:SetUiActive(self.BtnGet, false)
end

-- data 可以是 XItemData / XEquipData / XCharacterData / XFashionData
function XUiTip:Refresh(data)
    self.Data = data
    if not data then
        XLog.Error("XUiTip:Refresh error : data is nil.")
        return
    end

    self:ResetUi()

    if type(data) == "number" then
        self.TemplateId = data
    else
        self.TemplateId = data.TemplateId and data.TemplateId or data.Id
    end

    if self.TemplateId == XDataCenter.ItemManager.ItemId.AndroidHongKa or 
        self.TemplateId == XDataCenter.ItemManager.ItemId.IosHongKa then
        self.TemplateId = XDataCenter.ItemManager.ItemId.HongKa
    end
    
    local goodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId)

    -- 获取途径按钮
    local skipIdParams = XGoodsCommonManager.GetGoodsSkipIdParams(self.TemplateId)
    if skipIdParams and #skipIdParams > 0 then
        self:SetUiActive(self.BtnGet, true)
    end

    -- 名称
    if self.TxtName and goodsShowParams.Name then
        self.TxtName.text = goodsShowParams.Name
        self:SetUiActive(self.TxtName, true)
    end

    -- 数量
    if self.TxtCount then
        local count = XGoodsCommonManager.GetGoodsCurrentCount(self.TemplateId)
        self.TxtCount.text = count
        self:SetUiActive(self.TxtCount, true)
    end

    -- 图标
    if self.RImgIcon and self.RImgIcon:Exist() then
        local icon = goodsShowParams.Icon

        if goodsShowParams.BigIcon then
            icon = goodsShowParams.BigIcon
        end

        if icon and #icon > 0 then
            self.RImgIcon:SetRawImage(icon)
            self:SetUiActive(self.RImgIcon, true)
        end
    end

    -- 特效
    if self.HeadIconEffect then
        local effect = goodsShowParams.Effect
        if effect then
            self.HeadIconEffect.gameObject:LoadPrefab(effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    
    -- 品质底图
    if self.ImgQuality and goodsShowParams.Quality then
        XUiHelper.SetQualityIcon(self, self.ImgQuality, goodsShowParams.Quality)
        self:SetUiActive(self.ImgQuality, true)
    end

    -- 世界观描述
    if self.TxtWorldDesc then
        local worldDesc = XGoodsCommonManager.GetGoodsWorldDesc(self.TemplateId)
        if worldDesc and #worldDesc then
            self.TxtWorldDesc.text = worldDesc
            self:SetUiActive(self.TxtWorldDesc, true)
        end
    end

    -- 描述
    if self.TxtDescription then
        local desc = XGoodsCommonManager.GetGoodsDescription(self.TemplateId)
        if desc and #desc > 0 then
            self.TxtDescription.text = desc
            self:SetUiActive(self.TxtDescription, true)
        end
    end
end
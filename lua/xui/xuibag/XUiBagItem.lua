XUiBagItem = XClass()

-- 初始化
function XUiBagItem:Ctor(rootUi, ui, openCloseCb, clickCb)
    self.RootUi = rootUi
    self.CallBack = openCloseCb
    self.ClickCallback = clickCb
    self.IsShowBtnMinusWhenMinSelectCount = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitUi()
    self:AddListener()
    if self.WgtBtn then
        self.WidgetBtnLongClick = XUiButtonLongClick.New(self.WgtBtn, 100, self, nil, self.BtnLongClickCallback, nil, true)
    end
    if self.WgtBtnMinusSelect then
        self.WidgetBtnMinusLongClick = XUiButtonLongClick.New(self.WgtBtnMinusSelect, 100, self, nil, self.BtnMinusSelectLongClickCallback, nil, true)
    end
    if self.WgtBtnAddSelect then
        self.WidgetBtnMinusLongClick = XUiButtonLongClick.New(self.WgtBtnAddSelect, 100, self, nil, self.BtnAddSelectLongClickCallback, nil, true)
    end
    self.DefaultMinSelectCount = 0
    self.SelectCount = 0
end

function XUiBagItem:InitUi()
    -- 基础信息 -----------------------------------------------------------------------------
    -- 图标
    self.RImgIcon        = XUiHelper.TryGetComponent(self.Transform, "RImgIcon",        "RawImage")
    -- 图标背景图
    self.ImgIconBg        = XUiHelper.TryGetComponent(self.Transform, "ImgIconBg",        "Image")
    -- 图标品质底图
    self.ImgIconQuality = XUiHelper.TryGetComponent(self.Transform, "ImgIconQuality", "Image")
    -- 物品数量
    self.TxtCount        = XUiHelper.TryGetComponent(self.Transform, "TxtCount",        "Text")
    -- 物品名字
    self.TxtName        = XUiHelper.TryGetComponent(self.Transform, "TxtName",        "Text")
    -- 物品描述
    self.TxtDescription = XUiHelper.TryGetComponent(self.Transform, "TxtDescription", "Text")
    -- 物品经验是否加倍
    self.TxtEx            = XUiHelper.TryGetComponent(self.Transform, "TxtEx",            "Text")
    -- 世界观描述
    self.TxtWorldDesc    = XUiHelper.TryGetComponent(self.Transform, "TxtWorldDesc",    "Text")

    -- 自定义回调 -----------------------------------------------------------------------------
    -- 自定义回调Button
    self.Btn            = XUiHelper.TryGetComponent(self.Transform, "Btn",            "Button")
    -- 自定义回调Button2
    self.Btn2            = XUiHelper.TryGetComponent(self.Transform, "Btn2",            "Button")
    -- 自定义Widget
    self.WgtBtn        = XUiHelper.TryGetComponent(self.Transform, "Btn",            "XUiPointer")

    -- 选择相关 -----------------------------------------------------------------------------
    -- 选中Image
    self.ImgSelect        = XUiHelper.TryGetComponent(self.Transform, "ImgSelect",        "Image")
    -- 选中Image背景
    self.ImgSelectBg        = XUiHelper.TryGetComponent(self.Transform, "ImgSelectBg",    "Image")
    -- 选择数量
    self.TxtSelect        = XUiHelper.TryGetComponent(self.Transform, "TxtSelect",        "Text")
    -- 选择数量     为0自动隐藏
    self.TxtSelectHide    = XUiHelper.TryGetComponent(self.Transform, "TxtSelectHide",    "Text")
    -- 需要数量     例如升级部件 16/100，其中100为需要数量
    self.TxtNeedCount    = XUiHelper.TryGetComponent(self.Transform, "TxtNeedCount",    "Text")
    -- 现有数量     例如升级部件 16/100，其中16为需现有数量
    self.TxtHaveCount    = XUiHelper.TryGetComponent(self.Transform, "TxtHaveCount",    "Text")
    -- 减少选择按钮
    self.BtnMinusSelect    = XUiHelper.TryGetComponent(self.Transform, "BtnMinusSelect", "Button")
    -- 减少选择长按组件
    self.WgtBtnMinusSelect = XUiHelper.TryGetComponent(self.Transform, "BtnMinusSelect", "XUiPointer")
    -- 增加选择按钮
    self.BtnAddSelect    = XUiHelper.TryGetComponent(self.Transform, "BtnAddSelect",    "Button")
    -- 增加选择长按组件
    self.WgtBtnAddSelect    = XUiHelper.TryGetComponent(self.Transform, "BtnAddSelect",    "XUiPointer")
    -- 全选按钮
    self.BtnMax            = XUiHelper.TryGetComponent(self.Transform, "BtnMax",        "Button")

    -- 操作按钮 -----------------------------------------------------------------------------
    -- 确定按钮 隐藏Item
    self.BtnOk            = XUiHelper.TryGetComponent(self.Transform, "BtnOk",            "Button")
    -- 使用按钮
    self.BtnUse            = XUiHelper.TryGetComponent(self.Transform, "BtnUse",        "Button")
    -- 出售按钮
    self.BtnSell            = XUiHelper.TryGetComponent(self.Transform, "BtnSell",        "Button")
    -- 关闭按钮
    self.BtnClose        = XUiHelper.TryGetComponent(self.Transform, "BtnClose",        "Button")
    -- 获取按钮
    self.BtnGet            = XUiHelper.TryGetComponent(self.Transform, "BtnGet",        "Button")
    -- 阻挡按钮 防穿透
    self.BtnBlock        = XUiHelper.TryGetComponent(self.Transform, "BtnBlock",        "Button")
    -- Tips 显示
    self.BtnItemTip        = XUiHelper.TryGetComponent(self.Transform, "BtnItemTip",    "Button")

    -- 状态相关 -----------------------------------------------------------------------------
    -- 状态图片
    self.ImgState        = XUiHelper.TryGetComponent(self.Transform, "ImgState",        "Image")
    self.TxtState        = XUiHelper.TryGetComponent(self.Transform, "ImgState/TxtState", "Text")
    -- 可使用
    self.ImgCanUse        = XUiHelper.TryGetComponent(self.Transform, "ImgCanUse",        "Image")
    -- 物品使用等级
    self.TxtUseLevel        = XUiHelper.TryGetComponent(self.Transform, "TxtUseLevel",    "Text")
    -- 当前格子数量，根据Refresh时传入的GridIndex算
    self.TxtGridCount    = XUiHelper.TryGetComponent(self.Transform, "TxtGridCount",    "Text")
end

function XUiBagItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiBagItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelBagItemCommon:RegisterListener: func is not a function")
        end

        listener = function()
            func(self)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiBagItem:AddListener()
    self.AutoCreateListeners = {}

    if self.Btn then
        self:RegisterListener(self.Btn, "onClick", self.OnBtnClick)
    end

    if self.Btn2 then
        self:RegisterListener(self.Btn2, "onClick", self.OnBtn2Click)
    end

    if self.BtnOk then
        self:RegisterListener(self.BtnOk, "onClick", self.Hide)
    end

    if self.BtnSell then
        self:RegisterListener(self.BtnSell, "onClick", self.OnBtnSellClick)
    end

    if self.BtnClose then
        self:RegisterListener(self.BtnClose, "onClick", self.Hide)
    end

    if self.BtnGet then
        self:RegisterListener(self.BtnGet, "onClick", self.OnBtnGetClick)
    end

    if self.BtnBlock then
        self:RegisterListener(self.BtnBlock, "onClick", self.Hide)
    end

    if self.BtnMinusSelect then
        self:RegisterListener(self.BtnMinusSelect, "onClick", self.MinusSelectCount)

    end

    if self.BtnAddSelect then
        self:RegisterListener(self.BtnAddSelect, "onClick", self.AddSelectCount)
    end

    if self.BtnMax then
        self:RegisterListener(self.BtnMax, "onClick", self.SelectAll)
    end

    if self.BtnUse then
        self:RegisterListener(self.BtnUse, "onClick", self.OnBtnUseClick)
    end

    if self.BtnItemTip then
        self:RegisterListener(self.BtnItemTip, "onClick", self.OnBtnItemTipClick)
    end
end

-- 操作回调 
function XUiBagItem:OnBtnItemTipClick()
    if self.BtnItemTip then
        XLuaUiManager.Open("UiTip", { TemplateId = self.TemplateId, Count = self.Data.Count })
    end
end

function XUiBagItem:OnBtnClick()
    if self.ClickCallback then
        self.ClickCallback({ Data = self.Data, GridIndex = self.GridIndex, RecycleBatch = self.RecycleBatch }, self)
    end
    --CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiBag_Chip_Click)
end

function XUiBagItem:OnBtnUseClick()
    if self.SelectCount <= 0 then
        return
    end
    local closeCallback = function()
        self:RefreshSelf()
    end
    local callback = function(rewardGoodsList)
        if self.UseRefreshCallback then
            self.UseRefreshCallback()
        end
        XUiManager.OpenUiObtain(rewardGoodsList, CS.XTextManager.GetText("CongratulationsToObtain"), closeCallback, nil)
    end
    XDataCenter.ItemManager.Use(self.Data.Id, self.RecycleBatch and self.RecycleBatch.RecycleTime, self.SelectCount, callback)
    if self.CallBack then
        self.CallBack(false)
    end
    self.GameObject:SetActive(false)
end

function XUiBagItem:OnBtn2Click()
    if self.ClickCallback2 then
        self.ClickCallback2()
    end
end

function XUiBagItem:Hide()
    if self.CallBack then
        self.CallBack(false)
    end

    self.GameObject:SetActive(false)
end

function XUiBagItem:OnBtnSellClick()
    print("XUiBagItem:OnBtnSellClick")
end
function XUiBagItem:OnBtnGetClick()
    XLuaUiManager.Open("UiSkip", self.Template.Id)
end

function XUiBagItem:BtnLongClickCallback(time)
    local maxCount = self:GetGridCount()
    if maxCount and self.SelectCount >= maxCount then
        return
    end

    local delta = math.max(0, math.floor(time / 300))
    local count = self.SelectCount + delta
    if maxCount and count >= maxCount then
        count = maxCount
    end

    self:UpdateSelectCount(count)
end

function XUiBagItem:BtnMinusSelectLongClickCallback(time)
    if self.SelectCount == 0 then
        return
    end

    local delta = math.max(0, math.floor(time / 150))
    local count = self.SelectCount - delta
    if count <= 0 then
        count = 0
    end
    self:UpdateSelectCount(count)
end

function XUiBagItem:BtnAddSelectLongClickCallback(time)
    local maxCount = self:GetGridCount()
    if maxCount and self.SelectCount >= maxCount then
        return
    end    local delta = math.max(0, math.floor(time / 150))
    local count = self.SelectCount + delta
    if maxCount and count >= maxCount then
        count = maxCount
    end

    self:UpdateSelectCount(count)
end

-- 选择操作接口
function XUiBagItem:UpdateSelectCount(count)
    local newCount = math.max(count, self.DefaultMinSelectCount)
    newCount = math.min(newCount, self.Data.GridCount or self.Data.Count)
    if self.SelectCountChangeCondition and not self.SelectCountChangeCondition(newCount) then
        return
    end

    if newCount == self.SelectCount then
        return
    end

    self:SetSelectCount(newCount)
end

function XUiBagItem:SetSelectCount(newCount)
    local oldCount = self.SelectCount
    self.SelectCount = math.max(newCount, self.DefaultMinSelectCount)
    if self.BtnUse then
        self.BtnUse.interactable = newCount > 0
    end
    if self.OnSelectCountChanged then
        self.OnSelectCountChanged(newCount - oldCount)
    end
    self:SetSelectState(newCount > self.DefaultMinSelectCount, true)
end

function XUiBagItem:MinusSelectCount()
    if self.SelectCount <= 0 then
        return
    end
    self:UpdateSelectCount(self.SelectCount - 1)
end

function XUiBagItem:AddSelectCount()
    local maxCount = self:GetGridCount()
    if maxCount and self.SelectCount >= maxCount then
        return
    end

    if self.SelectCount < self.Data.Count then
        self:UpdateSelectCount(self.SelectCount + 1)
    end
end

function XUiBagItem:SelectAll()
    self:UpdateSelectCount(self.Template.MaxCount)
end

function XUiBagItem:ClearSelectState()
    self:UpdateSelectCount(0)
end

function XUiBagItem:GetSelectCount()
    return self.SelectCount
end

function XUiBagItem:SetSelectState(isSelected, forceRefresh)
    if isSelected ~= self.SelectState then
        self.SelectState = isSelected
        if self.OnSelectStateChanged then
            self.OnSelectStateChanged(self.SelectState)
        end
        self:RefreshSelectState()
    else
        if forceRefresh then
            self:RefreshSelectState()
        end
    end
end

function XUiBagItem:IsSelected()
    return self.SelectState
end

-- 其他接口 
function XUiBagItem:GetGridCount()
    if self.RecycleBatch then
        return self.RecycleBatch.RecycleCount
    end

    if self.Template.GridCount <= 0 then
        return self.Data.Count
    else
        if self.TxtGridCount and self.GridIndex then
            return math.min(self.Data.Count - (self.GridIndex - 1) * self.Template.GridCount, self.Template.GridCount)
        end
    end
end

function XUiBagItem:SetNeedCount(needCount)
    if needCount then
        self.NeedCount = needCount
        self.TxtNeedCount.text = needCount
    end
end

function XUiBagItem:IsEnable()
    return self and self.GameObject and self.GameObject.activeSelf
end

function XUiBagItem:Refresh(data, NeedDefulatQulity, isSmallIcon, notCommonBg)
    local showSmallIcon = false
    if isSmallIcon then
        showSmallIcon = isSmallIcon
    end

    if self.CallBack then
        self.CallBack(data)
    end

    self.GameObject:SetActive(data ~= nil)

    if data == nil then
        return
    end

    self.SelectCount = self.DefaultMinSelectCount
    self.SelectState = false

    if data.Data and data.GridIndex then
        self.Data = data.Data
        self.GridIndex = data.GridIndex
        self.RecycleBatch = data.RecycleBatch
    else
        self.Data = data
    end

    self.TemplateId = self.Data.TemplateId and self.Data.TemplateId or self.Data.Id
    if not self.TemplateId then
        XLog.Error("XUiBagItem:Refresh error: TemplateId is nil")
        return
    end

    self.Template = self.Data.Template or XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId)

    self:RefreshSelf(NeedDefulatQulity, showSmallIcon, notCommonBg)

    self:RefreshSelectState()
end

function XUiBagItem:RefreshSelectState()
    local isNotMaxCount = self.SelectCount ~= self.Data.Count
    if self.BtnMinusSelect then
        self.BtnMinusSelect.interactable = self.SelectState
        if self.SelectCount <= self.DefaultMinSelectCount then
            if (not self.IsShowBtnMinusWhenMinSelectCount) then
                self.BtnMinusSelect.gameObject:SetActive(false)
            end
        else
            self.BtnMinusSelect.gameObject:SetActive(true)
        end
    end
    if self.BtnAddSelect then
        self.BtnAddSelect.interactable = isNotMaxCount
    end
    if self.TxtSelect then
        self.TxtSelect.text = self.SelectCount
        if self.SelectCount == 0 then
            self.TxtSelect.text = ""
        end
    end
    if self.TxtSelectHide then
        self.TxtSelectHide.gameObject:SetActive(self.SelectState)
        if self.SelectState then
            self.TxtSelectHide.text = "x" .. self.SelectCount
        end
    end
    if self.ImgSelect then
        self.ImgSelect.gameObject:SetActive(self.SelectState)
    end
    if self.ImgSelectBg then
        self.ImgSelectBg.gameObject:SetActive(self.SelectState)
    end
    if self.TxtNeedCount and self.NeedCount then
        if self.Data.Count >= self.NeedCount then
            self.TxtNeedCount.text = self.Data.Count .. "/" .. self.NeedCount
            if self.TxtHaveCount then
                self.TxtHaveCount.gameObject:SetActive(false)
            end
        else
            self.TxtNeedCount.text = "/" .. self.NeedCount
            if self.TxtHaveCount then
                self.TxtHaveCount.text = self.Data.Count
                self.TxtHaveCount.gameObject:SetActive(true)
            end
        end
    end
end

function XUiBagItem:SetDefaultMinSelectCount(minSelectCount)
    self.DefaultMinSelectCount = minSelectCount
    self.SelectCount = self.DefaultMinSelectCount
end

function XUiBagItem:ShowBtnMinusWhenMinSelectCount(show)
    self.IsShowBtnMinusWhenMinSelectCount = show
end

function XUiBagItem:RefreshSelf(NeedDefulatQulity, isSmallIcon, notCommonBg)
    if self.BtnUse then
        local isUseable = XDataCenter.ItemManager.IsUseable(self.TemplateId)
        self.BtnUse.gameObject:SetActive(isUseable)
        self.BtnUse.interactable = self.SelectCount > 0
    end

    if self.ImgCanUse then
        local isUseable = XDataCenter.ItemManager.IsUseable(self.TemplateId)
        self.ImgCanUse.gameObject:SetActive(isUseable)
    end

    if self.BtnOk then
        local isUseable = XDataCenter.ItemManager.IsUseable(self.TemplateId)
        self.BtnOk.gameObject:SetActive(not isUseable)
    end

    self:RefreshSelfCount()

    local template = self.Template
    if self.TxtName then
        self.TxtName.text = template.Name
    end

    if self.TxtDescription then
        self.TxtDescription.text = template.Description
    end

    if self.TxtWorldDesc then
        self.TxtWorldDesc.text = template.WorldDesc
    end

    if self.TxtUseLevel then
        self.TxtUseLevel.text = CS.XTextManager.GetText("CharacterUpgradeSkillConsumeTitle") .. "Lv." .. template.UseLevel
    end

    if self.TxtCount and self.Data.Count ~= nil then
        self.TxtCount.text = self.Data.Count
    end

    if self.RImgIcon and isSmallIcon then
        self.RImgIcon:SetRawImage(template.Icon)
    elseif self.RImgIcon and not isSmallIcon then
        self.RImgIcon:SetRawImage(template.BigIcon)
    end

    local quality = template.Quality

    -- 角色品质背景特殊处理
    if template.RewardType == XRewardManager.XRewardType.Character then
        quality = quality < 3 and 5 or 6
    end

    if self.ImgIconBg then
        if self.BtnGet or notCommonBg then
            XUiHelper.SetQualityIcon(self.RootUi, self.ImgIconBg, quality)
        else
            self.RootUi:SetUiSprite(self.ImgIconBg, XArrangeConfigs.GeQualityBgPath(quality))
        end
    end

    if self.ImgIconQuality then
        XUiHelper.SetQualityIcon(self.RootUi, self.ImgIconQuality, quality)
    end

    if NeedDefulatQulity and self.ImgIconBg then
        XUiHelper.SetQualityIcon(self.RootUi, self.ImgIconBg, quality)
    end

    if self.ImgState then
        local sprite = nil
        local text = ""

        if XDataCenter.ItemManager.IsCanConvert(self.TemplateId) then
            sprite = XUiHelper.TagBgPath.Blue
            text = CS.XTextManager.GetText("ItemCanConvert")
        elseif XDataCenter.ItemManager.IsTimeLimit(self.TemplateId) then
            local leftTime = self.RecycleBatch and self.RecycleBatch.RecycleTime - XTime.Now() or XDataCenter.ItemManager.GetRecycleLeftTime(self.Data.Id)
            text, sprite = XUiHelper.GetBagTimeLimitTimeStrAndBg(leftTime)
        end

        if sprite then
            self.RootUi:SetUiSprite(self.ImgState, sprite)
            self.ImgState.gameObject:SetActive(true)
        else
            self.ImgState.gameObject:SetActive(false)
        end

        if text then
            self.TxtState.text = text
            self.TxtState.gameObject:SetActive(true)
        else
            self.TxtState.gameObject:SetActive(false)
        end
    end

    if self.RefreshCallback then
        self.RefreshCallback()
    end
end

function XUiBagItem:RefreshSelfCount(useSelectCout)
    if self.TxtGridCount then
        local gridCount = self:GetGridCount()

        if useSelectCout and useSelectCout > 0 then
            gridCount = gridCount - useSelectCout
        end

        if gridCount <= 0 then
            if self.CallBack then
                self.CallBack(false)
            end

            self.GameObject:SetActive(false)
        else
            self.TxtGridCount.text = gridCount
        end
    end
end

function XUiBagItem:SetEnable(active)
    if self.Btn then
        self.Btn.interactable = active
    end
    if self.Btn2 then
        self.Btn2.interactable = active
    end
    if self.BtnAddSelect then
        self.BtnAddSelect.interactable = active
    end
    if self.WgtBtnAddSelect then
        self.WgtBtnAddSelect.enabled = active
    end
    if self.BtnMinusSelect then
        self.BtnMinusSelect.interactable = active
    end
    if self.WgtBtnMinusSelect then
        self.WgtBtnMinusSelect.enabled = active
    end
    if self.BtnGet then
        self.BtnGet.interactable = active
    end
    if self.BtnClose then
        self.BtnClose.interactable = active
    end
    if self.BtnOk then

        self.BtnOk.interactable = active
    end
    if self.BtnUse then
        self.BtnUse.interactable = active
    end
    if self.WgtBtn then
        self.WgtBtn.enabled = active
    end
end

-- 回调修改
-- 参数： 无
function XUiBagItem:SetClickCallback(callback)
    self.ClickCallback = callback
end

-- 参数： 无
function XUiBagItem:SetClickCallback2(callback)
    self.ClickCallback2 = callback
end

-- 参数： 无
function XUiBagItem:SetRefreshCallback(callback)
    self.RefreshCallback = callback
end

-- 参数： 使用数量
function XUiBagItem:SetUseRefreshCallback(callback)
    self.UseRefreshCallback = callback
end

-- 参数： 变化量
function XUiBagItem:SetSelectCountChangedCallback(callback)
    self.OnSelectCountChanged = callback
end

-- 参数： 新的选择状态
function XUiBagItem:SetSelectStateChangedCallback(callback)
    self.OnSelectStateChanged = callback
end

-- 参数： newCount
function XUiBagItem:SetChangeSelectCountCondition(condition)
    self.SelectCountChangeCondition = condition
end
local XUiDrawBuyVoucher = XLuaUiManager.Register(XLuaUi, "UiDrawBuyVoucher")


function XUiDrawBuyVoucher:OnAwake()
    self:InitAutoScript()
end

--voucherId 卡券Id
--ownAmount 拥有数量
--buyAmount 购买数量
--confirmCb 确定回调
function XUiDrawBuyVoucher:OnStart(voucherId, ownAmount, buyAmount, confirmCb)
    self.VoucherId = voucherId
    self.BuyAmount = buyAmount
    self.ConfirmCb = confirmCb
    local voucherTemplate = XDataCenter.ItemManager.GetItemTemplate(voucherId)
    local voucherName = voucherTemplate.Name
    local assetTemplate = XDataCenter.ItemManager.GetBuyAssetTemplate(voucherId, -1)
    local consumeCost = assetTemplate.ConsumeCount * buyAmount
    local consumeId = assetTemplate.ConsumeId
    local consumeTemplate = XDataCenter.ItemManager.GetItemTemplate(consumeId)
    local consumeName = consumeTemplate.Name
    self.ImgIcon:SetRawImage(voucherTemplate.Icon)
    self.TxtName.text = CS.XTextManager.GetText("DrawVoucherNotEnough", voucherName)
    self.TxtTip.text = CS.XTextManager.GetText("DrawBuyVoucherQuery", consumeCost, consumeName, buyAmount * assetTemplate.GainCount, voucherName)
    self.TxtCount.text = CS.XTextManager.GetText("DrawOwnVoucherAmount", ownAmount)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawBuyVoucher:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiDrawBuyVoucher:AutoInitUi()
    -- self.BtnBack = self.Transform:Find("SafeAreaContentPane/BtnBack"):GetComponent("Button")
    -- self.PanelBuyVoucher = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher")
    -- self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher/TxtName"):GetComponent("Text")
    -- self.TxtTip = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher/TxtTip"):GetComponent("Text")
    -- self.TxtCount = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher/TxtCount"):GetComponent("Text")
    -- self.ImgIcon = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher/ImgIcon"):GetComponent("RawImage")
    -- self.BtnBuy = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher/BtnBuy"):GetComponent("Button")
    -- self.BtnCancel = self.Transform:Find("SafeAreaContentPane/PanelBuyVoucher/BtnCancel"):GetComponent("Button")
    -- self.ImgMask = self.Transform:Find("SafeAreaContentPane/ImgMask"):GetComponent("Image")
end

function XUiDrawBuyVoucher:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiDrawBuyVoucher:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiDrawBuyVoucher:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiDrawBuyVoucher:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnBuy, self.OnBtnBuyClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
end
-- auto
function XUiDrawBuyVoucher:OnBtnBackClick(...)
    self:OnBtnCancelClick(...)
end

function XUiDrawBuyVoucher:OnBtnCancelClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiDrawBuyVoucher:OnBtnBuyClick(...)
    self.ImgMask.gameObject:SetActive(true)
    XDataCenter.ItemManager.BuyAsset(self.VoucherId, function()
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
        self.ConfirmCb()
    end, function()
        self.ImgMask.gameObject:SetActive(false)
    end, self.BuyAmount)
end
local XUiDrawPreview = XLuaUiManager.Register(XLuaUi, "UiDrawPreview")

function XUiDrawPreview:OnAwake()
    self:InitAutoScript()
end

function XUiDrawPreview:OnStart(drawId, closeCb, father)
    self.PanelProCard.gameObject:SetActive(false)
    self.PanelStdCard.gameObject:SetActive(false)
    self.DrawId = drawId
    self.CloseCb = closeCb
    self.Father = father
    self.ProCards = {}
    self.StdCards = {}
end

function XUiDrawPreview:OnEnable()
    self:Init(self.Father.DrawInfo.Id)
    XUiHelper.PlayAnimation(self, "UiDrawPreviewBegin")
end

function XUiDrawPreview:Init(id)
    self.DrawId = id
    local previewList = XDataCenter.DrawManager.GetDrawPreview(self.DrawId)
    if not previewList then
        return
    end

    local upGoods = previewList.UpGoods

    if #upGoods > 0 then
        self.ProTitle.gameObject:SetActive(true)
    else
        self.ProTitle.gameObject:SetActive(false)
    end

    for i = 1, #upGoods do
        if not self.ProCards[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.PanelProCard, self.PanelPro)
            local item = XUiGridCommon.New(self, go)
            item:Refresh(upGoods[i])
            table.insert(self.ProCards, item)
        else
            self.ProCards[i]:Refresh(upGoods[i])
        end
        self.ProCards[i].GameObject:SetActive(true)
    end

    for i = #upGoods + 1, #self.ProCards do
        self.ProCards[i].GameObject:SetActive(false)
    end


    local goods = previewList.Goods
    for i = 1, #goods do
        if not self.StdCards[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.PanelStdCard, self.PanelStd)
            local item = XUiGridCommon.New(self, go)
            item:Refresh(goods[i])
            table.insert(self.StdCards, item)
        else
            self.StdCards[i]:Refresh(goods[i])
        end
        self.StdCards[i].GameObject:SetActive(true)
    end

    for i = #goods + 1, #self.StdCards do
        self.StdCards[i].GameObject:SetActive(false)
    end
end

function XUiDrawPreview:SetActive(bool)
    self.GameObject:SetActive(bool)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawPreview:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiDrawPreview:AutoInitUi()
    self.PanelPreview = self.Transform:Find("SafeAreaContentPane/PanelPreview")
    self.PanelPro = self.Transform:Find("SafeAreaContentPane/PanelPreview/PnlScrollView/PnlViewport/PnlDetailContent/PanelPro")
    self.PanelProCard = self.Transform:Find("SafeAreaContentPane/PanelPreview/PnlScrollView/PnlViewport/PnlDetailContent/PanelPro/PanelProCard")
    self.PanelStd = self.Transform:Find("SafeAreaContentPane/PanelPreview/PnlScrollView/PnlViewport/PnlDetailContent/PanelStd")
    self.PanelStdCard = self.Transform:Find("SafeAreaContentPane/PanelPreview/PnlScrollView/PnlViewport/PnlDetailContent/PanelStd/PanelStdCard")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.ProTitle = self.Transform:Find("SafeAreaContentPane/PanelPreview/PnlScrollView/PnlViewport/PnlDetailContent/ProTitle")
end

function XUiDrawPreview:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiDrawPreview:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiDrawPreview:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiDrawPreview:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnClose, "onClick", self.OnBtnCloseClick)
end
-- auto
function XUiDrawPreview:OnBtnCloseClick(...)
    --[[
    if self.Closed then
        return
    end

    self.Closed = true
    --]]


    XUiHelper.PlayAnimation(self, "UiDrawPreviewEnd", nil, function()
        self:Close()
        self.CloseCb()
    end)

end
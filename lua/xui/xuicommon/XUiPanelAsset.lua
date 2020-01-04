XUiPanelAsset = XClass()
local insert = table.insert
local min = math.min
local max = math.max

function XUiPanelAsset:Ctor(rootUi, ui, ...)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ItemIds = { ... }
    self.EventListener = {}
    self:InitAutoScript()

    self:InitBtnSound()
    self:InitAssert(self.ItemIds)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAsset:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelAsset:AutoInitUi()
    self.PanelTool3 = XUiHelper.TryGetComponent(self.Transform, "PanelTool3", nil)
    self.RImgTool3 = XUiHelper.TryGetComponent(self.Transform, "PanelTool3/RImgTool3", "RawImage")
    self.TxtTool3 = XUiHelper.TryGetComponent(self.Transform, "PanelTool3/TxtTool3", "Text")
    self.BtnBuyJump3 = XUiHelper.TryGetComponent(self.Transform, "PanelTool3/BtnBuyJump3", "Button")
    self.PanelTool2 = XUiHelper.TryGetComponent(self.Transform, "PanelTool2", nil)
    self.RImgTool2 = XUiHelper.TryGetComponent(self.Transform, "PanelTool2/RImgTool2", "RawImage")
    self.TxtTool2 = XUiHelper.TryGetComponent(self.Transform, "PanelTool2/TxtTool2", "Text")
    self.BtnBuyJump2 = XUiHelper.TryGetComponent(self.Transform, "PanelTool2/BtnBuyJump2", "Button")
    self.PanelTool1 = XUiHelper.TryGetComponent(self.Transform, "PanelTool1", nil)
    self.RImgTool1 = XUiHelper.TryGetComponent(self.Transform, "PanelTool1/RImgTool1", "RawImage")
    self.TxtTool1 = XUiHelper.TryGetComponent(self.Transform, "PanelTool1/TxtTool1", "Text")
    self.BtnBuyJump1 = XUiHelper.TryGetComponent(self.Transform, "PanelTool1/BtnBuyJump1", "Button")
end

function XUiPanelAsset:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelAsset:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiPanelAsset:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelAsset:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBuyJump3, "onClick", self.OnBtnBuyJump3Click)
    self:RegisterListener(self.BtnBuyJump2, "onClick", self.OnBtnBuyJump2Click)
    self:RegisterListener(self.BtnBuyJump1, "onClick", self.OnBtnBuyJump1Click)
end
-- auto

function XUiPanelAsset:InitBtnSound()
    if self.BtnBuyJump3 then
        self.SpecialSoundMap[self:GetAutoKey(self.BtnBuyJump3, "onClick")] = 1013
    end

    if self.BtnBuyJump2 then
        self.SpecialSoundMap[self:GetAutoKey(self.BtnBuyJump2, "onClick")] = 1013
    end

    if self.BtnBuyJump1 then
        self.SpecialSoundMap[self:GetAutoKey(self.BtnBuyJump1, "onClick")] = 1013
    end
end

function XUiPanelAsset:OnBtnBuyJump1Click(...)
    self:BuyJump(1)
end

function XUiPanelAsset:OnBtnBuyJump2Click(...)
    self:BuyJump(2)
end

function XUiPanelAsset:OnBtnBuyJump3Click(...)
    self:BuyJump(3)
end

function XUiPanelAsset:BuyJump(index)
    if self.ItemIds[index] == XDataCenter.ItemManager.ItemId.FreeGem then
        XLuaUiManager.Open("UiPurchase",XPurchaseConfigs.TabsConfig.HK)
    else
        XUiManager.OpenBuyAssetPanel(self.ItemIds[index])
    end
end

function XUiPanelAsset:InitAssert()
    if XTool.UObjIsNil(self.GameObject) then
        return
    end

    local panels = {}
    if self.PanelTool1 then
        insert(panels, self.PanelTool1)
        self.PanelTool1.gameObject:SetActive(false)
    end

    if self.PanelTool2 then
        insert(panels, self.PanelTool2)
        self.PanelTool2.gameObject:SetActive(false)
    end

    if self.PanelTool3 then
        insert(panels, self.PanelTool3)
        self.PanelTool3.gameObject:SetActive(false)
    end

    local itemIds = self.ItemIds

    if #itemIds > #panels then
        XLog.Warning("XUiPanelAsset:InitAssert Warning: use item id morn than panel count, panel count is " .. #panels .. "use item id is ", itemIds)
    end
    local panelCount = min(#itemIds, #panels)

    local func = function(textTool, id)
        local itemCount = XDataCenter.ItemManager.GetCount(id)
        if id == XDataCenter.ItemManager.ItemId.ActionPoint then
            textTool.text = itemCount .. "/" .. XDataCenter.ItemManager.GetMaxActionPoints()
        else
            textTool.text = itemCount
        end
    end

    for i = 1, panelCount do
        local panel = panels[i]
        local item = XDataCenter.ItemManager.GetItem(itemIds[i])
        local rawImageIcon = self["RImgTool" .. i];
        if rawImageIcon ~= null and rawImageIcon:Exist() then
            --self.RootUi:SetUiSprite(self["ImgTool" .. i], item.Template.Icon)
            rawImageIcon:SetRawImage(item.Template.Icon, null, false)
        end
        local f = function(itemId, itemCount)
            func(self["TxtTool" .. i], itemIds[i])
        end
        XDataCenter.ItemManager.AddCountUpdateListener(itemIds[i], f, self["TxtTool" .. i])
        func(self["TxtTool" .. i], itemIds[i])
        panel.gameObject:SetActive(true)
    end
end


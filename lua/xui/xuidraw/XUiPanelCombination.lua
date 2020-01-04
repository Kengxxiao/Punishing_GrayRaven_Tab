local XUiPanelCombination = XClass()
local XUiGridSuitDetail = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitDetail")

function XUiPanelCombination:Ctor(ui, parent, index)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Parent = parent
    self.Index = index
    self.PanelComposition.gameObject:SetActive(false)
    self.PanelSuitCommon.gameObject:SetActive(false)
    self.TxtCombination.text = CS.XTextManager.GetText("DrawCombination", index)
    self:SetSelectState(false)
end

function XUiPanelCombination:SetData(drawId)

    local clickCb = function(data, grid)
        self.Parent:OnSuitGridClick(data, grid)
    end

    if self.DrawId ~= drawId then
        self.DrawId = drawId
        local combination = XDataCenter.DrawManager.GetDrawCombination(drawId)
        if not combination then return end

        local list = combination.GoodsId
        if not self.Compositions then
            self.Compositions = {}
        end

        --因为有了2种类型，每次都清空
        for k, v in pairs(self.Compositions) do
            CS.UnityEngine.Object.Destroy(v.GameObject)
        end
        self.Compositions = {}
        for i = 1, #list do
            if not self.Compositions[i] then
                local go = nil
                if combination.Type == XDrawConfigs.CombinationsTypes.Aim then
                    go = CS.UnityEngine.Object.Instantiate(self.PanelComposition, self.PanelNormal)
                    local item = XUiGridCommon.New(self.Parent, go)
                    item.GameObject:SetActive(true)
                    table.insert(self.Compositions, item)
                elseif combination.Type == XDrawConfigs.CombinationsTypes.EquipSuit then
                    go = CS.UnityEngine.Object.Instantiate(self.PanelSuitCommon, self.PanelSuit)
                    local item = XUiGridSuitDetail.New(go, self.Parent, clickCb)
                    item.GameObject:SetActive(true)
                    table.insert(self.Compositions, item)
                end
            end
            self.Compositions[i]:Refresh(list[i], nil, true)
        end

    end
    self:SetActive(true)
    end

function XUiPanelCombination:SetSelectState(bool)
    self.BtnSelect.gameObject:SetActive(not bool)
    self.TxtSelected.gameObject:SetActive(bool)
    if not self.Compositions then
        return
    end
    for k, v in pairs(self.Compositions) do
        v:SetShowUp(bool)
    end
end

function XUiPanelCombination:SetActive(bool)
    self.GameObject:SetActive(bool)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelCombination:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelCombination:AutoInitUi()
    self.PanelCompositions = self.Transform:Find("PanelCompositions")
    self.PanelNormal = self.Transform:Find("PanelCompositions/PanelNormal")
    self.PanelSuit = self.Transform:Find("PanelCompositions/PanelSuit")
    self.PanelComposition = self.Transform:Find("PanelCompositions/PanelNormal/PanelComposition")
    self.PanelSuitCommon = self.Transform:Find("PanelCompositions/PanelSuit/PanelSuitCommon")
    self.TxtCombination = self.Transform:Find("PanelSelect/TxtCombination"):GetComponent("Text")
    self.BtnSelect = self.Transform:Find("PanelSelect/BtnSelect"):GetComponent("XUiButton")
    self.TxtSelected = self.Transform:Find("PanelSelect/TxtSelected")
end

function XUiPanelCombination:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelCombination:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelCombination:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelCombination:AutoAddListener()
    self.BtnSelect.CallBack = function() self:OnBtnSelectClick() end
    self.AutoCreateListeners = {}
    --self:RegisterListener(self.BtnSelect, "onClick", self.OnBtnSelectClick)
end
-- auto
function XUiPanelCombination:OnBtnSelectClick(...)
    self.Parent:SelectCombination(self.Index, self.DrawId)
    --CS.XUiManager.ViewManager:Pop()
end

return XUiPanelCombination
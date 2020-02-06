local XUiDrawRule = XLuaUiManager.Register(XLuaUi, "UiDrawRule")
local prob = require("XUi/XUiDraw/XUiPanelProbability")

function XUiDrawRule:OnAwake()
    self:InitAutoScript()
end

function XUiDrawRule:OnStart(drawId, closeCb)
    self.PanelProbability.gameObject:SetActive(false)
    self.CloseCb = closeCb
    self:SetData(drawId)
    --XUiHelper.PlayAnimation(self, "DrawRuleBegin")
end

function XUiDrawRule:SetData(drawId)
    local groupId = XDataCenter.DrawManager.GetDrawInfo(drawId).GroupId
    local rules = XDataCenter.DrawManager.GetDrawGroupRule(groupId).BaseRules
    local rule = rules[1]
    for i = 2, #rules do
        rule = rule .. "\n" .. rules[i]
    end
    self.TxtRule.text = rule
    if not self.Probs then
        self.Probs = {}
    end
    local list = XDataCenter.DrawManager.GetDrawProb(drawId)
    if not list then
        return
    end
    for i = 1, #list do
        if not self.Probs[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.PanelProbability, self.PanelDetailContent)
            local item = prob.New(go, self)
            table.insert(self.Probs, item)
        end
        self.Probs[i]:SetData(list[i])
        self.Probs[i]:SetActive(true)
    end
    if #list < #self.Probs then
        for i = #list + 1, #self.Probs do
            self.Probs[i]:SetActive(false)
        end
    end
end

function XUiDrawRule:SetActive(bool)
    self.GameObject:SetActive(bool)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawRule:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiDrawRule:AutoInitUi()
    -- self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    -- self.PanelRule = self.Transform:Find("SafeAreaContentPane/PanelRule")
    -- self.PanelDetailContent = self.Transform:Find("SafeAreaContentPane/PanelRule/PnlScrollView/PnlViewport/PanelDetailContent")
    -- self.TxtRule = self.Transform:Find("SafeAreaContentPane/PanelRule/PnlScrollView/PnlViewport/PanelDetailContent/TxtRule"):GetComponent("Text")
    -- self.PanelProbability = self.Transform:Find("SafeAreaContentPane/PanelRule/PnlScrollView/PnlViewport/PanelDetailContent/PanelProbability")
end

function XUiDrawRule:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiDrawRule:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiDrawRule:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiDrawRule:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto
function XUiDrawRule:OnBtnCloseClick(...)
    if self.Closed then
        return
    end

    self.Closed = true
    -- XUiHelper.PlayAnimation(self, "DrawRuleEnd", nil, function()
    --     --CS.XUiManager.ViewManager:Pop()
    --     self:Close()
    --     self.CloseCb()
    -- end)
end
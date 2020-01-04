local XUiDrawOptional = XLuaUiManager.Register(XLuaUi, "UiDrawOptional")
local combination = require("XUi/XUiDraw/XUiPanelCombination")

function XUiDrawOptional:OnAwake()
    self:InitAutoScript()
end

function XUiDrawOptional:OnStart(groupId, drawInfo, parentUi, optionalCb)
    self.PanelCombination.gameObject:SetActive(false)
    self.ParentUi = parentUi
    self.OptionalCb = optionalCb
    self.GroupId = groupId
    self:SetData(groupId, drawInfo)
    self.CurSuitId = 0
    self.CurSelectDrawId = drawInfo.Id
end

function XUiDrawOptional:OnEnable()
    self.Transform:PlayLegacyAnimation("UiDrawOptionalBegin")
end

function XUiDrawOptional:SetData(groupId, drawInfo)
    local list = XDataCenter.DrawManager.GetDrawInfoListByGroupId(groupId)
    if not self.Combinations then
        self.Combinations = {}
    end
    local selectedIndex
    for i = 1, #list do
        if not self.Combinations[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.PanelCombination, self.PanelCombinations)
            local item = combination.New(go, self, i)
            table.insert(self.Combinations, item)
        end
        self.Combinations[i]:SetData(list[i].Id)
        self.Combinations[i]:SetActive(true)
        if list[i].Id == drawInfo.Id then
            selectedIndex = i
        end
    end
    for i = #list + 1, #self.Combinations do
        self.Combinations[i]:SetActive(false)
    end
    if selectedIndex and self.Combinations[selectedIndex] then
        self:SelectCombination(selectedIndex, list[selectedIndex].Id)
    else
        self:SelectCombination(1, list[1].Id)
    end
end

function XUiDrawOptional:SelectCombination(index, drawId)
    if self.SelectedIndex == index then
        return
    end
    if self.Combinations[index] then
        if self.SelectedIndex and self.Combinations[self.SelectedIndex] then
            self.Combinations[self.SelectedIndex]:SetSelectState(false)
        end
        self.SelectedIndex = index
        self.Combinations[index]:SetSelectState(true)
        self.CurSelectDrawId = drawId
    end
end

function XUiDrawOptional:SetActive(bool)
    self.GameObject:SetActive(bool)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawOptional:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiDrawOptional:AutoInitUi()
    self.PanelOptional = self.Transform:Find("SafeAreaContentPane/PanelOptional")
    self.PanelCombinations = self.Transform:Find("SafeAreaContentPane/PanelOptional/SrollViewInfoList/PanelCombinations")
    self.PanelCombination = self.Transform:Find("SafeAreaContentPane/PanelOptional/SrollViewInfoList/PanelCombinations/PanelCombination")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
end

function XUiDrawOptional:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiDrawOptional:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiDrawOptional:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiDrawOptional:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnClose, "onClick", self.OnBtnCloseClick)
end
-- auto
function XUiDrawOptional:OnBtnCloseClick(...)
    XUiHelper.PlayAnimation(self, "UiDrawOptionalEnd", nil, function()
        self.OptionalCb(self.CurSelectDrawId)
        self:Close()
    end)
    XDataCenter.DrawManager.SaveDrawAimId(self.CurSelectDrawId,self.GroupId)
end

function XUiDrawOptional:OnSuitGridClick(suitId, grid)
    self.CurSuitId = suitId
    self.ParentUi:OpenChildUi("UiDrawSuitPreview", self.CurSuitId, self)
    --XLuaUiManager.Open("UiDrawSuitPreview", suitId)
end
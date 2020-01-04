local XUiAutoFightReward = XLuaUiManager.Register(XLuaUi, "UiAutoFightReward")
local UiCharacter = require("XUi/XUiAutoFightReward/XUiAutoFightRewardCharacter")

local tableinsert = table.insert

local AnimBegin = "AniAutoFightRewardBegin"
local AnimEnd = "AniAutoFightRewardEnd"

function XUiAutoFightReward:OnAwake()
    self:InitAutoScript()
    self:InitTemplate()
end

function XUiAutoFightReward:OnStart(cardIds, data)
    self.CardIds = cardIds
    self.Data = data

    local playerLevel = XPlayer.Level
    self.TxtLv.text = playerLevel
    self.TxtExp.text = "+" .. data.TeamExp

    for i, id in pairs(cardIds) do
        if id > 0 then
            self:NewCharacter(id, data.CharacterExp)
        end
    end

    for key, reward in pairs(data.Rewards) do
        self:NewItem(reward)
    end

    local playerExp = XPlayer.Exp
    local playerMaxExp = XPlayerManager.GetMaxExp(XPlayer.Level)
    local expBefore = playerExp - data.TeamExp
    self.ImgExpBar.fillAmount = expBefore > 0 and expBefore / playerMaxExp or 0
    self.ImgExpBarReward.fillAmount = playerExp / playerMaxExp
    self.Transform:PlayLegacyAnimation(AnimBegin)
end

function XUiAutoFightReward:InitTemplate()
    self.CharacterContainer = self.PanelCharacters:Find("CharacterContainer")
    self.CharacterTemplate = self.CharacterContainer:Find("CharacterTemplate")
    self.ItemContainer = self.PanelItems:Find("ScrollView/Viewport/ItemContainer")
    self.ItemTemplate = self.ItemContainer:Find("ItemTemplate")
end

function XUiAutoFightReward:NewCharacter(id, exp)
    local transform
    if not self.UiCharacters then
        transform = self.CharacterTemplate
        self.UiCharacters = {}
    else
        transform = CS.UnityEngine.Object.Instantiate(self.CharacterTemplate, self.CharacterContainer)
    end

    local uiCharacter = UiCharacter.New(transform)
    uiCharacter:SetData(id, exp)
    tableinsert(self.UiCharacters, uiCharacter)
end

function XUiAutoFightReward:NewItem(data)
    local transform
    if not self.UiItems then
        transform = self.ItemTemplate
        self.UiItems = {}
    else
        transform = CS.UnityEngine.Object.Instantiate(self.ItemTemplate, self.ItemContainer)
    end

    local grid = XUiGridCommon.New(self, transform)
    grid:Refresh(data)
    tableinsert(self.UiItems, grid)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAutoFightReward:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAutoFightReward:AutoInitUi()
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.PanelAutoFightReward = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward")
    self.PanelCharacters = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCharacters")
    self.PanelCommander = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCommander")
    self.TxtLv = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCommander/TxtLv"):GetComponent("Text")
    self.TxtExp = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCommander/TxtExp"):GetComponent("Text")
    self.ImgExpBarBg = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCommander/ExpBar/ImgExpBarBg"):GetComponent("Image")
    self.ImgExpBarReward = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCommander/ExpBar/ImgExpBarReward"):GetComponent("Image")
    self.ImgExpBar = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelCommander/ExpBar/ImgExpBar"):GetComponent("Image")
    self.PanelItems = self.Transform:Find("SafeAreaContentPane/PanelAutoFightReward/PanelItems")
end

function XUiAutoFightReward:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto
function XUiAutoFightReward:OnBtnCloseClick(eventData)
    self.BtnClose.interactable = false
    self.Transform:PlayLegacyAnimation(AnimEnd, function()
        self:Close()
    end)
end
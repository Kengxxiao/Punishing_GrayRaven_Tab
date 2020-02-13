local XUiGridEchelonExp = XClass()

function XUiGridEchelonExp:Ctor(rootUi, ui, data)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self:InitComponentState()
    self:ResetDataInfo()
    self:UpdateDataInfo(data)
end

function XUiGridEchelonExp:InitComponentState()
    self.GridCharacter.gameObject:SetActive(false)
end

function XUiGridEchelonExp:ResetDataInfo()
    self.GroupId = nil
    self.EchelonIndex = nil
    self.BaseStage = nil
end

function XUiGridEchelonExp:UpdateDataInfo(data)
    self.GroupId = data.GroupId
    self.EchelonIndex = data.EchelonIndex
    self.BaseStage = data.BaseStage
    self.EchelonType = data.EchelonType

    self:UpdateTxtExp()
    self:UpdateTxtEchelonIndex()
    self:UpdatePanelMembers()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridEchelonExp:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridEchelonExp:AutoInitUi()
    self.TxtExp = self.Transform:Find("ImageExpTag/TxtExp"):GetComponent("Text")
    self.TxtEchelonIndex = self.Transform:Find("TxtEchelonIndex"):GetComponent("Text")
    self.PanelCharacters = self.Transform:Find("PanelCharacters")
    self.GridCharacter = self.Transform:Find("PanelCharacters/GridCharacter")
end

function XUiGridEchelonExp:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridEchelonExp:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridEchelonExp:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridEchelonExp:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiGridEchelonExp:UpdateTxtExp()
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.BaseStage)
    self.TxtExp.text = "+" .. stageCfg.CardExp
end

function XUiGridEchelonExp:UpdateTxtEchelonIndex()
    self.TxtEchelonIndex.text = XDataCenter.BfrtManager.GetEchelonNameTxt(self.EchelonType, self.EchelonIndex)
end

function XUiGridEchelonExp:UpdatePanelMembers()
    if self.EchelonType == XDataCenter.BfrtManager.EchelonType.Fight then
        self:UpdateFightTeamCharacter()
    elseif self.EchelonType == XDataCenter.BfrtManager.EchelonType.Logistics then
        self:UpdateLogisticsTeamCharacter()
    end
end

function XUiGridEchelonExp:UpdateFightTeamCharacter()
    local fightTeamList = XDataCenter.BfrtManager.GetFightTeamList(self.GroupId)
    if not fightTeamList then
        XLog.Error("XUiGridEchelonExp UpdateFightTeamCharacter error: do not have fightTeamList.")
        return
    end

    local fightTeam = fightTeamList[self.EchelonIndex]
    for index = 1, #fightTeam do
        local charId = fightTeam[XDataCenter.BfrtManager.TeamPosConvert(index)]
        if charId ~= 0 then
            local char = XDataCenter.CharacterManager.GetCharacter(charId)
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCharacter)
            local grid = XUiGridCharacter.New(self, ui, char)
            grid.Transform:SetParent(self.PanelCharacters, false)
            grid.GameObject:SetActive(true)
        end
    end
end

function XUiGridEchelonExp:UpdateLogisticsTeamCharacter()
    local logisticsTeamList = XDataCenter.BfrtManager.GetLogisticsTeamList(self.GroupId)
    if not logisticsTeamList then
        XLog.Error("XUiGridEchelonExp UpdateLogisticsTeamCharacter error: do not have logisticsTeamList.")
        return
    end

    local logisticsTeam = logisticsTeamList[self.EchelonIndex]
    for index = 1, #logisticsTeam do
        local charId = logisticsTeam[index]
        if charId ~= 0 then
            local char = XDataCenter.CharacterManager.GetCharacter(charId)
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCharacter)
            local grid = XUiGridCharacter.New(self, ui, char)
            grid.Transform:SetParent(self.PanelCharacters, false)
            grid.GameObject:SetActive(true)
        end
    end
end

return XUiGridEchelonExp
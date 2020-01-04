local XUiPanelExpBar = require("XUi/XUiSettleWinMainLine/XUiPanelExpBar")

XUiGridWinRole = XClass()

function XUiGridWinRole:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

-- 角色经验
function XUiGridWinRole:UpdateRoleInfo(charExpData, addExp)
    local charId = charExpData.Id
    local char = XDataCenter.CharacterManager.GetCharacter(charId)
    if char == nil then
        return
    end
   
    local lastLevel = charExpData.Level
    local lastExp = charExpData.Exp
    local lastMaxExp = XCharacterConfigs.GetNextLevelExp(charId, lastLevel)
    local curLevel = char.Level
    local curExp = char.Exp
    local curMaxExp = XCharacterConfigs.GetNextLevelExp(charId, curLevel)
    self.PlayerExpBar = self.PlayerExpBar or XUiPanelExpBar.New(self.PanelPlayerExpBar)
    self.PlayerExpBar:LetsRoll(lastLevel, lastExp, lastMaxExp, curLevel, curExp, curMaxExp, addExp)

    local icon = XDataCenter.CharacterManager.GetCharBigHeadIcon(charId)
    if icon then
        self.RImgIcon:SetRawImage(icon)
    end
end

function XUiGridWinRole:UpdateRobotInfo(robotId)
    local data = XRobotManager.GetRobotTemplate(robotId)
    local curLevel = data.CharacterLevel
    local curExp = 1
    local maxExp = 1
    local addExp = 0
    self.PlayerExpBar = self.PlayerExpBar or XUiPanelExpBar.New(self.PanelPlayerExpBar, curLevel, curExp, curLevel, curExp, maxExp, addExp)

    local icon = XDataCenter.CharacterManager.GetCharBigHeadIcon(data.CharacterId)
    if icon then
        self.RImgIcon:SetRawImage(icon)
    end
end
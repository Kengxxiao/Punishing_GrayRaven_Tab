local XUiBabelTowerAutoFight = XLuaUiManager.Register(XLuaUi, "UiBabelTowerAutoFight")
local XUiGridAutoFightMember = require("XUi/XUiFubenBabelTower/XUiGridAutoFightMember")

function XUiBabelTowerAutoFight:OnAwake()
    self.BtnBg.CallBack = function() self:OnBtnBgClick() end
    self.BtnAutoFight.CallBack = function() self:OnBtnAutoFightClik() end
    self.BtnTanchuangClose.CallBack = function() self:OnBtnBgClick() end

    self.AutoFightGrid = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        self.AutoFightGrid[i] = XUiGridAutoFightMember.New(self[string.format("GridRoleAutoFight%d", i)])
    end
end

function XUiBabelTowerAutoFight:OnBtnBgClick()
    self:Close()
end

function XUiBabelTowerAutoFight:OnBtnAutoFightClik()
    if self.StageId and self.StageServerInfo then
        -- 黑名单判断
        local blackList = XDataCenter.FubenBabelTowerManager.WipeOutBlackList(self.StageId)
        local hasBlackListMember = false
        local blackListMemberId = 0
        for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
            local characterId = self.StageServerInfo.TeamList[i]
            if characterId ~= nil and characterId ~= 0 then
                if blackList[characterId] then
                    hasBlackListMember = true
                    blackListMemberId = characterId
                    break
                end
            end
        end
        if hasBlackListMember and blackListMemberId > 0 then
            local blackName = XCharacterConfigs.GetCharacterFullNameStr(blackListMemberId)
            XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerCharacterLock", blackName))
            return
        end

        XDataCenter.FubenBabelTowerManager.WipeOutBabelTowerStage(self.StageId, function()
            self.StageServerInfo.IsReset = false
            if self.EndCb then
                self.EndCb()
            end
            local stageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(self.StageId)
            XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerStageWipeOutSucceed", stageConfigs.Name))
            self:Close()
        end)
    end
end

function XUiBabelTowerAutoFight:OnStart(stageId, endCb)
    self.StageId = stageId
    self.StageServerInfo = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    self.EndCb = endCb
    if not self.StageServerInfo then
        self:Close()
        return 
    end

    local blackList = XDataCenter.FubenBabelTowerManager.WipeOutBlackList(self.StageId)
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        local characterId = self.StageServerInfo.TeamList[i]
        local isLock = false
        if characterId ~= nil and characterId ~= 0 then
            isLock = blackList[characterId]
        end
        
        self.AutoFightGrid[i]:UpdateMember(self.StageServerInfo.TeamList[i], isLock)
    end
    self.TxtScore.text = self.StageServerInfo.CurScore
end

function XUiBabelTowerAutoFight:OnDestroy()
end

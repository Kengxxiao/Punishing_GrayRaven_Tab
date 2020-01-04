local XUiBfrtInfo = XLuaUiManager.Register(XLuaUi, "UiBfrtInfo")

local ANIMATION_OPEN = {
    "UiBfrtInfoBegan1",
    "UiBfrtInfoBegan2",
    "UiBfrtInfoBegan3",
}

local ANIMATION_LOOP = {
    "UiBfrtInfoLoop1",
    "UiBfrtInfoLoop2",
    "UiBfrtInfoLoop3",
}

local ANIMATION_PANEL = {
    "PanelStageList01",
    "PanelStageList02",
    "PanelStageList03",
}

function XUiBfrtInfo:OnAwake()
    self:InitAutoScript()
    self.SafeAreaContentPane = self.Transform:Find("SafeAreaContentPane")
    self.FullScreenBackground = self.Transform:Find("FullScreenBackground")
end

function XUiBfrtInfo:OnGetEvents()
    return { CS.XEventId.EVENT_FIGHT_FORCE_EXIT, CS.XEventId.EVENT_FUBEN_SETTLE_FAIL }
end

function XUiBfrtInfo:OnNotify(evt, ...)
    if evt == CS.XEventId.EVENT_FIGHT_FORCE_EXIT or evt == CS.XEventId.EVENT_FUBEN_SETTLE_FAIL then
        self:Close()
    end
end

function XUiBfrtInfo:OnStart(groupId, fightTeams)
    self:ShowBfrtInfo(groupId, fightTeams)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBfrtInfo:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiBfrtInfo:AutoInitUi()
    self.PanelStageList01 = self.Transform:Find("SafeAreaContentPane/PanelStageList01")
    self.PanelGridTeam = self.Transform:Find("SafeAreaContentPane/PanelGridTeam")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/TxtName"):GetComponent("Text")
    self.GridTeam = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam")
    self.PanelCharIcon1 = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam/PanelCharIcon1")
    self.RImgCharIcon1 = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam/PanelCharIcon1/Bg/RImgCharIcon1"):GetComponent("RawImage")
    self.PanelCharIcon2 = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam/PanelCharIcon2")
    self.RImgCharIcon2 = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam/PanelCharIcon2/Bg/RImgCharIcon2"):GetComponent("RawImage")
    self.PanelCharIcon3 = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam/PanelCharIcon3")
    self.RImgCharIcon3 = self.Transform:Find("SafeAreaContentPane/PanelGridTeam/GridTeam/PanelCharIcon3/Bg/RImgCharIcon3"):GetComponent("RawImage")
    self.PanelLine = self.Transform:Find("SafeAreaContentPane/PanelLine")
    self.TxtGroupName = self.Transform:Find("SafeAreaContentPane/PanelLine/TxtGroupName"):GetComponent("Text")
    self.TxtZhangjie = self.Transform:Find("SafeAreaContentPane/PanelLine/TxtZhangjie"):GetComponent("Text")
    self.PanelStageList02 = self.Transform:Find("SafeAreaContentPane/PanelStageList02")
    self.PanelStageList03 = self.Transform:Find("SafeAreaContentPane/PanelStageList03")
end

function XUiBfrtInfo:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiBfrtInfo:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBfrtInfo:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiBfrtInfo:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiBfrtInfo:ShowBfrtInfo(groupId, fightTeams)
    self.GroupId = groupId
    self.CurIndex = 1

    local chapterId = XDataCenter.BfrtManager.GetChapterIdByGroupId(groupId)
    local chapterCfg = XDataCenter.BfrtManager.GetChapterCfg(chapterId)
    local stageIdList = XDataCenter.BfrtManager.GetStageIdList(groupId)
    local maxIndex = #stageIdList

    self.TxtZhangjie.text = chapterCfg.ChapterName
    self.TxtGroupName.text = chapterCfg.ChapterEn

    local updateStageInfofunc = function()
        if self.CurIndex > maxIndex then
            XDataCenter.BfrtManager.SetCloseLoadingCb()
            XDataCenter.BfrtManager.SetFightCb()
            self:Close()
            return
        end

        self.FullScreenBackground.gameObject:SetActive(true)
        self.SafeAreaContentPane.gameObject:SetActive(true)

        local stageId = stageIdList[self.CurIndex]
        local team = fightTeams[self.CurIndex]
        self:UpdateAnimationNode()
        self:PlayBeginAnimation()
        self:SetBfrtTeam(team)
        XDataCenter.FubenManager.EnterBfrtFight(stageId, team)

        self.TxtName.text = CS.XTextManager.GetText("BfrtInfoTeamName", self.CurIndex)
    end

    XDataCenter.BfrtManager.SetCloseLoadingCb(function()
        self.FullScreenBackground.gameObject:SetActive(false)
        self.SafeAreaContentPane.gameObject:SetActive(false)
    end)

    XDataCenter.BfrtManager.SetFightCb(function(result)
        if not result then
            XDataCenter.BfrtManager.SetCloseLoadingCb()
            XDataCenter.BfrtManager.SetFightCb()
            self:Close()
        else
            self.CurIndex = self.CurIndex + 1
            updateStageInfofunc()
        end
    end)

    updateStageInfofunc()
end

function XUiBfrtInfo:SetBfrtTeam(team)
    local count = #team
    if count <= 0 then
        self.GridTeam.gameObject:SetActive(false)
        return
    end

    for i = 1, count do
        local viewIndex = XDataCenter.BfrtManager.TeamPosConvert(i)
        if team[i] > 0 then
            self["RImgCharIcon" .. viewIndex]:SetRawImage(XDataCenter.CharacterManager.GetCharBigRoundnessNotItemHeadIcon(team[i]))
            self["PanelCharIcon" .. viewIndex].gameObject:SetActive(true)
        else
            self["PanelCharIcon" .. viewIndex].gameObject:SetActive(false)
        end
    end
end

function XUiBfrtInfo:UpdateAnimationNode()
    for k, v in pairs(ANIMATION_PANEL) do
        if k == self.CurIndex then
            self[v].gameObject:SetActive(true)
        else
            self[v].gameObject:SetActive(false)
        end
    end

    local stageList = XDataCenter.BfrtManager.GetStageIdList(self.GroupId)
    for i = #stageList + 2, 4 do
        local gridBfrtStage = XUiHelper.TryGetComponent(self[ANIMATION_PANEL[self.CurIndex]], "GridBfrtStage" .. i, nil)
        if gridBfrtStage then gridBfrtStage.gameObject:SetActive(false) end
    end
end

function XUiBfrtInfo:PlayBeginAnimation()
    local endCb = function()
        self:PlayLoopAnimation()
    end

    self.GameObject:PlayLegacyAnimation(ANIMATION_OPEN[self.CurIndex], endCb)
end

function XUiBfrtInfo:PlayLoopAnimation()
    local endCb = function()
    end
    self.GameObject:PlayLegacyAnimation(ANIMATION_LOOP[self.CurIndex], endCb)
end

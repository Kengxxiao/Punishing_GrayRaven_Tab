local XUiNewRoomSingle = XLuaUiManager.Register(XLuaUi, "UiNewRoomSingle")

local MAX_FIREND_HELP = 2
-- 当下战斗里面位置写死1号位为队长 如之后战斗里面改为队长位跟随配置表 这里顺序都改为 123
local CHAR_POS1 = 2
local CHAR_POS2 = 1
local CHAR_POS3 = 3
local MAX_CHAR_COUNT = 3
local LONG_CLICK_TIME = 0
local TIMER = 1
local LOAD_TIME = 10

function XUiNewRoomSingle:OnAwake()
    self:AutoAddListener()
    self.PanelTip.gameObject:SetActive(false)
end

function XUiNewRoomSingle:OnStart(stageId, suggestedConditionIds, forceConditionIds, eventIds)
    self.CurrentStageId = stageId
    self.SuggestedConditionIds = suggestedConditionIds or {}
    self.ForceConditionIds = forceConditionIds or {}
    self.EventIds = eventIds
    self.TypeIdMainLine = CS.XGame.Config:GetInt("TypeIdMainLine")
    self.TypeIdBossSingle = CS.XGame.Config:GetInt("TypeIdBossSingle")
    self.TypeIdExplore = CS.XGame.Config:GetInt("TypeIdExplore")
    self.StageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    self.StageInfos = XDataCenter.FubenManager.GetStageInfo(stageId)

    self.BtnShowInfoToggle.CallBack = function(val) self:OnBtnShowInfoToggle(val) end

    self.ImgAddList = {
        self.ImgAdd2,
        self.ImgAdd1,
        self.ImgAdd3
    }
    self.ChangeCharIndex = 0

    self.RoleModelPanelList = {
        XUiPanelRoleModel.New(self:GetSceneRoot().transform:FindTransform("PanelRoleModel2"), self.Name, nil, true, nil, true, true),
        XUiPanelRoleModel.New(self:GetSceneRoot().transform:FindTransform("PanelRoleModel1"), self.Name, nil, true, nil, true, true),
        XUiPanelRoleModel.New(self:GetSceneRoot().transform:FindTransform("PanelRoleModel3"), self.Name, nil, true, nil, true, true)
    }

    self.PanelLeaderPos = {
        CS.UnityEngine.Vector2(140, -250), -- 2
        CS.UnityEngine.Vector2(-500, -145), -- 1
        CS.UnityEngine.Vector2(700, -145) -- 3
    }

    self.PanelRoleEffect2 = self:GetSceneRoot().transform:FindTransform("PanelRoleEffect2")
    self.PanelRoleEffect1 = self:GetSceneRoot().transform:FindTransform("PanelRoleEffect1")
    self.PanelRoleEffect3 = self:GetSceneRoot().transform:FindTransform("PanelRoleEffect3")

    self.PanelRoleEffect = {
        self.PanelRoleEffect2,
        self.PanelRoleEffect1,
        self.PanelRoleEffect3
    }
    self.PanelStaminaList = {
        [1] = {
            PanelStamina = self.PanelStaminaBar2,
            ImgStaminaFill = self.ImgStaminaExpFill2,
            TxtMyStamina = self.TxtMyStamina2
        },
        [2] = {
            PanelStamina = self.PanelStaminaBar1,
            ImgStaminaFill = self.ImgStaminaExpFill1,
            TxtMyStamina = self.TxtMyStamina1
        },
        [3] = {
            PanelStamina = self.PanelStaminaBar3,
            ImgStaminaFill = self.ImgStaminaExpFill3,
            TxtMyStamina = self.TxtMyStamina3
        }
    }

    self.PanelCharacterInfo = {
        [1] = {
            CharacterInfo = self.CharacterInfo2,
            TxtFight = self.TxtFight2,
            RImgType = self.RImgType2
        },
        [2] = {
            CharacterInfo = self.CharacterInfo1,
            TxtFight = self.TxtFight1,
            RImgType = self.RImgType1
        },
        [3] = {
            CharacterInfo = self.CharacterInfo3,
            TxtFight = self.TxtFight3,
            RImgType = self.RImgType3
        }
    }

    -- 默认助战为关闭状态
    if XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.OtherHelp) then
        self.BtnSupportToggle:SetButtonState(XUiButtonState.Normal)
    end

    self.Camera = self.Transform:GetComponent("Canvas").worldCamera
    self.RectTransform = self.Transform:GetComponent("RectTransform")
    self:InitInfo()

    XCameraHelper.SetUiCameraParam(self.Name)
    XEventManager.AddEventListener(XEventId.EVENT_TEAM_PREFAB_SELECT, self.UpdateTeam, self)
    XEventManager.AddEventListener(XEventId.EVENT_FIGHT_BEGIN_PLAYMOVIE, self.OnOpenLoadingOrBeginPlayMovie, self)
    XEventManager.AddEventListener(XEventId.EVENT_FIGHT_LOADINGFINISHED, self.OnOpenLoadingOrBeginPlayMovie, self)
    XEventManager.AddEventListener(XEventId.EVENT_TEAM_PREFAB_CHANGE, self.OnTeamChange, self)
end

function XUiNewRoomSingle:OnDisable()
    XDataCenter.FavorabilityManager.StopCv()
end

function XUiNewRoomSingle:OnDestroy()
    XUiHelper.StopAnimation()
    self:RemoveTimer()
    XEventManager.RemoveEventListener(XEventId.EVENT_TEAM_PREFAB_SELECT, self.UpdateTeam, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_FIGHT_BEGIN_PLAYMOVIE, self.OnOpenLoadingOrBeginPlayMovie, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_FIGHT_LOADINGFINISHED, self.OnOpenLoadingOrBeginPlayMovie, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_TEAM_PREFAB_CHANGE, self.OnTeamChange, self)
end

function XUiNewRoomSingle:OnTeamChange()
    --更新战力限制提示
    self:InitFightControl()
end

function XUiNewRoomSingle:OnOpenLoadingOrBeginPlayMovie()
    self:Remove()
end

function XUiNewRoomSingle:OnEnable()
    self:InitFightControl()
    self:InitCharacterInfo()
end

function XUiNewRoomSingle:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnTeamPrefab, self.OnBtnTeamPrefabClick)
    self:RegisterClickEvent(self.BtnChar1, self.OnBtnChar1Click)
    self:RegisterClickEvent(self.BtnChar2, self.OnBtnChar2Click)
    self:RegisterClickEvent(self.BtnChar3, self.OnBtnChar3Click)
    self:RegisterClickEvent(self.BtnEnterFight, self.OnBtnEnterFightClick)
    self.BtnSupportToggle.CallBack = function(state) self:OnBtnAssistToggleClick(state) end
    if not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.OtherHelp) then
        self.BtnSupportToggle:SetDisable(true)
    end
end

function XUiNewRoomSingle:OnBtnTeamPrefabClick(...)
    if self:CheckHasRobot() then
        return
    end
    XLuaUiManager.Open("UiRoomTeamPrefab", function(resTeam)
        self:UpdateTeam(resTeam)
    end)

end

function XUiNewRoomSingle:OnBtnShowInfoToggle(val)
    if val then
        local key = "NewRoomShowInfoToggle" .. tostring(XPlayer.Id)
        CS.UnityEngine.PlayerPrefs.SetInt(key, val)
    end
    self:InitCharacterInfo()
end

function XUiNewRoomSingle:OnBtnAssistToggleClick(state)
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.OtherHelp) then
        return
    end

    self:SetAssistStatus(XUiHelper.GetToggleVal(state))
    local assistSwitch = self:GetAssistStatus() and 1 or 0
    CS.UnityEngine.PlayerPrefs.SetInt(XPrefs.AssistSwitch .. XPlayer.Id, assistSwitch)
    if self:GetAssistStatus() then
        self:PlayTips("FightAssistOpen", true)
    else
        self:PlayTips("FightAssistClose", false)
    end
end

function XUiNewRoomSingle:InitInfo()
    self.ImgRoleRepace.gameObject:SetActive(false)
    self:InitTeamData()
    self:InitPanelTeam()
    self:SetWeakness()
    self:RefreshCaptainSkill()
    self:InitBtnLongClicks()
    self:SetCondition()
    self:SetStageInfo()
    self:InitEndurance()
    --更新战力限制提示
    self:InitFightControl()
    --更新战斗信息
    self:InitCharacterInfo()

    if self.StageInfos.HaveAssist == 1 then
        self:ShowAssistToggle(true)
        -- 保存玩家选择助战状态
        local assistSwitch = CS.UnityEngine.PlayerPrefs.GetInt(XPrefs.AssistSwitch .. XPlayer.Id)
        if assistSwitch == nil or assistSwitch == 0 then
            self:SetAssistStatus(false)
        else
            self:SetAssistStatus(true)
        end

    else
        self:ShowAssistToggle(false)
        self:SetAssistStatus(false)
    end
    -- end
end

function XUiNewRoomSingle:SetBossSingleInfo()
    self:ShowAssistToggle(false)
end

-- 初始化长按事件
function XUiNewRoomSingle:InitBtnLongClicks()
    local btnLongClick1 = self.BtnChar1:GetComponent("XUiPointer")
    local btnLongClick2 = self.BtnChar2:GetComponent("XUiPointer")
    local btnLongClick3 = self.BtnChar3:GetComponent("XUiPointer")
    XUiButtonLongClick.New(btnLongClick1, 10, self, nil, self.OnBtnUnLockLongClick1, self.OnBtnUnLockLongUp, false)
    XUiButtonLongClick.New(btnLongClick2, 10, self, nil, self.OnBtnUnLockLongClick2, self.OnBtnUnLockLongUp, false)
    XUiButtonLongClick.New(btnLongClick3, 10, self, nil, self.OnBtnUnLockLongClick3, self.OnBtnUnLockLongUp, false)
end

function XUiNewRoomSingle:OnBtnUnLockLongUp(...)
    self.ImgRoleRepace.gameObject:SetActive(false)
    self.IsUp = not self.IsUp
    LONG_CLICK_TIME = 0
    if self:CheckHasRobot() then
        return
    end

    if self.ChangeCharIndex > 0 then
        local targetX = math.floor(self:GetPisont().x + self.RectTransform.rect.width / 2)
        local targetIndex = 0
        if targetX <= self.RectTransform.rect.width / 3 then
            targetIndex = CHAR_POS1
        elseif targetX > self.RectTransform.rect.width / 3 and targetX <= self.RectTransform.rect.width / 3 * 2 then
            targetIndex = CHAR_POS2
        else
            targetIndex = CHAR_POS3
        end

        if targetIndex > 0 and targetIndex ~= self.ChangeCharIndex then
            local teamData = XTool.Clone(self.CurTeam.TeamData)
            local targetId = teamData[targetIndex]
            teamData[targetIndex] = teamData[self.ChangeCharIndex]
            teamData[self.ChangeCharIndex] = targetId
            self:UpdateTeam(teamData)
        end
        self.ChangeCharIndex = 0
    end
end

function XUiNewRoomSingle:SeBtnUnLockLongClickt(index, time)
    if self.CurTeam.TeamData[index] <= 0 then
        self.IsUp = true
        return
    end

    LONG_CLICK_TIME = LONG_CLICK_TIME + time / 1000
    if self.IsUp then
        self.IsUp = false
        return
    end
    if LONG_CLICK_TIME > TIMER and not self.IsUp then
        self.IsUp = false
        if not self.ImgRoleRepace.gameObject.activeSelf then
            self.ImgRoleRepace.gameObject:SetActive(true)
        end
        self.ImgRoleRepace.gameObject.transform.localPosition = self:GetPisont()
    end
    if self.ChangeCharIndex <= 0 then
        self.ChangeCharIndex = index
    end
end

function XUiNewRoomSingle:GetPisont()
    local screenPoint
    if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsPlayer then
        screenPoint = CS.UnityEngine.Vector2(CS.UnityEngine.Input.mousePosition.x, CS.UnityEngine.Input.mousePosition.y)
    else
        screenPoint = CS.UnityEngine.Input.GetTouch(0).position
    end

    -- 设置拖拽
    local hasValue, v2 = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.RectTransform, screenPoint, self.Camera)
    if hasValue then
        return CS.UnityEngine.Vector3(v2.x, v2.y, 0)
    else
        return CS.UnityEngine.Vector3.zero
    end
end

function XUiNewRoomSingle:OnBtnUnLockLongClick1(time)
    self:SeBtnUnLockLongClickt(2, time)
end

function XUiNewRoomSingle:OnBtnUnLockLongClick2(time)
    self:SeBtnUnLockLongClickt(1, time)
end

function XUiNewRoomSingle:OnBtnUnLockLongClick3(time)
    self:SeBtnUnLockLongClickt(3, time)
end

-- 初始化 team 数据
function XUiNewRoomSingle:InitTeamData()
    local curTeam = nil
    if self.StageInfos.Type == XDataCenter.FubenManager.StageType.BossSingle then
        curTeam = XDataCenter.TeamManager.GetPlayerTeam(self.TypeIdBossSingle)
    elseif self.StageInfos.Type == XDataCenter.FubenManager.StageType.Explore then
        curTeam = XDataCenter.TeamManager.GetPlayerTeam(self.TypeIdExplore)
        --每次进入清空上次的选则
        for i = 1, #curTeam.TeamData do
            curTeam.TeamData[i] = 0
        end
    else
        curTeam = XDataCenter.TeamManager.GetPlayerTeam(self.TypeIdMainLine)
    end
    if curTeam == nil then
        return
    end

    self.CurTeam = curTeam
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.CurrentStageId)
    self.HasRobot = stageCfg.RobotId and #stageCfg.RobotId > 0
    if stageCfg.RobotId and #stageCfg.RobotId > 0 then
        self.CurTeam.TeamData = {}
        for i = 1, MAX_CHAR_COUNT do
            if i > #stageCfg.RobotId then
                table.insert(self.CurTeam.TeamData, 0)
            else
                local charId = XRobotManager.GetCharaterId(stageCfg.RobotId[i])
                table.insert(self.CurTeam.TeamData, charId)
            end
        end
    end

    for i = 1, MAX_CHAR_COUNT do
        local teamCfg = XDataCenter.TeamManager.GetTeamCfg(i)
        if teamCfg then
            self.PanelRoleEffect[i]:LoadPrefab(teamCfg.EffectPath, false)
        end
    end
end

-- team Ui 初始化
function XUiNewRoomSingle:InitPanelTeam()
    self.BtnEnterFight.gameObject:SetActive(false)
    self.ImgEnterFightOff.gameObject:SetActive(true)

    -- 记录是否全部加载完成
    self.LoadModelCount = 0
    for i = 1, MAX_CHAR_COUNT do
        local posData = self.CurTeam.TeamData[i]
        if posData and posData > 0 then
            self.LoadModelCount = self.LoadModelCount + 1
        end
    end

    for i = 1, MAX_CHAR_COUNT do
        self["Timer" .. i] = CS.XScheduleManager.ScheduleOnce(function()
            if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
                return
            end

            local posData = self.CurTeam.TeamData[i]
            if posData and posData > 0 then
                self:UpdateRoleModel(posData, self.RoleModelPanelList[i], i)
                self.ImgAddList[i].gameObject:SetActive(false)
                self:UpdateRoleStanmina(posData, i)
            else
                self.PanelStaminaList[i].PanelStamina.gameObject:SetActive(false)
                self.ImgAddList[i].gameObject:SetActive(true)
            end
        end, i * LOAD_TIME)
    end
end

function XUiNewRoomSingle:RemoveTimer()
    for i = 1, MAX_CHAR_COUNT do
        if self["Timer" .. i] then
            CS.XScheduleManager.UnSchedule(self["Timer" .. i])
            self["Timer" .. i] = nil
        end
    end
end

--更新模型
function XUiNewRoomSingle:UpdateRoleModel(charId, roleModelPanel, pos)
    local callback = function(model)
        self.LoadModelCount = self.LoadModelCount - 1
        if self.LoadModelCount <= 0 then
            self.BtnEnterFight.gameObject:SetActive(true)
            self.ImgEnterFightOff.gameObject:SetActive(false)
        end
    end
    if self.HasRobot then
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.CurrentStageId)
        local robotCfg = XRobotManager.GetRobotTemplate(stageCfg.RobotId[pos])
        roleModelPanel:UpdateRobotModel(charId, callback, robotCfg.FashionId, robotCfg.WeaponId)
    else
        roleModelPanel:UpdateCharacterModel(charId, nil, nil, nil, callback)
    end
    
    roleModelPanel:ShowRoleModel()
end

--更新耐力值
function XUiNewRoomSingle:UpdateRoleStanmina(charId, index)
    if self.StageInfos.Type ~= XDataCenter.FubenManager.StageType.BossSingle
    and self.StageInfos.Type ~= XDataCenter.FubenManager.StageType.Explore
    then
        self.PanelStaminaList[index].PanelStamina.gameObject:SetActive(false)
        return
    end

    local maxStamina = 9
    local curStamina = 0

    if self.StageInfos.Type == XDataCenter.FubenManager.StageType.BossSingle then
        maxStamina = XDataCenter.FubenBossSingleManager.MAX_STAMINA
        curStamina = XDataCenter.FubenBossSingleManager.MAX_STAMINA - XDataCenter.FubenBossSingleManager.GetCharacterChallengeCount(charId)
    elseif self.StageInfos.Type == XDataCenter.FubenManager.StageType.Explore then
        maxStamina = XDataCenter.FubenExploreManager.GetMaxEndurance(XDataCenter.FubenExploreManager.GetCurChapterId())
        curStamina = maxStamina - XDataCenter.FubenExploreManager.GetEndurance(XDataCenter.FubenExploreManager.GetCurChapterId(), charId)
    end

    local text = CS.XTextManager.GetText("BossSingleStamina", curStamina, maxStamina)
    self.PanelStaminaList[index].TxtMyStamina.text = text
    self.PanelStaminaList[index].ImgStaminaFill.fillAmount = curStamina / maxStamina
    self.PanelStaminaList[index].PanelStamina.gameObject:SetActive(true)
end

function XUiNewRoomSingle:SetAssistStatus(active)
    if XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.OtherHelp) then
        if active then
            self.BtnSupportToggle:SetButtonState(XUiButtonState.Select)
        else
            self.BtnSupportToggle:SetButtonState(XUiButtonState.Normal)
        end
    end
end

function XUiNewRoomSingle:ShowAssistToggle(show)
    if show then
        self.BtnSupportToggle.gameObject:SetActive(true)
    else
        self.BtnSupportToggle.gameObject:SetActive(false)
    end
end

function XUiNewRoomSingle:GetAssistStatus()
    return self.BtnSupportToggle:GetToggleState()
end

function XUiNewRoomSingle:SetWeakness()
    self.PanelWeakness.gameObject:SetActive(true)

    local eventDesc
    if self.EventIds and #self.EventIds > 0 and self.EventIds[1] > 0 then
        eventDesc = XRoomSingleManager.GetEvenDesc(self.EventIds[1])
        self.TxtWeaknessDesc.text = eventDesc
        return
    end

    eventDesc = XRoomSingleManager.GetEventDescByMapId(self.CurrentStageId)
    if eventDesc then
        self.TxtWeaknessDesc.text = eventDesc
    else
        self.PanelWeakness.gameObject:SetActive(false)
    end
end

function XUiNewRoomSingle:SetCondition()
    self.GridCondition.gameObject:SetActive(false)

    local stageSuggestedConditionIds, stageForceConditionIds = XDataCenter.FubenManager.GetConditonByMapId(self.CurrentStageId)
    for _, value in pairs(stageSuggestedConditionIds) do
        table.insert(self.SuggestedConditionIds, value)
    end

    for _, value in pairs(stageForceConditionIds) do
        table.insert(self.ForceConditionIds, value)
    end

    for _, id in pairs(self.SuggestedConditionIds) do
        self:SetConditionGrid(id)
    end

    for _, id in pairs(self.ForceConditionIds) do
        self:SetConditionGrid(id)
    end
end

function XUiNewRoomSingle:SetConditionGrid(id)
    local item = CS.UnityEngine.Object.Instantiate(self.GridCondition)
    item.gameObject.transform:SetParent(self.PanelConditionContent, false)
    local textDesc = item.gameObject.transform:Find("TxtDesc"):GetComponent("Text")
    local ret, desc = XConditionManager.CheckCondition(id, self.CurTeam.TeamData)
    textDesc.text = desc
    item.gameObject:SetActive(true)
end

function XUiNewRoomSingle:RefreshCaptainSkill()
    self.PanelSkill.gameObject:SetActive(true)
    local captainId = self.CurTeam.TeamData[self.CurTeam.CaptainPos]
    if captainId <= 0 then
        self.PanelSkill.gameObject:SetActive(false)
        return
    end

    local captianSkillInfo = XDataCenter.CharacterManager.GetCaptainSkillInfo(captainId)
    self:SetUiSprite(self.ImgSkillIcon, captianSkillInfo.Icon)
    self.TxtSkillName.text = captianSkillInfo.Name
    self.TxtSkillDesc.text = captianSkillInfo.Intro
end

function XUiNewRoomSingle:SetStageInfo()
    local chapterName, stageName = XDataCenter.FubenManager.GetFubenNames(self.CurrentStageId)
    self.TxtChapterName.text = chapterName
    self.TxtStageName.text = stageName
end

function XUiNewRoomSingle:InitEndurance()
    if self.StageInfos.Type == XDataCenter.FubenManager.StageType.Explore then
        if XDataCenter.FubenExploreManager.IsNodeFinish(XDataCenter.FubenExploreManager.GetCurChapterId(), XDataCenter.FubenExploreManager.GetCurNodeId()) then
            self.PanelEndurance.gameObject:SetActive(false)
        else
            self.PanelEndurance.gameObject:SetActive(true)
            self.TxtEnduranceNum.text = XDataCenter.FubenExploreManager.GetCurNodeEndurance()
        end
    else
        self.PanelEndurance.gameObject:SetActive(false)
    end
end

function XUiNewRoomSingle:InitFightControl()
    local teamAbility = {}
    for i = 1, #self.CurTeam.TeamData do
        local character = XDataCenter.CharacterManager.GetCharacter(self.CurTeam.TeamData[i])
        if character == nil then
            table.insert(teamAbility, 0)
        else
            table.insert(teamAbility, character.Ability)
        end
    end
    local conditionResult = true
    for _, id in pairs(self.ForceConditionIds) do
        local ret, desc = XConditionManager.CheckCondition(id, self.CurTeam.TeamData)
        if not ret then
            conditionResult = false
        end
    end
    if not self.FightControl then
        self.FightControl = XUiNewRoomFightControl.New(self.PanelNewRoomFightControl)
        self.FightControlResult = self.FightControl:UpdateInfo(self.StageCfg.FightControlId, teamAbility, conditionResult, self.CurrentStageId, self.CurTeam.TeamData)
    else
        self.FightControlResult = self.FightControl:UpdateInfo(self.StageCfg.FightControlId, teamAbility, conditionResult, self.CurrentStageId, self.CurTeam.TeamData)
    end
end

--更新战斗信息
function XUiNewRoomSingle:InitCharacterInfo()
    --机器人关卡不显示战斗信息
    if self.HasRobot then
        self.BtnShowInfoToggle.gameObject:SetActiveEx(false)
        for i = 1, #self.PanelCharacterInfo do
            self.PanelCharacterInfo[i].CharacterInfo.gameObject:SetActiveEx(false)
        end
        return
    else
        self.BtnShowInfoToggle.gameObject:SetActiveEx(true)
    end
    self.IsShowCharacterInfo = 0
    local key = "NewRoomShowInfoToggle" .. tostring(XPlayer.Id)
    if CS.UnityEngine.PlayerPrefs.HasKey(key) then
        self.IsShowCharacterInfo = CS.UnityEngine.PlayerPrefs.GetInt(key)
    else
        CS.UnityEngine.PlayerPrefs.SetInt(key, 0)
    end
    if self.IsShowCharacterInfo > 0 then
        self.BtnShowInfoToggle:SetButtonState(XUiButtonState.Select)
        for i = 1, #self.CurTeam.TeamData do
            local character = XDataCenter.CharacterManager.GetCharacter(self.CurTeam.TeamData[i])
            if character == nil then
                self.PanelCharacterInfo[i].CharacterInfo.gameObject:SetActiveEx(false)
            else
                self.PanelCharacterInfo[i].CharacterInfo.gameObject:SetActiveEx(true)
                self.PanelCharacterInfo[i].TxtFight.text = math.floor(character.Ability)
                self.PanelCharacterInfo[i].RImgType:SetRawImage(XCharacterConfigs.GetNpcTypeIcon(character.Type))
            end
        end
    else
        self.BtnShowInfoToggle:SetButtonState(XUiButtonState.Normal)
        for i = 1, #self.PanelCharacterInfo do
            self.PanelCharacterInfo[i].CharacterInfo.gameObject:SetActiveEx(false)
        end
    end
end

function XUiNewRoomSingle:OnBtnBackClick(...)
    self:Close()
end

function XUiNewRoomSingle:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiNewRoomSingle:OnBtnChar1Click(...)
    if self:CheckHasRobot() then
        return
    end
    local teamData = XTool.Clone(self.CurTeam.TeamData)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.CurrentStageId)
    if stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
        XLuaUiManager.Open("UiMainLineRoomCharacter", teamData, CHAR_POS1, function(resTeam)
            self:UpdateTeam(resTeam)
        end)
    else
        XLuaUiManager.Open("UiRoomCharacter", teamData, CHAR_POS1, function(resTeam)
            self:UpdateTeam(resTeam)
        end, stageInfo.Type)
    end
end

function XUiNewRoomSingle:OnBtnChar2Click(...)
    if self:CheckHasRobot() then
        return
    end
    local teamData = XTool.Clone(self.CurTeam.TeamData)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.CurrentStageId)
    if stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
        XLuaUiManager.Open("UiMainLineRoomCharacter", teamData, CHAR_POS2, function(resTeam)
            self:UpdateTeam(resTeam)
        end)
    else
        XLuaUiManager.Open("UiRoomCharacter", teamData, CHAR_POS2, function(resTeam)
            self:UpdateTeam(resTeam)
        end, stageInfo.Type)
    end
end

function XUiNewRoomSingle:OnBtnChar3Click(...)
    if self:CheckHasRobot() then
        return
    end
    local teamData = XTool.Clone(self.CurTeam.TeamData)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.CurrentStageId)
    if stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
        XLuaUiManager.Open("UiMainLineRoomCharacter", teamData, CHAR_POS3, function(resTeam)
            self:UpdateTeam(resTeam)
        end)
    else
        XLuaUiManager.Open("UiRoomCharacter", teamData, CHAR_POS3, function(resTeam)
            self:UpdateTeam(resTeam)
        end, stageInfo.Type)
    end
end

-- 更新队伍
function XUiNewRoomSingle:UpdateTeam(teamData)
    if self.CurTeam.TeamId == nil or self.CurTeam.TeamData == nil then
        XLog.Error("Set Team Error! teamId or team is nil")
        return
    end

    for posId, val in pairs(teamData) do
        local oldCharId = self.CurTeam.TeamData[posId]
        if oldCharId > 0 and oldCharId ~= val then
            -- 检查被替换的位置是否有角色，并且不相同
            self.RoleModelPanelList[posId]:HideRoleModel()
        end
    end

    self.CurTeam.TeamData = teamData
    self:InitPanelTeam() -- 更新当前队伍显示状态
    self:RefreshCaptainSkill()
    XDataCenter.TeamManager.SetPlayerTeam(self.CurTeam, false) -- 保存数据

    --更新角色信息面板
    self:InitCharacterInfo()
end

function XUiNewRoomSingle:PlayTips(key, isOn)
    local msg = CS.XTextManager.GetText(key)
    self.TxtTips1.text = isOn and msg or ""
    self.TxtTips2.text = isOn and "" or msg
    self.PanelTip.gameObject:SetActive(true)

    self:PlayAnimation("PanelTipEnable", handler(self, function()
        self.PanelTip.gameObject:SetActive(false)
    end))
end

function XUiNewRoomSingle:CheckHasRobot()
    if self.HasRobot then
        local text = CS.XTextManager.GetText("NewRoomSingleCannotSetRobot")
        XUiManager.TipError(text)
    end
    return self.HasRobot
end

function XUiNewRoomSingle:OnBtnEnterFightClick(...)
    local captainId = XDataCenter.TeamManager.GetTeamCaptainId(self.CurTeam.TeamId)
    if not self.HasRobot then
        if captainId == nil or captainId <= 0 then
            XUiManager.TipText("TeamManagerCheckCaptainNil")
            return
        end
    end

    if not XDataCenter.FubenManager.CheckFightConditionByTeamData(self.ForceConditionIds, self.CurTeam.TeamData) then
        return
    end

    if not self:CheckRoleStanmina() then
        return
    end

    local stage = XDataCenter.FubenManager.GetStageCfg(self.CurrentStageId)
    local isAssist = self:GetAssistStatus()

    if self.StageInfos.Type == XDataCenter.FubenManager.StageType.Explore then
        XDataCenter.FubenExploreManager.SetCurTeam(self.CurTeam)
    end
    --战力警告
    if self.FightControlResult == XUiFightControlState.Ex then
        local data = XFubenConfigs.GetStageFightControl(self.StageCfg.FightControlId)
        local contenttext
        --计算战力
        local teamAbility = {}
        for i = 1, #self.CurTeam.TeamData do
            local character = XDataCenter.CharacterManager.GetCharacter(self.CurTeam.TeamData[i])
            if character == nil then
                table.insert(teamAbility, 0)
            else
                table.insert(teamAbility, character.Ability)
            end
        end

        if data.MaxRecommendFight > 0 then
            contenttext = CS.XTextManager.GetText("Insufficient", data.MaxShowFight)
        elseif data.AvgRecommendFight > 0 then
            local count = 0
            for k, v in pairs(teamAbility) do
                if v > 0 then
                    if v < data.AvgShowFight then
                        count = count + 1
                    end
                end
            end
            contenttext = CS.XTextManager.GetText("AvgInsufficient", count, data.AvgShowFight)
        else
            contenttext = CS.XTextManager.GetText("Insufficient", data.ShowFight)
        end

        local titletext = CS.XTextManager.GetText("AbilityInsufficient")
        XUiManager.DialogTip(titletext, contenttext, XUiManager.DialogType.Normal, nil, function()
            XDataCenter.FubenManager.EnterFight(stage, self.CurTeam.TeamId, isAssist)
        end)
    else
        XDataCenter.FubenManager.EnterFight(stage, self.CurTeam.TeamId, isAssist)
    end
end

function XUiNewRoomSingle:CheckRoleStanmina()
    if self.StageInfos.Type ~= XDataCenter.FubenManager.StageType.BossSingle then
        return true
    end

    for i = 1, MAX_CHAR_COUNT do
        local posData = self.CurTeam.TeamData[i]
        if posData and posData > 0 then
            local curStamina = XDataCenter.FubenBossSingleManager.MAX_STAMINA - XDataCenter.FubenBossSingleManager.GetCharacterChallengeCount(posData)
            if curStamina <= 0 then
                local charName = XCharacterConfigs.GetCharacterName(posData)
                local text = CS.XTextManager.GetText("BossSingleNoStamina", charName)
                XUiManager.TipError(text)
                return false
            end
        end
    end
    return true
end
local XUiMultiplayerRoom = XLuaUiManager.Register(XLuaUi, "UiMultiplayerRoom")
local XUiGridMulitiplayerRoomChar = require("XUi/XUiMultiplayerRoom/XUiGridMulitiplayerRoomChar")
local XUiGridMultiplayerDifficultyItem = require("XUi/XUiMultiplayerRoom/XUiGridMultiplayerDifficultyItem")
local CSXTextManagerGetText = CS.XTextManager.GetText
local MAX_CHAT_WIDTH = 450
local CHAT_SUB_LENGTH = 18

------------------------------ tips类 ---------------------------
local XUiTips = XClass()
function XUiTips:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiTips:SetText(desc)
    self.TxtTips.text = desc
end

function XUiTips:SetActive(enable)
    self.GameObject:SetActive(enable)
end
---------------------------------------------------------

local MAX_PLAYER_COUNT = 3

local ButtonState = {
    ["Waiting"] = 1,
    ["Fight"] = 2,
    ["Ready"] = 3,
    ["CancelReady"] = 4,
}

local DifficultyType = {
    ["Normal"] = 1,
    ["Hart"] = 2,
    ["Nightmare"] = 3,
}

function XUiMultiplayerRoom:OnAwake()
    self.RoomKickCountDownTime = CS.XGame.Config:GetInt("RoomKickCountDownTime")
    self.RoomKickCountDownShowTime = CS.XGame.Config:GetInt("RoomKickCountDownShowTime")

    local root = self:GetSceneRoot().transform
    self.RoleModelList = {}
    for i = 1, MAX_PLAYER_COUNT do
        local case = root:FindTransform("PanelModelCase" .. i)
        local roleModel = XUiPanelRoleModel.New(case, self.Name, nil, true)
        self.RoleModelList[i] = roleModel
    end

    self.InFSetAbilityLimit = self.InFSetAbilityLimit:GetComponent("InputField")

    self:RegisterClickEvent(self.ToggleQuickMatch, self.OnToggleQuickMatchClick)
    self:RegisterClickEvent(self.BtnFight, self.OnBtnFightClick)
    self:RegisterClickEvent(self.BtnCancelReady, self.OnBtnCancelReadyClick)
    self:RegisterClickEvent(self.BtnReady, self.OnBtnReadyClick)
    self:RegisterClickEvent(self.BtnChat, self.OnBtnChatClick)
    self:RegisterClickEvent(self.BtnChangeDifficulty, self.OnBtnChangeDifficultyClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnDifficultySelect, self.OnBtnDifficultySelectClick)
    self:RegisterClickEvent(self.BtnCloseDifficulty, self.OnBtnCloseDifficultyClick)
    self.BtnSetAbilityLimit.CallBack = handler(self, self.OnBtnSetAbilityLimitClick)
    self.BtnCloseAbilityLimit.CallBack = handler(self, self.OnBtnCloseAbilityLimitClick)
    self.BtnCancel.CallBack = handler(self, self.OnBtnCloseAbilityLimitClick)
    self.BtnConfirmSetAbilityLimit.CallBack = handler(self, self.OnBtnConfirmSetAbilityLimitClick)
    self.BtnAutoMatch.CallBack = handler(self, self.OnBtnAutoMatchClick)

    local actionIcon = XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.ActionPoint)
    self.RImgActionIcon:SetRawImage(actionIcon)
    self.BtnGroup = {
        [ButtonState.Waiting] = self.BtnWaiting.gameObject,
        [ButtonState.Fight] = self.BtnFight.gameObject,
        [ButtonState.Ready] = self.BtnReady.gameObject,
        [ButtonState.CancelReady] = self.BtnCancelReady.gameObject,
    }

    self:InitCharItems()

    self:InitDifficultyButtons()

    self.TipsList = {
        XUiTips.New(self.PanelTips)
    }

    self.PanelDifficulty.gameObject:SetActive(false)
    self.PanelChangeDifficulty.gameObject:SetActive(false)
    self.PanelAbilityLimit.gameObject:SetActive(false)
end

function XUiMultiplayerRoom:OnStart()
    self.GridMap = {}

    XEventManager.AddEventListener(XEventId.EVENT_ROOM_REFRESH, self.OnRoomRefresh, self)
    -- XEventManager.AddEventListener(XEventId.EVENT_FUBEN_SHOW_REWARD, self.OnShowReward, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_KICKOUT, self.OnKickOut, self)
    XEventManager.AddEventListener(XEventId.EVENT_ITEM_COUNT_UPDATE_PREFIX .. XDataCenter.ItemManager.ItemId.ActionPoint, self.OnActionPointUpdate, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_PLAYER_ENTER, self.OnPlayerEnter, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_PLAYER_LEAVE, self.OnPlayerLevel, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_PLAYER_STAGE_REFRESH, self.OnPlayerStageRefresh, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_PLAYER_NPC_REFRESH, self.OnPlayerNpcRefresh, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_AUTO_MATCH_CHANGE, self.OnRoomAutoMatchChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_STAGE_LEVEL_CHANGE, self.OnRoomStageLevelChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_STAGE_CHANGE, self.OnRoomStageChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_ROOM_STAGE_ABILITY_LIMIT_CHANGE, self.OnRoomAbilityLimitChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHAT_RECEIVE_ROOM_MSG, self.RefreshChatMsg, self)
end

function XUiMultiplayerRoom:OnEnable()
    self:Refresh()
end

function XUiMultiplayerRoom:OnDestroy()
    self:StopTimer()

    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_REFRESH, self.OnRoomRefresh, self)
    -- XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_SHOW_REWARD, self.OnShowReward, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_KICKOUT, self.OnKickOut, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ITEM_COUNT_UPDATE_PREFIX .. XDataCenter.ItemManager.ItemId.ActionPoint, self.OnActionPointUpdate, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_PLAYER_ENTER, self.OnPlayerEnter, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_PLAYER_LEAVE, self.OnPlayerLevel, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_PLAYER_STAGE_REFRESH, self.OnPlayerStageRefresh, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_PLAYER_NPC_REFRESH, self.OnPlayerNpcRefresh, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_AUTO_MATCH_CHANGE, self.OnRoomAutoMatchChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_STAGE_LEVEL_CHANGE, self.OnRoomStageLevelChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_STAGE_CHANGE, self.OnRoomStageChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_ROOM_STAGE_ABILITY_LIMIT_CHANGE, self.OnRoomAbilityLimitChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHAT_RECEIVE_ROOM_MSG, self.RefreshChatMsg, self)
end

function XUiMultiplayerRoom:OnRoomRefresh()
end

function XUiMultiplayerRoom:OnKickOut()
    if XLuaUiManager.IsUiShow("UiChatServeMain") then
        XLuaUiManager.Close("UiChatServeMain")
    end

    if XLuaUiManager.IsUiShow("UiDialog") then
        XLuaUiManager.Close("UiDialog")
    end

    if XLuaUiManager.IsUiShow("UiMultiplayerRoom") then
        self:Close()
    else
        self:Remove()
    end
end

function XUiMultiplayerRoom:OnActionPointUpdate(itemId, count)
    self.TxtActionPoint.text = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.ActionPoint).Count
end

-- 有玩家进入房间
function XUiMultiplayerRoom:OnPlayerEnter(playerData)
    local grid = self:GetGrid(playerData.Id)
    grid:InitCharData(playerData)
    self:RefreshButtonStatus()
    self:CheckLeaderCountDown()
    self:RefreshTips()
    self:RefreshSameCharTips()
end

-- 有玩家离开房间
function XUiMultiplayerRoom:OnPlayerLevel(playerId)
    local grid = self:GetGrid(playerId)
    grid:InitEmpty()
    self:RefreshButtonStatus()
    self.GridMap[playerId] = nil
    self:CheckLeaderCountDown()
    self:RefreshTips()
    self:RefreshSameCharTips()
end

-- 玩家状态刷新
function XUiMultiplayerRoom:OnPlayerStageRefresh(playerData)
    local grid = self:GetGrid(playerData.Id)
    grid:RefreshPlayer(playerData)
    self:RefreshButtonStatus()
    self:CheckLeaderCountDown()
end

-- 玩家Npc信息刷新
function XUiMultiplayerRoom:OnPlayerNpcRefresh(playerData)
    local grid = self:GetGrid(playerData.Id)
    grid:InitCharData(playerData)
    self:RefreshButtonStatus()
    self:CheckLeaderCountDown()
    self:RefreshTips()
    self:RefreshSameCharTips()
end

-- 房间自动修改
function XUiMultiplayerRoom:OnRoomAutoMatchChange(autoMatch)
    self:RefreshButtonStatus()
    self:RefreshDifficultyPanel()
    self:CheckLeaderCountDown()
end

-- 房间难度等级修改
function XUiMultiplayerRoom:OnRoomStageLevelChange(lastLevel, curLevel)
    self:RefreshButtonStatus()
    self:RefreshDifficultyPanel()
    self:PlayStageLevelChange(lastLevel, curLevel)
    self.PanelDifficulty.gameObject:SetActive(false)
    self:CheckLeaderCountDown()
end

-- 房间状态修改
function XUiMultiplayerRoom:OnRoomStageChange(state)
    self:CheckLeaderCountDown()
end

-- 房间战力限制修改
function XUiMultiplayerRoom:OnRoomAbilityLimitChange(lastAbilityLimit, curAbilityLimit)
    self:RefreshAbilityLimit()
end

function XUiMultiplayerRoom:PlayStageLevelChange(lastLevel, curLevel)
    local roomData = XDataCenter.RoomManager.RoomData
    local levelControl = XDataCenter.FubenManager.GetStageMultiplayerLevelControl(roomData.StageId, curLevel)
    self.TxtChangeAdditionDest.text = levelControl.AdditionDest

    for k, v in pairs(self.DifficultyIconGroup) do
        if k == lastLevel then
            v.gameObject:SetActive(true)
            v.transform.position = self.ChangeDifficultyCase1.position
        elseif k == curLevel then
            v.gameObject:SetActive(true)
            v.transform.position = self.ChangeDifficultyCase2.position
        else
            v.gameObject:SetActive(false)
        end
    end

    if XLuaUiManager.IsUiShow("UiMultiplayerRoom") then
        XLuaUiManager.SetMask(true)
        self.AnimChangeDifficulty:PlayTimelineAnimation(function ()
            XLuaUiManager.SetMask(false)
        end)
    end
end

----------------------- 界面方法 -----------------------

function XUiMultiplayerRoom:SwitchButtonState(state)
    for k, v in pairs(self.BtnGroup) do
        v:SetActive(k == state)
    end
end

function XUiMultiplayerRoom:SwitchDifficultyState(diff)
    for k, v in pairs(self.DifficultyImageGroup) do
        v.gameObject:SetActive(k == diff)
    end
end

function XUiMultiplayerRoom:GetCurRole()
    local roomData = XDataCenter.RoomManager.RoomData

    if not roomData then
        return nil
    end

    for k, v in pairs(roomData.PlayerDataList) do
        if v.Id == XPlayer.Id then
            return v
        end
    end
end

function XUiMultiplayerRoom:GetLeaderRole()
    local roomData = XDataCenter.RoomManager.RoomData
    for k, v in pairs(roomData.PlayerDataList) do
        if v.Leader then
            return v
        end
    end
end

function XUiMultiplayerRoom:CheckAllReady()
    local roomData = XDataCenter.RoomManager.RoomData
    for k, v in pairs(roomData.PlayerDataList) do
        if not v.Leader and v.State ~= XDataCenter.RoomManager.PlayerState.Ready then
            return false
        end
    end
    return true
end

function XUiMultiplayerRoom:CheckListFullAndAllReady()
    local roomData = XDataCenter.RoomManager.RoomData
    return roomData.State == 0 and #roomData.PlayerDataList == MAX_PLAYER_COUNT and self:CheckAllReady()
end

-- 界面刷新
function XUiMultiplayerRoom:Refresh()
    local roomData = XDataCenter.RoomManager.RoomData
    local stageId = roomData.StageId
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    self.TxtTitle.text = stageCfg.Name

    --体力&门票
    if XDataCenter.FubenManager.CheckCanFlop(stageId) and stageInfo.Type == XDataCenter.FubenManager.StageType.BossOnline then
        self.TxtActionConsume.text = XDataCenter.FubenManager.GetStageActionPointConsume(stageId)
        local itemId = XDataCenter.FubenManager.GetFlopConsumeItemId(stageId)
        local item = XDataCenter.ItemManager.GetItem(itemId)
        local count = item and item:GetCount() or 0
        self.TxtTicket.text = count
        local flopIcon = XDataCenter.ItemManager.GetItemIcon(itemId)
        self.RImgFlopIcon:SetRawImage(flopIcon)
        self.PanelFlopItem.gameObject:SetActive(true)
    else
        local stage = XDataCenter.FubenManager.GetStageCfg(stageId)
        self.TxtActionConsume.text = stage.RequireActionPoint
        self.PanelFlopItem.gameObject:SetActive(false)
    end
    self.TxtActionPoint.text = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.ActionPoint).Count

    --按钮状态
    self:RefreshButtonStatus()

    self:RefreshChars()

    self:RefreshTips()

    self:RefreshSameCharTips()

    self:RefreshDifficultyPanel()

    self:RefreshAbilityLimit()
end

function XUiMultiplayerRoom:CloseAllOperationPanel(exceptIndex)
    for k, v in pairs(self.GridList) do
        if not exceptIndex or k ~= exceptIndex then
            v:CloseOperationPanelAndInvitePanel()
        end
    end
end

-- 角色面板初始化
function XUiMultiplayerRoom:InitCharItems()
    local caseList = {
        self.RoomCharCase1,
        self.RoomCharCase2,
        self.RoomCharCase3,
    }

    self.GridList = {}
    for i = 1, MAX_PLAYER_COUNT do
        local ui
        if i == 1 then
            ui = self.GridMulitiplayerRoomChar
        else
            ui = CS.UnityEngine.GameObject.Instantiate(self.GridMulitiplayerRoomChar)
        end
        ui.transform:SetParent(caseList[i], false)
        ui.transform:Reset()
        local grid = XUiGridMulitiplayerRoomChar.New(ui, self, i, self.RoleModelList[i])
        self.GridList[i] = grid
    end
end

function XUiMultiplayerRoom:InitDifficultyButtons()
    self.DifficultyImageGroup = {
        [DifficultyType.Normal] = self.ImgDifficultyNormal,
        [DifficultyType.Hart] = self.ImgDifficultyHart,
        [DifficultyType.Nightmare] = self.ImgDifficultyNightmare,
    }
    self.DifficultyButtonGroup = {
        [DifficultyType.Normal] = XUiGridMultiplayerDifficultyItem.New(self.GridDifficultyNormal, DifficultyType.Normal, handler(self, self.SelectDifficulty)),
        [DifficultyType.Hart] = XUiGridMultiplayerDifficultyItem.New(self.GridDifficultyHart, DifficultyType.Hart, handler(self, self.SelectDifficulty)),
        [DifficultyType.Nightmare] = XUiGridMultiplayerDifficultyItem.New(self.GridDifficultyNightmare, DifficultyType.Nightmare, handler(self, self.SelectDifficulty)),
    }
    self.DifficultyIconGroup = {
        [DifficultyType.Normal] = self.IconNormal,
        [DifficultyType.Hart] = self.IconHart,
        [DifficultyType.Nightmare] = self.IconNightmare,
    }
end

function XUiMultiplayerRoom:GetGrid(playerId)
    local grid = self.GridMap[playerId]
    if not grid then
        if playerId == XPlayer.Id then
            grid = self.GridList[1]
            self.GridMap[playerId] = grid
        else
            for i = 2, MAX_PLAYER_COUNT do
                if not self.GridList[i].PlayerData then
                    grid = self.GridList[i]
                    self.GridMap[playerId] = grid
                    break
                end
            end
        end
    end
    if not grid then
        XLog.Error("XUiMultiplayerRoom:GetGrid error, there is no empty grid")
    end
    return grid
end

function XUiMultiplayerRoom:RefreshButtonStatus()
    local roomData = XDataCenter.RoomManager.RoomData
    local role = self:GetCurRole()
    if role and role.Leader then
        if self:CheckAllReady() then
            self:SwitchButtonState(ButtonState.Fight)
        else
            self:SwitchButtonState(ButtonState.Waiting)
        end
    else
        if role.State == XDataCenter.RoomManager.PlayerState.Ready then
            self:SwitchButtonState(ButtonState.CancelReady)
        else
            self:SwitchButtonState(ButtonState.Ready)
        end
    end

    if XDataCenter.FubenManager.CheckMultiplayerLevelControl(roomData.StageId) then
        self:SwitchDifficultyState(roomData.StageLevel)
    else
        self:SwitchDifficultyState(0)
    end

    self.BtnAutoMatch.ButtonState = roomData.AutoMatch and CS.UiButtonState.Select or CS.UiButtonState.Normal
end

function XUiMultiplayerRoom:RefreshChars()
    local roomData = XDataCenter.RoomManager.RoomData
    for k, v in pairs(roomData.PlayerDataList) do
        local grid = self:GetGrid(v.Id)
        grid:InitCharData(v)
    end

    for k, v in pairs(self.GridList) do
        if not v.PlayerData then
            v:InitEmpty()
        end
    end
end

function XUiMultiplayerRoom:RefreshDifficultyPanel()
    local roomData = XDataCenter.RoomManager.RoomData
    if XDataCenter.FubenManager.CheckMultiplayerLevelControl(roomData.StageId) then
        for k, v in pairs(self.DifficultyButtonGroup) do
            local levelControl = XDataCenter.FubenManager.GetStageMultiplayerLevelControl(roomData.StageId, k)
            v:Refresh(levelControl)
            v:SetSelected(roomData.StageLevel == k)
        end
        local levelControl = XDataCenter.FubenManager.GetStageMultiplayerLevelControl(roomData.StageId, roomData.StageLevel)
        self.TxtAdditionDest.text = levelControl.AdditionDest
        self.TxtRecommend.text = CS.XTextManager.GetText("MultiplayerRoomRecommendAbility", levelControl.RecommendAbility)
    else
        self.TxtAdditionDest.gameObject:SetActive(false)
        self.TxtRecommend.gameObject:SetActive(false)
    end
end

function XUiMultiplayerRoom:RefreshAbilityLimit()
    local roomData = XDataCenter.RoomManager.RoomData
    self.TxtAbilityLimit.text = roomData.AbilityLimit
    self.TxtCurAbilityLimit.text = roomData.AbilityLimit
end

function XUiMultiplayerRoom:RefreshAbilityLimitPanel()
    local roomData = XDataCenter.RoomManager.RoomData
    local levelControl = XDataCenter.FubenManager.GetStageMultiplayerLevelControl(roomData.StageId, roomData.StageLevel)
    local defaultAbilityLimit = roomData.AbilityLimit > 0 and roomData.AbilityLimit or levelControl and levelControl.RecommendAbility or 0
    self.InFSetAbilityLimit.text = defaultAbilityLimit
    self.TxtCurAbilityLimit.text = roomData.AbilityLimit
end

function XUiMultiplayerRoom:CheckSameCharacterByMyself()
    local roomData = XDataCenter.RoomManager.RoomData
    local curRole = self:GetCurRole()
    if not curRole then 
        return false
    end

    for k, v in pairs(roomData.PlayerDataList) do
        if v.Id ~= curRole.Id
        and (v.Leader or v.State == XDataCenter.RoomManager.PlayerState.Ready)
        and v.FightNpcData.Character.Id == curRole.FightNpcData.Character.Id then
            return true
        end
    end
end

function XUiMultiplayerRoom:RefreshChatMsg(chatDataLua)
    if chatDataLua.MsgType == ChatMsgType.Emoji then
        self.TxtMessageContent.text = string.format("%s:%s", chatDataLua.NickName, CSXTextManagerGetText("EmojiText"))
    else
        self.TxtMessageContent.text = string.format("%s:%s", chatDataLua.NickName, chatDataLua.Content)
    end

    if not string.IsNilOrEmpty(chatDataLua.CustomContent) then
        self.TxtMessageContent.supportRichText = true
    else
        self.TxtMessageContent.supportRichText = false
    end

    if XUiHelper.CalcTextWidth(self.TxtMessageContent) > MAX_CHAT_WIDTH then
        self.TxtMessageContent.text = string.Utf8Sub(self.TxtMessageContent.text, 1, CHAT_SUB_LENGTH) .. [[......]]
    end
end

----------------------- 职业提示 -----------------------
function XUiMultiplayerRoom:RefreshTips()
    for k, v in pairs(self.TipsList) do
        v:SetActive(false)
    end

    local roomData = XDataCenter.RoomManager.RoomData
    local stageTemplate = XDataCenter.FubenManager.GetStageCfg(roomData.StageId)

    if stageTemplate.NeedJobType then
        local needJobCount = {}
        for k, v in pairs(stageTemplate.NeedJobType) do
            if not needJobCount[v] then
                needJobCount[v] = 0
            end
            needJobCount[v] = needJobCount[v] + 1
        end

        local index = 0
        for k, v in pairs(needJobCount) do
            local jobCount = self:GetJopCount(k)
            if jobCount < v then
                index = index + 1
                local tips = self.TipsList[index]
                if not tips then
                    local ui = CS.UnityEngine.GameObject.Instantiate(self.PanelTips, self.PanelTipsContainer)
                    tips = XUiTips.New(ui)
                    self.TipsList[index] = tips
                end
                tips:SetActive(true)
                tips:SetText(self:GetJobTips(k, v - jobCount))
            end
        end
    end
end

function XUiMultiplayerRoom:RefreshSameCharTips()
    local roomData = XDataCenter.RoomManager.RoomData
    for _, v in pairs(roomData.PlayerDataList) do
        local grid = self:GetGrid(v.Id)
        grid:ShowSameCharTips(false)
        for _, v2 in pairs(roomData.PlayerDataList) do
            if v.Id ~= v2.Id and v.FightNpcData.Character.Id == v2.FightNpcData.Character.Id then
                grid:ShowSameCharTips(true)
                break
            end
        end
    end
end

function XUiMultiplayerRoom:GetJopCount(type)
    local count = 0
    local roomData = XDataCenter.RoomManager.RoomData
    for k, v in pairs(roomData.PlayerDataList) do
        local charId = v.FightNpcData.Character.Id
        local quality = v.FightNpcData.Character.Quality
        local npcId = XCharacterConfigs.GetCharNpcId(charId, quality)
        local npcTemplate = XCharacterConfigs.GetNpcTemplate(npcId)
        if type == npcTemplate.Type then
            count = count + 1
        end
    end
    return count
end

function XUiMultiplayerRoom:GetJobTips(type, count)
    if type == 1 then
        return CS.XTextManager.GetText("CharacterLackDps", count)
    elseif type == 2 then
        return CS.XTextManager.GetText("CharacterLackTank", count)
    elseif type == 3 then
        return CS.XTextManager.GetText("CharacterLackCure", count)
    end
end

function XUiMultiplayerRoom:SelectDifficulty(diff)
    XDataCenter.RoomManager.SetStageLevel(diff)
end

----------------------- 倒计时 -----------------------
function XUiMultiplayerRoom:CheckLeaderCountDown()
    if self.Timer then
        if not self:CheckListFullAndAllReady() then
            self:StopTimer()
        end
    else
        if self:CheckListFullAndAllReady() then
            self:StartTimer()
        end
    end
end

function XUiMultiplayerRoom:StartTimer()
    self.StartTime = XTime.Now()
    self.Timer = CS.XScheduleManager.ScheduleForever(handler(self, self.UpdateTimer), CS.XScheduleManager.SECOND)
    local role = self:GetLeaderRole()
    self.CurCountDownGrid = self:GetGrid(role.Id)
    self:UpdateTimer()
end

function XUiMultiplayerRoom:StopTimer()
    if self.CurCountDownGrid then
        self.CurCountDownGrid:ShowCountDownPanel(false)
        self.CurCountDownGrid = nil
    end
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiMultiplayerRoom:UpdateTimer()
    local elapseTime = XTime.Now() - self.StartTime
    if elapseTime > self.RoomKickCountDownShowTime then
        self.CurCountDownGrid:ShowCountDownPanel(true)
        local leftTime = self.RoomKickCountDownTime - elapseTime
        self.CurCountDownGrid:SetCountDownTime(leftTime)
    end
end

----------------------- 按钮回调 -----------------------

function XUiMultiplayerRoom:OnToggleQuickMatchClick(eventData)
    XDataCenter.RoomManager.Ready()
end

function XUiMultiplayerRoom:OnBtnFightClick(eventData)
    local role = self:GetCurRole()
    if not role or not role.Leader then
        return
    end

    if self:CheckSameCharacterByMyself() then
        local msg = CS.XTextManager.GetText("MultiplayerRoomTeamHasSameCharacter")
        XUiManager.TipMsg(msg)
        return
    end

    XDataCenter.RoomManager.Enter(function(response)
        if response.Code ~= XCode.Success then
            XUiManager.TipCode(response.Code)
            return
        -- else
        --     self.EnterFightCb()
        end
    end)
end

function XUiMultiplayerRoom:OnBtnCancelReadyClick(eventData)
    XDataCenter.RoomManager.CancelReady(function(code)
        XUiManager.TipCode(code)
        if code ~= XCode.Success then
            return
        end
        self.BtnReady.gameObject:SetActive(true)
        self.BtnCancelReady.gameObject:SetActive(false)
    end)
end

function XUiMultiplayerRoom:OnBtnReadyClick(eventData)
    if self:CheckSameCharacterByMyself() then
        local msg = CS.XTextManager.GetText("MultiplayerRoomTeamHasSameCharacter")
        XUiManager.TipMsg(msg)
        return
    end
    XDataCenter.RoomManager.Ready()
end

function XUiMultiplayerRoom:OnBtnChatClick(eventData)
    XLuaUiManager.Open("UiChatServeMain", false, ChatChannelType.Room, ChatChannelType.World)
end

function XUiMultiplayerRoom:OnBtnChangeDifficultyClick(eventData)

end

function XUiMultiplayerRoom:OnBtnBackClick(eventData)
    self:CloseAllOperationPanel()
    local title = CS.XTextManager.GetText("TipTitle")
    local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
    XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
        XDataCenter.RoomManager.Quit(function(res)
            XLuaUiManager.Close("UiMultiplayerRoom")
        end)
    end)
end

function XUiMultiplayerRoom:OnBtnMainUiClick(eventData)
    self:CloseAllOperationPanel()
    XLuaUiManager.RunMain()
end

function XUiMultiplayerRoom:OnBtnDifficultySelectClick(eventData)
    self:CloseAllOperationPanel()
    local curRole = self:GetCurRole()
    if not curRole or not curRole.Leader then
        local msg = CS.XTextManager.GetText("MultiplayerRoomCanNotSelectDifficulty")
        XUiManager.TipMsg(msg)
        return
    end
    self.PanelDifficulty.gameObject:SetActive(true)
    self:PlayAnimation("DifficultyEnable")
    self:RefreshDifficultyPanel()
end

function XUiMultiplayerRoom:OnBtnCloseDifficultyClick(eventData)
    self.PanelDifficulty.gameObject:SetActive(false)
end

function XUiMultiplayerRoom:OnBtnSetAbilityLimitClick(eventData)
    self:CloseAllOperationPanel()
    local curRole = self:GetCurRole()
    if not curRole or not curRole.Leader then
        local msg = CS.XTextManager.GetText("MultiplayerRoomCanNotSetAbilityLimit")
        XUiManager.TipMsg(msg)
        return
    end
    self.PanelAbilityLimit.gameObject:SetActive(true)
    self:PlayAnimation("AbilityLimitEnable")
    self:RefreshAbilityLimitPanel()
end

function XUiMultiplayerRoom:OnBtnCloseAbilityLimitClick(eventData)
    self.PanelAbilityLimit.gameObject:SetActive(false)
end

function XUiMultiplayerRoom:OnBtnAutoMatchClick(eventData)
    self:CloseAllOperationPanel()
    local curRole = self:GetCurRole()
    if not curRole or not curRole.Leader then
        local msg = CS.XTextManager.GetText("MultiplayerRoomCanNotChangeAutoMatch")
        XUiManager.TipMsg(msg)
        -- 重置按钮状态
        local roomData = XDataCenter.RoomManager.RoomData
        self.BtnAutoMatch.ButtonState = roomData.AutoMatch and CS.UiButtonState.Select or CS.UiButtonState.Normal
        return
    end
    local roomData = XDataCenter.RoomManager.RoomData
    XDataCenter.RoomManager.SetAutoMatch(not roomData.AutoMatch)
end

function XUiMultiplayerRoom:OnBtnConfirmSetAbilityLimitClick(eventData)
    local abilityLimit = tonumber(self.InFSetAbilityLimit.text)
    if not abilityLimit or abilityLimit < 0 then
        local msg = CS.XTextManager.GetText("MultiplayerRoomAbilityNotLegal")
        XUiManager.TipMsg(msg)
        return
    end
    abilityLimit = math.floor(abilityLimit)
    local _self = self
    XDataCenter.RoomManager.SetAbilityLimit(abilityLimit, function()
        _self.PanelAbilityLimit.gameObject:SetActive(false)
    end)
end
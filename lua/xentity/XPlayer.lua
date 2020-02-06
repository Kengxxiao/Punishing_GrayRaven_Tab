local setmetatable = setmetatable
local table = table
local math = math

local tableInsert = table.insert
local mathFloor = math.floor
local mathCeil = math.ceil

local GETTER_KEY_PREFIX = "Getter"

local METHOD_NAME = {
    ChangePlayerName = "ChangePlayerNameRequest",
    ChangePlayerSign = "ChangePlayerSignRequest",
    ChangePlayerMark = "ChangePlayerMarkRequest",
    ChangePlayerBirthday = "ChangePlayerBirthdayRequest",
    ChangePlayerHeadPortrait = "ChangePlayerHeadPortraitRequest",
    ChangePlayerMedal = "SetCurrentMedalRequest",
    ChangeCommunication = "ChangeCommunicationRequest",
    ChangeAppearance = "SetAppearanceRequest", -- 设置展示角色
}

local NextChangeNameTime

local PlayerData = {}               -- 玩家数据，外部只读               
local Player = {}                   -- 玩家对象，公有方法
local Getter = {}                   -- 属性get

local function New()
    return setmetatable({}, {
        __metatable = "readonly",
        __index = function(tab, k)
            if Player[k] ~= nil then
                return Player[k]
            end

            local getterKey = GETTER_KEY_PREFIX .. k
            if Getter[getterKey] then
                return Getter[getterKey]()
            end

            return PlayerData[k]
        end,
        __newindex = function(tab, k, v)
            XLog.Error("attempt to update a readonly object")
        end,
    })
end

function Player.Init(playerData, headPortraitList)
    PlayerData = playerData
    NextChangeNameTime = playerData.ChangeNameTime + XPlayerManager.PlayerChangeNameInterval
    CS.Movie.XMovieManager.Instance.PlayerName = PlayerData.Name
    Player.AsyncHeadPortraitIds(headPortraitList,false)
end

function Getter.GetterExp()
    local item = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.TeamExp)
    if not item then
        return 0
    else
        return item:GetCount()
    end
end

function Player.IsNewPlayerTaskUIGroupActive(index)
    return (PlayerData.NewPlayerTaskActiveUi & (1 << index)) > 0
end

function Player.IsMark(id)
    local marks = PlayerData.Marks or {}
    for _, v in pairs(marks) do
        if v == id then
            return true
        end
    end

    return false
end


--检测检测通讯系统
function Player.IsCommunicationMark(id)
    local marks = PlayerData.Communications or {}
    for _, v in pairs(marks) do
        if v == id then
            return true
        end
    end

    return false
end

function Player.IsGetDailyActivenessReward(index)
    index = index - 1
    return (PlayerData.DailyActivenessRewardStatus & (1 << index)) > 0
end

function Player.IsGetWeeklyActivenessReward(index)
    index = index - 1
    return (PlayerData.WeeklyActivenessRewardStatus & (1 << index)) > 0
end

function Player.HandlerPlayLevelUpAnimation()
    if Player.NeedPlayLevelUp then
        XLuaUiManager.Open("UiPlayerUp", Player.LevelUpAnimationData.OldLevel, Player.LevelUpAnimationData.NewLevel)
        Player.NeedPlayLevelUp = false
        Player.LevelUpAnimationData = nil
        return true
    end
    return false
end

-----------------服务端数据同步-----------------
-- 看板娘Id
function Player.SetDisplayCharId(charId)
    PlayerData.DisplayCharId = charId
end

function Player.AddMark(id)
    if not PlayerData.Marks then
        PlayerData.Marks = {}
    end

    tableInsert(PlayerData.Marks, id)
end

--添加通讯系统标志
function Player.AddCommunicationMark(id)
    if not PlayerData.Communications then
        PlayerData.Communications = {}
    end

    tableInsert(PlayerData.Communications, id)
end

function Player.SetNewPlayerTaskActiveUi(result)
    PlayerData.NewPlayerTaskActiveUi = result
end

function Player.SetPlayerLikes(count)
    PlayerData.Likes = count
end

function Player.GetUnlockedHeadPortraitIds()
    local list = {}

    local headPortraitList = XPlayerManager.GetHeadPortraitData()
    for k, v in pairs(headPortraitList) do
        table.insert(list, v)
    end


    table.sort(list, function(headA, headB)
        local weightA = Player.IsHeadPortraitUnlock(headA.Id) and 1 or 0
        local weightB = Player.IsHeadPortraitUnlock(headB.Id) and 1 or 0
        if weightA == weightB then
            return headA.Priority > headB.Priority
        end
        return weightA > weightB
    end)

    return list
end

function Player.GetUnlockedMedalInfoById(id)
    return PlayerData.UnlockedMedalInfos[id]
end

-- 功能开发标记
XRpc.NotifyPlayerMarks = function(data)
    XTool.LoopCollection(data.Ids, function(id)
        Player.AddMark(id)
    end)
end

-- 玩家名字
XRpc.NotifyPlayerName = function(data)
    PlayerData.Name = data.Name
    CS.Movie.XMovieManager.Instance.PlayerName = PlayerData.Name
end

-- 新手目标相关
XRpc.NotifyNewPlayerTaskStatus = function(data)
    PlayerData.NewPlayerTaskActiveDay = data.NewPlayerTaskActiveDay
    Player.SetNewPlayerTaskActiveUi(data.NewPlayerTaskActiveUi)
    XEventManager.DispatchEvent(XEventId.EVENT_NEWBIETASK_DAYCHANGED)
    local maxTab = #XTaskConfig.GetNewPlayerTaskGroupTemplate()
    local activeDay = (data.NewPlayerTaskActiveDay > maxTab) and maxTab or data.NewPlayerTaskActiveDay
    XDataCenter.TaskManager.SaveNewPlayerHint(XDataCenter.TaskManager.NewPlayerLastSelectTab, activeDay)
end

XRpc.NotifyActivenessStatus = function(data)
    PlayerData.DailyActivenessRewardStatus = data.DailyActivenessRewardStatus
    PlayerData.WeeklyActivenessRewardStatus = data.WeeklyActivenessRewardStatus
end

-- 玩家升级
XRpc.NotifyPlayerLevel = function(data)
    -- local oldLevel = PlayerData.Level
    -- if not CS.XFight.Instance then
    --     XTipManager.Add(function()
    --         --CS.XUiManager.DialogManager:Push("UiPlayerUp", false, false, oldLevel, data.Level)
    --         XLuaUiManager.Open("UiPlayerUp", oldLevel, data.Level)
    --     end)
    -- end
    if PlayerData.Level >= data.Level then
        return
    end
    Player.LevelUpAnimationData = {
        OldLevel = PlayerData.Level,
        NewLevel = data.Level
    }
    PlayerData.Level = data.Level
    Player.NeedPlayLevelUp = true
    XEventManager.DispatchEvent(XEventId.EVENT_PLAYER_LEVEL_CHANGE, data.Level)
end

XRpc.NotifyDailyReciveGiftCount = function(data)
    PlayerData.DailyReceiveGiftCount = data.DailyReceiveGiftCount
end

XRpc.NotifyTips = function(res)
    XUiManager.TipCode(res.Code)
end
-----------------服务端数据同步-----------------
-----------------服务端接口方法-----------------
local DoChangeResultError = function(code, nextCanChangeTime)
    if code == XCode.PlayerDataManagerChangeNameTimeLimit then
        NextChangeNameTime = nextCanChangeTime

        local timeLimit = nextCanChangeTime - XTime.GetServerNowTimestamp()
        local hour = mathFloor(timeLimit / 3600)
        local minute = mathCeil(timeLimit % 3600 / 60)

        if minute == 60 then
            hour = hour + 1
            minute = 0
        end

        XUiManager.TipCode(code, hour, minute)
        return
    end

    XUiManager.TipCode(code)
end

function Player.ChangeName(name, cb)
    if NextChangeNameTime > XTime.GetServerNowTimestamp() then
        DoChangeResultError(XCode.PlayerDataManagerChangeNameTimeLimit, NextChangeNameTime)
        return
    end

    XNetwork.Call(METHOD_NAME.ChangePlayerName, { Name = name },
    function(response)
        if response.Code == XCode.Success then
            NextChangeNameTime = response.NextCanChangeTime
            PlayerData.ChangeNameTime = response.NextCanChangeTime - XPlayerManager.PlayerChangeNameInterval
            cb()
            return
        end

        DoChangeResultError(response.Code, response.NextCanChangeTime)
    end)
end

local CheckCanChangeBirthday = function()
    return not (PlayerData.Birthday and PlayerData.Birthday.Mon and PlayerData.Birthday.Day)
end

--修改生日
function Player.ChangeBirthday(mon, day, cb)
    if not CheckCanChangeBirthday() then
        XUiManager.TipCode(XCode.PlayerDataManagerBirthdayAlreadySet)
        return
    end

    XNetwork.Call(METHOD_NAME.ChangePlayerBirthday, { Mon = mon, Day = day },
    function(response)
        if response.Code ~= XCode.Success then
            XUiManager.TipCode(response.Code)
            return
        end

        PlayerData.Birthday = {
            Mon = mon,
            Day = day
        }

        cb()
    end)
end

--保存展示信息
function Player.SetAppearance(characterIds, cb)
    XNetwork.Call(METHOD_NAME.ChangeAppearance, { Characters = characterIds }, function(res)
        if res.Code ~= XCode.Success then
            XUiManager.TipCode(res.Code)
            return
        end
        XUiManager.TipText("SetAppearanceSuccess")
        PlayerData.ShowCharacters = characterIds
        if cb then
            cb()
        end
    end)
end

--添加标记
function Player.ChangeMarks(id)
    Player.AddMark(id)
    XNetwork.Call(METHOD_NAME.ChangePlayerMark, { MaskId = id }, function(res)
        if res.Code == XCode.Success then
            -- Player.AddMark(id)
        end
    end)
end

--添加标记
function Player.ChangeCommunicationMarks(id)
    Player.AddCommunicationMark(id)
    XNetwork.Call(METHOD_NAME.ChangeCommunication, { Id = id }, function(res)
        if res.Code == XCode.Success then

        end
    end)
end


function Player.ChangeSign(msg, cb)
    XNetwork.Call(METHOD_NAME.ChangePlayerSign, { Msg = msg },
    function(response)
        if response.Code ~= XCode.Success then
            XUiManager.TipCode(response.Code)
            return
        end

        PlayerData.Sign = msg
        cb()
    end)
end

function Player.ChangeHeadPortrait(id, cb)
    XNetwork.Call(METHOD_NAME.ChangePlayerHeadPortrait, { HeadPortraitId = id },
    function(response)
        if (response.Code == XCode.Success) then
            PlayerData.CurrHeadPortraitId = id
            cb()
        else
            XUiManager.TipCode(response.Code)
        end
    end)
end

function Player.ChangeMedal(id, cb)
    XNetwork.Call(METHOD_NAME.ChangePlayerMedal, { Id = id },
        function(response)
            if (response.Code == XCode.Success) then
                PlayerData.CurrMedalId = id
                cb()
            else
                XUiManager.TipCode(response.Code)
            end
        end)
end

function Player.IsHeadPortraitUnlock(headId)
    if not PlayerData.UnlockedHeadPortraitIds then return false end
    return PlayerData.UnlockedHeadPortraitIds[headId]
end

function Player.IsMedalUnlock(medalId)
    if not PlayerData.UnlockedMedalInfos then return false end
    return PlayerData.UnlockedMedalInfos[medalId] and true or false
end

function Player.AsyncHeadPortraitIds(headPortraitIds,IsAddNew)
    if not PlayerData.UnlockedHeadPortraitIds then PlayerData.UnlockedHeadPortraitIds = {} end
    for k, v in pairs(headPortraitIds or {}) do
        PlayerData.UnlockedHeadPortraitIds[v] = true
        
        if IsAddNew then 
            XDataCenter.HeadPortraitManager.AddNewHeadPortrait(v)
        end
    end
end

function Player.AsyncMedalIds(MedalIds,IsAddNew)
    if not PlayerData.UnlockedMedalInfos then PlayerData.UnlockedMedalInfos = {} end
    for k, v in pairs(MedalIds or {}) do
        if IsAddNew then 
            XDataCenter.MedalManager.AddNewMedal(v)
            PlayerData.UnlockedMedalInfos[MedalIds.Id] = MedalIds
            PlayerData.NewMedalInfo = MedalIds
        else
            PlayerData.UnlockedMedalInfos[v.Id] = v
        end
    end
end
-----------------服务端接口方法-----------------
XPlayer = XPlayer or New()

XRpc.NotifyUnlockedHeadPortraitIds = function(data)
    if not data then return end
    Player.AsyncHeadPortraitIds(data.UnlockedHeadPortraitIds,true)
    XEventManager.DispatchEvent(XEventId.EVENT_HEAD_PORTRAIT_NOTIFY)
end
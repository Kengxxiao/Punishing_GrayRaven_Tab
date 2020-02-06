XPlayerManager = XPlayerManager or {}

local TABLE_PLAYER = "Share/Player/Player.tab"
local TABLE_HEADPORTRAITS = "Share/HeadPortrait/HeadPortrait.tab"

local PlayerTable
local HeadPortrait

local HeadPortraitQuality = CS.XGame.Config:GetInt("HeadPortraitQuality")

XPlayerManager.PlayerChangeNameInterval = nil
XPlayerManager.PlayerMaxLevel = 1

function XPlayerManager.Init()
    XPlayerManager.PlayerChangeNameInterval = CS.XGame.Config:GetInt("PlayerChangeNameInterval")
    XPlayerManager.PlayerMaxLevel = CS.XGame.Config:GetInt("PlayerMaxLevel")
    PlayerTable = XTableManager.ReadByIntKey(TABLE_PLAYER, XTable.XTablePlayer, "Level")
    if not PlayerTable then
        XLog.Error("Load Player Table error: " .. TABLE_PLAYER)
    end
    
    HeadPortrait = XTableManager.ReadByIntKey(TABLE_HEADPORTRAITS, XTable.XTableHeadPortrait, "Id")
end

function XPlayerManager.GetHeadPortraitData()
    return HeadPortrait
end

function XPlayerManager.GetHeadPortraitInfoById(id)
    return HeadPortrait[id]
end

function XPlayerManager.GetHeadPortraitNumById(id)
    local num = 0
    local RowNum = 0
    local Ids = XPlayer.GetUnlockedHeadPortraitIds()
    for k,v in pairs(Ids) do
        num = num + 1
        if v.Id == id then
            break
        end
    end
    
    return num
end

function XPlayerManager.GetHeadPortraitQuality()
    return HeadPortraitQuality
end

function XPlayerManager.GetHeadPortraitNameById(id)
    if not HeadPortrait[id] then return "" end
    return HeadPortrait[id].Name
end

function XPlayerManager.GetHeadPortraitImgSrcById(id)
    return HeadPortrait[id].ImgSrc
end


function XPlayerManager.GetHeadPortraitEffectById(id)
    return HeadPortrait[id].Effect
end

function XPlayerManager.GetHeadPortraitLockDescId(id)
    if not HeadPortrait[id] then return "" end
    return HeadPortrait[id].LockDescId
end

function XPlayerManager.GetHeadPortraitDescriptionById(id)
    if not HeadPortrait[id] then return "" end
    return HeadPortrait[id].Description
end

function XPlayerManager.GetHeadPortraitWorldDescById(id)
    if not HeadPortrait[id] then return "" end
    return HeadPortrait[id].WorldDesc
end

function XPlayerManager.GetMaxExp(level)
    local maxExp = 0
    if not PlayerTable[level] then
        XLog.Error("GetMaxExp level error: " .. level)
    else
        maxExp = PlayerTable[level].MaxExp
    end
    return maxExp
end

function XPlayerManager.GetMaxActionPoint(level)
    local maxActp = 0
    if not PlayerTable[level] then
        XLog.Error("GetMaxActionPoint level error: " .. level)
    else
        maxActp = PlayerTable[level].MaxActionPoint
    end
    return maxActp
end

function XPlayerManager.GetMaxFriendCount(level)
    local maxCount = 0
    if not PlayerTable[level] then
        XLog.Error("GetMaxFriendCount level error : " .. level)
    else
        maxCount = PlayerTable[level].MaxFriendCount
    end
    return maxCount
end

function XPlayerManager.GetFreeActionPoint(level)
    local freeActp = 0
    if not PlayerTable[level] then
        XLog.Error("GetFreeActionPoint level error: " .. level)
    else
        freeActp = PlayerTable[level].FreeActionPoint
    end
    return freeActp
end


--==============================--
--desc: 获取玩家信息
--@id: 玩家id
--@cb: 结果回调
--==============================--
function XPlayerManager.GetPlayerInfos(id, cb)
    local req = { id = id }
    XNetwork.Call("GetPlayerInfoRequest", req,
    function(result)
        if result.Code and result.Code ~= XCode.Success then
            XUiManager.TipCode(result.Code)
            return
        end
        if cb then
            cb(result.Code, result.PlayerData)
        end
    end
    )
end
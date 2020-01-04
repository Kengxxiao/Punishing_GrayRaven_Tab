XRoomSingleManager = XRoomSingleManager or {}

XRoomSingleManager.PlayerType = {
    None = 0,
    Firend = 1,
    Guild = 2,
    Stranger = 3,
}

XRoomSingleManager.BtnType = {
    None = 0,
    SelectStage = 1,
    Again = 2,
    Next = 3,
    Main = 4,
}

local FIGHT_EVENT = "Share/Fight/FightEvent.tab"
local FightEventCfg    = {}

function XRoomSingleManager.Init()
    FightEventCfg = XTableManager.ReadByIntKey(FIGHT_EVENT, XTable.XTableFightEvent, "Id")
end

function XRoomSingleManager.GetEventDescByMapId(stageId)
    local eventId = XDataCenter.FubenManager.GetStageCfg(stageId).EventId
    if eventId <= 0 then
        return nil
    end
    local eventCfg = FightEventCfg[eventId]
    if not eventCfg then
        return nil
    end
    return eventCfg.Description
end

function XRoomSingleManager.GetEvenDesc(eventId)
    local eventCfg = FightEventCfg[eventId]
    return eventCfg.Description
end

function XRoomSingleManager.GetBtnText(btnType)
    if    btnType == XRoomSingleManager.BtnType.SelectStage then return CS.XTextManager.GetText("BattleWinSelectStage")
    elseif btnType == XRoomSingleManager.BtnType.Again then return CS.XTextManager.GetText("BattleWinAgain")
    elseif btnType == XRoomSingleManager.BtnType.Next then return CS.XTextManager.GetText("BattleWinNext")
    elseif btnType == XRoomSingleManager.BtnType.Main then return CS.XTextManager.GetText("BattleWinMain")
    else return "" end
end
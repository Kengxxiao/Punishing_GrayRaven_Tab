XTipManager = XTipManager or {}

local TABLE_TIP = "Client/Tip/Tip.tab"
local TeamTipCfg = {}


function XTipManager.Init()
    TeamTipCfg = XTableManager.ReadByIntKey(TABLE_TIP, XTable.XTableTip, "Id")
end

--==============================--
--desc: 获取提示信息
--@id: 提示表 Id
--@return: 1.是否显示提示
--@return: 2.提示描述
--==============================--
function XTipManager.GetTipInfo(id)
    local isShow = false
    local deesc = ""
    if TeamTipCfg[id] then
        local key = tostring(XPlayer.Id) .. id
        if not CS.UnityEngine.PlayerPrefs.HasKey(key) then
            isShow = true
            deesc = TeamTipCfg[id].Description
        end
    end
    return isShow, deesc
end

--==============================--
--desc: 永久取消提示
--@id: 提示表 Id
--==============================--
function XTipManager.DeleteTip(id)
    if TeamTipCfg[id] then
        local key = tostring(XPlayer.Id) .. id
        if not CS.UnityEngine.PlayerPrefs.HasKey(key) then
            CS.UnityEngine.PlayerPrefs.SetString(key, key)
            CS.UnityEngine.PlayerPrefs.Save()
        end
    end
end

--===========================================================================================--
local State = {
    Standby = 1,
    Suspend = 2,
    Playing = 3
}
local state = State.Standby
local first
local last

function XTipManager.Add(tip)
    if not first then
        first = {
            cb = tip,
            next = nil
        }
        last = first
    else
        local next = {
            cb = tip,
            next = nil
        }
        last.next = next
        last = next
    end

    if state == State.Standby then
        XTipManager.Execute()
    end
end

function XTipManager.Execute()
    if first then
        local cb = first.cb
        first = first.next
        state = State.Playing
        cb()
    else
        state = State.Standby
    end
end

function XTipManager.Suspend()
    if state == State.Standby then
        state = State.Suspend
    end
end
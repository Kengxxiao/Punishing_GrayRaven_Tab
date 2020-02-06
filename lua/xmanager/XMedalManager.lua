XMedalManagerCreator = function()
    
    local XMedalManager ={}
    
    XMedalManager.InType = {Normal = 1,GetMedal = 2,OtherPlayer = 3}
    
    XMedalManager.MedalStroyId = CS.XGame.ClientConfig:GetInt("MedalStoryId")
    
    local NewMedalId = nil
    
    function XMedalManager.Init()
    end
    
    function XMedalManager.GetMedals()
        local list = {}
        local meadals = XMedalConfigs.GetMeadalConfigs()
        for k, v in pairs(meadals) do
            table.insert(list, v)
        end
        
        table.sort(list, function(headA, headB)
                local weightA = XPlayer.IsMedalUnlock(headA.Id) and 1 or 0
                local weightB = XPlayer.IsMedalUnlock(headB.Id) and 1 or 0
                if weightA == weightB then
                    return headA.Priority > headB.Priority
                end
                return weightA > weightB
                
            end)
        
        return list
    end
    
    function XMedalManager.GetMeadalInfoById(Id)
        return XPlayer.UnlockedMedalInfos[Id]
    end
    
    function XMedalManager.GetMeadalMaxCount()
        local maxCount = 0
        local medalsList = XMedalConfigs.GetMeadalConfigs()
        for k,v in pairs(medalsList or {}) do
            maxCount = maxCount + 1
        end
        return maxCount
    end
    
    function XMedalManager.CheakMedalStoryIsPlayed()
        if XSaveTool.GetData(string.format("%d%s", XPlayer.Id, "MedalStoryIsPlayed")) then
            return true
        end
        return false 
    end
    
    function XMedalManager.MarkMedalStory()
        if not XSaveTool.GetData(string.format("%d%s", XPlayer.Id, "MedalStoryIsPlayed")) then
            XSaveTool.SaveData(string.format("%d%s", XPlayer.Id, "MedalStoryIsPlayed"),"MedalStoryIsPlayed")
        end
    end
    
    function XMedalManager.CheakHaveNewMedal()
        local meadals = XMedalConfigs.GetMeadalConfigs()
        if not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.Medal) then
            if XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.Medal) then
                for k,v in pairs(meadals) do
                    if XSaveTool.GetData(string.format("%d%s%d", XPlayer.Id, "NewMeadal",v.Id)) then
                        return true
                    end
                end
            end
        end 
        return false 
    end
    
    function XMedalManager.CheakIsNewMedalById(Id)
        if XSaveTool.GetData(string.format("%d%s%d", XPlayer.Id, "NewMeadal",Id)) then
            return true
        end
        return false 
    end
    
    function XMedalManager.SetMedalForOld(Id)
        if XSaveTool.GetData(string.format("%d%s%d", XPlayer.Id, "NewMeadal",Id)) then
            XSaveTool.RemoveData(string.format("%d%s%d", XPlayer.Id, "NewMeadal",Id))
        end
    end
    
    function XMedalManager.AddNewMedal(Id)
        if not XSaveTool.GetData(string.format("%d%s%d", XPlayer.Id, "NewMeadal",Id)) then
            XSaveTool.SaveData(string.format("%d%s%d", XPlayer.Id, "NewMeadal",Id),Id)
        end
    end
    
    function XMedalManager.ShowUnlockTips()
        if NewMedalId then 
            XLuaUiManager.Open("UiMedalUnlockTips",NewMedalId)
            NewMedalId = nil
            return true
        end
        return false
    end
    
    function XMedalManager.SetNewMedalId(id)
        NewMedalId = id
    end
    
    XMedalManager.Init()
    return XMedalManager
end

XRpc.NotifyMedalData = function(data)
    if not data then return end
    XPlayer.AsyncMedalIds(data.MedalInfos,falset)
end

XRpc.NotifyUpdateMedalData = function(data)
    if not data then return end
    XPlayer.AsyncMedalIds(data.UpdateInfo,true)
    XDataCenter.MedalManager.SetNewMedalId(data.UpdateInfo.Id)
    XEventManager.DispatchEvent(XEventId.EVENT_MEDAL_NOTIFY)
end
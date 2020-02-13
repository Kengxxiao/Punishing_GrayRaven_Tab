XFunctionCommunicationManagerCreator = function()

    local XFunctionCommunicationManager = {}


    --已经记录同
    local CommunicationData = {}
    local CommunicationQueen = {}
    local IsCommunicating = false
    local LoveCommunication = {}
    XFunctionCommunicationManager.Type = { Normal = 1, Medal = 2, Love = 3 }

    function XFunctionCommunicationManager.Init()


    end

    --处理战斗结算
    function XFunctionCommunicationManager.HandleFunctionEvent()

        local result = XFunctionCommunicationManager.CheckCommunication(XFunctionCommunicationManager.Type.Normal)
        -- if result then
        --     if not IsCommunicating then
        --         IsCommunicating = true
        --         XFunctionCommunicationManager.ShowNextCommunication()
        --     end
        -- end
        return result
    end

    --检查开启的通讯
    function XFunctionCommunicationManager.SetCommunication()
        local FunctionCommunicationConfig = XCommunicationConfig.GetFunctionCommunicationConfig()

        if FunctionCommunicationConfig then
            for k, v in pairs(FunctionCommunicationConfig) do

                if v.Type == XFunctionCommunicationManager.Type.Love then
                    for i, condition in ipairs(v.ConditionIds) do
                        if XConditionManager.CheckCondition(condition) then
                            LoveCommunication = v
                            break
                        end
                    end

                end

                if not XPlayer.IsCommunicationMark(k) and v.Type ~= XFunctionCommunicationManager.Type.Love then

                    local isOpen = true
                    for i, condition in ipairs(v.ConditionIds) do
                        if not XConditionManager.CheckCondition(condition) then
                            isOpen = false
                            break
                        end
                    end

                    if isOpen then
                        XFunctionCommunicationManager.ReqMarkCommunication(v.Id)
                        if not CommunicationQueen[v.Type] then CommunicationQueen[v.Type] = {} end
                        table.insert(CommunicationQueen[v.Type], v)
                        CommunicationQueen[v.Type].Type = v.Type
                    end
                end
            end

            for k, v in pairs(CommunicationQueen) do
                table.sort(v, function(a, b)
                    return a.Priority < b.Priority
                end)
            end

        end
    end

    function XFunctionCommunicationManager.CheakCommunication(type)
        if #CommunicationQueen[type] <= 0 then
            return false
        end
        return true
    end

    --显示
    function XFunctionCommunicationManager.ShowNextCommunication(type)
        if not CommunicationQueen[type] or #CommunicationQueen[type] <= 0 then
            return false
        end


        local communicationData = XFunctionCommunicationManager.GetNextCommunication(type)

        XLuaUiManager.Open("UiFunctionalOpen", communicationData)

        return true
    end


    function XFunctionCommunicationManager.ShowLoveCommunication(type)
        if not XLuaUiManager.IsUiShow("UiMain") then
            return false
        end


        if not LoveCommunication then
            return false
        end

        local curTime = XTime.GetServerNowTimestamp()
        local startStr = CS.XGame.ClientConfig:GetString("LovelCommunicateStartTime")
        local endStr = CS.XGame.ClientConfig:GetString("LovelCommunicateEndTime")

        if curTime > tonumber(startStr) and curTime < tonumber(endStr) then

            local result = XFunctionCommunicationManager.GetLoveCommunicationTrigger()
            if result == 1 then
                return false
            end
            XFunctionCommunicationManager.SetLoveCommunicationTrigger()

            XLuaUiManager.Open("UiFunctionalOpen", LoveCommunication)
            return true
        end


        return false
    end

    function XFunctionCommunicationManager.SetLoveCommunicationTrigger()
        local key = tostring(XPlayer.Id) .. "_LoveCommunicationTrigger"
        CS.UnityEngine.PlayerPrefs.SetInt(key, 1)
    end

    function XFunctionCommunicationManager.GetLoveCommunicationTrigger()
        local key = tostring(XPlayer.Id) .. "_LoveCommunicationTrigger"
        local result = CS.UnityEngine.PlayerPrefs.GetInt(key, 0)
        return result
    end


    --获取下一个
    function XFunctionCommunicationManager.GetNextCommunication(type)
        if not CommunicationQueen[type] or #CommunicationQueen[type] <= 0 then
            return nil
        end

        return table.remove(CommunicationQueen[type], 1)
    end


    function XFunctionCommunicationManager.IsCommunicating()
        return IsCommunicating
    end


    function XFunctionCommunicationManager.SetCommunicating(isCommunicating)
        IsCommunicating = isCommunicating
    end

    --请求记录
    function XFunctionCommunicationManager.ReqMarkCommunication(id)
        XPlayer.ChangeCommunicationMarks(id)
    end

    XFunctionCommunicationManager.Init()
    return XFunctionCommunicationManager
end
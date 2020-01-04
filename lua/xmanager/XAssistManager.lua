XAssistManagerCreator = function()

    local XAssistManager = {}

    XAssistManager.AssistType = {
        Friend = 1,
        Legion = 2,
        Passer = 3,
        Robot = 4
    }

    local ASSIST_SERVICE_NAME = "XAssistService"
    local METHOD_NAME = {
        GetPasser = "GetPasser",
        ChangeAssistCharacterId= "ChangeAssistCharIdRequest",
    }

    local AssistPlayerData = {}
    local AssistRuleTemplate = {}
    local TABLE_ASSISTRULE = "Share/Fuben/Assist/AssistRule.tab";

    function XAssistManager.NotifyAssistData(data)
        XAssistManager.InitAssistData(data.AssistData)
    end

    function XAssistManager.Init()
        AssistRuleTemplate = XTableManager.ReadByIntKey(TABLE_ASSISTRULE, XTable.XTableAssistRule, "Id")
    end

    function XAssistManager.InitAssistData(assistData)
        if assistData == nil then
            return
        end
        AssistPlayerData = assistData
    end

    function XAssistManager.GetAssistRuleTemplate(id)
        return AssistRuleTemplate[id]
    end

    function XAssistManager.GetAssistCharacterId()
        return AssistPlayerData.AssistCharacterId
    end

    function XAssistManager.ChangeAssistCharacterId(id,cb)
        XNetwork.Call(METHOD_NAME.ChangeAssistCharacterId,{ AssistCharId=id },
                function (response)
                    if response.Code == XCode.Success then
                        AssistPlayerData.AssistCharacterId=id
                        cb(response.Code)
                    else
                        XUiManager.TipCode(response.Code)
                    end
                end)
    end

    XAssistManager.Init()
    return XAssistManager
end

XRpc.NotifyAssistData = function(data)
    XDataCenter.AssistManager.NotifyAssistData(data)
end
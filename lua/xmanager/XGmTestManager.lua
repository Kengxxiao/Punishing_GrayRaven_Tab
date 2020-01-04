local tonumber = tonumber
local table = table
local tableInsert = table.insert
local tableConcat = table.concat

XGmTestManager = XGmTestManager or {}

local DebuggerGm
local DebuggerGmMessage

local function CheckLogin()
    if not XLoginManager.IsLogin() then
        XUiManager.TipError("请先登录")
        return false
    end

    return true
end

XGmTestManager.Graduate = function()
    if not CheckLogin() then
        return
    end

    XNetwork.Call("GraduateRequest", nil, function(res)
        XUiManager.TipCode(res.Code)
    end)
    
end

local function AddGraduate()
    local btn = DebuggerGm:AddButton("一键毕业", function(...)
        if not CheckLogin() then
            return
        end

        XNetwork.Call("GraduateRequest", nil, function(res)
            XUiManager.TipCode(res.Code)
        end)
    end)

    btn.transform.localPosition = CS.UnityEngine.Vector3(-860, 260, 0)
end

local function AddTestMail()
    local btn = DebuggerGm:AddButton("获取测试邮件", function(...)
        if not CheckLogin() then
            return
        end

        XNetwork.Send("GetTestMailRequest", nil)
    end)

    btn.transform.localPosition = CS.UnityEngine.Vector3(-660, 260, 0)
end

local function AddLoginPlatform()
    local btn = DebuggerGm:AddButton("模拟Android", function(...)
        XUserManager.Platform = XUserManager.PLATFORM.Android
    end)

    btn.transform.localPosition = CS.UnityEngine.Vector3(-460, 260, 0)

    local btn = DebuggerGm:AddButton("模拟iOS", function(...)
        XUserManager.Platform = XUserManager.PLATFORM.IOS
    end)

    btn.transform.localPosition = CS.UnityEngine.Vector3(-260, 260, 0)
end

local function AddItemCount()
    local id, count
    local txt = DebuggerGm:AddText("增加道具:")
    txt.transform.localPosition = CS.UnityEngine.Vector3(-860, 180, 0)

    local infId = DebuggerGm:AddInputField("Id", function(value)
        id = value
    end)
    infId.transform.localPosition = CS.UnityEngine.Vector3(-660, 180, 0)

    local infCount = DebuggerGm:AddInputField("Count", function(value)
        count = value
    end)
    infCount.transform.localPosition = CS.UnityEngine.Vector3(-460, 180, 0)

    local btn = DebuggerGm:AddButton("确定", function(...)
        if not id then
            XUiManager.TipError("请输入Id")
            return
        end

        if not count then
            XUiManager.TipError("请输入数量")
            return
        end

        if not CheckLogin() then
            return
        end

        XNetwork.Call("ItemAddCountRequest", { Id = tonumber(id), Count = tonumber(count) }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
            end
        end)
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(-260, 180, 0)
end

local function AddPassStage()
    local id
    local txt = DebuggerGm:AddText("通关至:")
    txt.transform.localPosition = CS.UnityEngine.Vector3(0, 180, 0)

    local infId = DebuggerGm:AddInputField("Id", function(value)
        id = value
    end)
    infId.transform.localPosition = CS.UnityEngine.Vector3(200, 180, 0)

    local btn = DebuggerGm:AddButton("确定", function(...)
        if not id then
            XUiManager.TipError("请输入Id")
            return
        end

        if not CheckLogin() then
            return
        end

        XNetwork.Call("FinishToStageRequest", { StageId = tonumber(id) }, function(res)
            XUiManager.TipCode(res.Code)
        end)
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(400, 180, 0)
end

local function AddTestEquip()
    local btn = DebuggerGm:AddButton("获取所有装备", function(...)
        if not CheckLogin() then
            return
        end

        XNetwork.Send("GetAllEquipRequest", nil)
    end)

    btn.transform.localPosition = CS.UnityEngine.Vector3(-860, 100, 0)
end

local function AddSimulateDraw()
    local drawId, times
    local txt = DebuggerGm:AddText("抽卡测试:")
    txt.transform.localPosition = CS.UnityEngine.Vector3(-860, 20, 0)

    local infId = DebuggerGm:AddInputField("DrawId", function(value)
        drawId = value
    end)
    infId.transform.localPosition = CS.UnityEngine.Vector3(-660, 20, 0)

    local infTimes = DebuggerGm:AddInputField("Times", function(value)
        times = value
    end)
    infTimes.transform.localPosition = CS.UnityEngine.Vector3(-460, 20, 0)

    local btn = DebuggerGm:AddButton("确定", function(...)
        if not drawId then
            XUiManager.TipError("请输入DrawId")
            return
        end

        if not times then
            XUiManager.TipError("请输入次数")
            return
        end

        if not CheckLogin() then
            return
        end

        XNetwork.Call("DrawSimulationRequest", { DrawId = tonumber(drawId), Times = tonumber(times) }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return 
            end

            local content = {}
            tableInsert(content, "------------------------------------------抽卡测试------------------------------------------\n")
            
            tableInsert(content, "普通奖励：\n")
            XTool.LoopCollection(res.NormalRewardList, function(reward)
                tableInsert(content, reward.TemplateId .. "\t\t\t" .. reward.Count .. "\n")
            end)


            tableInsert(content, "保底奖励：\n")
            XTool.LoopCollection(res.BottomRewardList, function(reward)
                tableInsert(content, reward.TemplateId .. "\t\t\t" .. reward.Count .. "\n")
            end)

            tableInsert(content, "触发保底次数：\n")
            tableInsert(content, res.TriggerCount .. "\n")

            tableInsert(content, "------------------------------------------抽卡测试------------------------------------------\n")
            XLog.Debug(tableConcat(content))
        end)
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(-260, 20, 0)
end

local function AddTestPay()
    local txt = DebuggerGm:AddText("充值测试:")
    txt.transform.localPosition = CS.UnityEngine.Vector3(-860, -80, 0)

    local btn = DebuggerGm:AddButton("Pay06", function ()
        XDataCenter.PayManager.Pay("Pay06")
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(-660, -80, 0)

    local btn = DebuggerGm:AddButton("Pay30", function ()
        XDataCenter.PayManager.Pay("Pay30")
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(-460, -80, 0)

    local btn = DebuggerGm:AddButton("Pay68", function ()
        XDataCenter.PayManager.Pay("Pay68")
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(-260, -80, 0)

    local btn = DebuggerGm:AddButton("Pay128", function ()
        XDataCenter.PayManager.Pay("Pay128")
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(-60, -80, 0)

end

local function AddDormEvent()
    local txt = DebuggerGm:AddText("宿舍事件：")
    txt.transform.localPosition = CS.UnityEngine.Vector3(-860, -160, 0)

    local characterId, eventId
    local infId = DebuggerGm:AddInputField("Id", function(value)
        characterId = value
    end)
    infId.transform.localPosition = CS.UnityEngine.Vector3(-660, -160, 0)

    local infId = DebuggerGm:AddInputField("Id", function(value)
        eventId = value
    end)
    infId.transform.localPosition = CS.UnityEngine.Vector3(-460, -160, 0)

    local btn = DebuggerGm:AddButton("确定", function(...)
        XNetwork.Call("GmGetCharacterEventRequest", { CharacterId = tonumber(characterId), EventId = tonumber(eventId) }, function(res)
            local dormCharacterEvent = {
                CharacterId = tonumber(characterId),
                EventList = { [1] = res.Event }
            }
            XDataCenter.DormManager.NotifyDormCharacterAddEvent({ dormCharacterEvent })
        end)
    end)
    btn.transform.localPosition = CS.UnityEngine.Vector3(400, -160, 0)
end

local function InitGmMessage()
    DebuggerGmMessage = CS.XDebugManager.DebuggerCheat
    DebuggerGmMessage.SendAction = function (content)
        XNetwork.Call("SendCheatRequest", {Content = content}, function (response)
            DebuggerGmMessage:SetShowBoxText(response.Massage)
        end)
    end
end

function XGmTestManager.Init()
    DebuggerGm = CS.XDebugManager.DebuggerGm
    AddGraduate()
    AddTestMail()
    AddItemCount()
    AddPassStage()
    AddTestEquip()
    AddSimulateDraw()
    AddTestPay()
    AddDormEvent()
    AddLoginPlatform()
    -- 作弊消息
    InitGmMessage()
end
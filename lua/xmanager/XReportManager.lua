XReportManagerCreater = function()
    local XReportManager = {}

    local LastReportTime = -9999
    local ReportInterval = CS.XGame.Config:GetInt("ReportInterval")

    function XReportManager.Report(playerId, playerName, mainType, subType, msg, playerLevel, chatContent)
        if LastReportTime < 0 then
            LastReportTime = XPlayer.ReportTime
        end
        local now = XTime.GetServerNowTimestamp()
        if now - LastReportTime < ReportInterval then
            local tempTime = (ReportInterval - (now - LastReportTime))
            XUiManager.TipError(CS.XTextManager.GetText("ReportError", tostring(tempTime)))
        else
            XNetwork.Call("ReportRequest", {
                PlayerId = playerId,
                PlayerName = playerName,
                FirstTag = mainType,
                SecondTag = subType,
                Message = msg,
                PlayerLevel = playerLevel,
                ReportMessage = chatContent
            }, function(res)
                if res.Code ~= XCode.Success then
                    XUiManager.TipCode(res.Code)
                    return
                end
                LastReportTime = res.ReportTime
                XUiManager.TipText("ReportFinish")
            end)
        end
    end

    return XReportManager
end
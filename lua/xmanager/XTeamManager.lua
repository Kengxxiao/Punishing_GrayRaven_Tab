XTeamManagerCreator = function()

    local XTeamManager = {}

    local TABLE_TEAMTYPE = "Share/Team/TeamType.tab"
    local TABLE_PATH = "Share/Team/Team.tab"
    local TeamTypeCfg
    local TeamCfg
    local TeamTypeDic = {}

    local MaxPos    -- 默认一个队伍的位置数
    local CaptainPos -- 队长位

    local PlayerTeamGroupData = {}
    local PlayerTeamPrefabData = {}

    local METHOD_NAME = {
        SetTeam = "TeamSetTeamRequest",
    }

    local function SetCaptainPos()
        CaptainPos = 0
        for _, cfg in pairs(TeamCfg) do
            if cfg.IsCaptain and CaptainPos == 0 then
                CaptainPos = cfg.Id
                break
            end
        end
    end

    function XTeamManager.Init()
        TeamTypeCfg = XTableManager.ReadByIntKey(TABLE_TEAMTYPE, XTable.XTableTeamType, "TeamId")
        TeamCfg = XTableManager.ReadByIntKey(TABLE_PATH, XTable.XTableTeam, "Id")
        if TeamTypeCfg == nil then
            XLog.Error("XTeamManager Init Error, filename: " .. TABLE_TEAMTYPE)
            return
        end
        SetCaptainPos()
        if CaptainPos == 0 then
            XLog.Error("XTeamManager Init Error, not Captain: " .. TABLE_PATH)
            return
        end
        XTeamManager.ConstructTeamCfg()

        MaxPos = CS.XGame.Config:GetInt("TeamMaxPos")
    end

    function XTeamManager.ConstructTeamCfg()
        for _, tcfg in pairs(TeamTypeCfg) do
            local typeId = tcfg.TypeId
            if typeId > 0 then
                if TeamTypeDic[typeId] == nil then
                    TeamTypeDic[typeId] = {}
                end

                table.insert(TeamTypeDic[typeId], tcfg)
            end
        end
    end

    -- 通过类型获取限定的队伍配置
    function XTeamManager.GetTeamsByTypeId(typeId)
        if TeamTypeDic[typeId] == nil then
            return nil
        end
        return TeamTypeDic[typeId]
    end

    function XTeamManager.GetTeamId(typeId, stageId)
        local teams = XTeamManager.GetTeamsByTypeId(typeId)
        if teams == nil then
            return nil
        end

        local sectionId = 0
        local chapterId = 0
        if stageId ~= nil then
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
            sectionId = stageInfo.SectionId
            chapterId = stageInfo.ChpaterId
            if sectionId == nil or chapterId == nil then
                return nil
            end
        end

        -- 匹配规则：chapterId, sectionId, stageId 逐级查找，某一项为 nil 时，表示匹配上一级
        for _, val in pairs(teams) do
            if #val.ChapterId <= 0 then
                return val.TeamId         -- 匹配 TypeId
            end

            for _, cId in pairs(val.ChapterId) do
                if chapterId > 0 and cId == chapterId then
                    if #val.SectionId <= 0 then
                        return val.TeamId         -- 匹配 chapterId
                    end

                    for _, sId in pairs(val.SectionId) do
                        if sectionId > 0 and sId == sectionId then
                            if #val.StageId <= 0 then
                                return val.TeamId     -- 匹配 sectionId
                            end

                            for _, stId in pairs(val.StageId) do
                                if stId == stageId then
                                    return val.TeamId     -- 匹配 stageId
                                end
                            end
                        end
                    end
                end
            end
        end

        return nil
    end

    -- 玩家队伍中队长的位置Id
    function XTeamManager.GetTeamCaptainKey(teamId)
        return teamId << 8
    end

    function XTeamManager.GetTeamCaptainPos(teamId)
        if TeamTypeCfg[teamId] == nil then
            XLog.Error("captain teamid error!")
            return
        end

        local posId = 1
        if PlayerTeamGroupData[teamId] ~= nil then
            posId = PlayerTeamGroupData[teamId].CaptainPos
        end
        return posId
    end

    function XTeamManager.GetValidPos(teamData)
        local posId = 1
        for k, v in pairs(teamData) do
            if v > 0 then
                posId = k
                break
            end
        end
        return posId
    end

    function XTeamManager.SetPlayerTeam(curTeam, isPrefab, cb)
        local curTeamId = curTeam.TeamId

        local params = {}
        params.TeamData = {}
        params.TeamId = curTeamId
        XMessagePack.MarkAsTable(params.TeamData)
        for k, v in pairs(curTeam.TeamData) do
            params.TeamData[k] = v
        end
        params.CaptainPos = curTeam.CaptainPos

        local req = { TeamData = params, IsPrefab = isPrefab }
        XNetwork.Call(METHOD_NAME.SetTeam, req, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            local characterCheckTable = {}
            local playerTeamData = isPrefab and PlayerTeamPrefabData or PlayerTeamGroupData
            -- 更新客户端队伍缓存
            if playerTeamData[curTeamId] == nil then
                playerTeamData[curTeamId] = {}
            else
                for _, characterId in pairs(playerTeamData[curTeamId].TeamData) do
                    characterCheckTable[characterId] = true
                end

                for pos, characterId in pairs(curTeam.TeamData) do
                    if not characterCheckTable[characterId] then
                        XEventManager.DispatchEvent(XEventId.EVENT_TEAM_MEMBER_CHANGE, curTeamId, characterId, pos == curTeam.CaptainPos)
                    end
                end
            end
            playerTeamData[curTeamId].TeamId = curTeamId
            playerTeamData[curTeamId].CaptainPos = curTeam.CaptainPos
            playerTeamData[curTeamId].TeamData = curTeam.TeamData

            if cb then cb() end

            XEventManager.DispatchEvent(XEventId.EVENT_TEAM_PREFAB_CHANGE, curTeamId, playerTeamData[curTeamId])
        end)
    end

    function XTeamManager.GetTeamData(teamId)
        if TeamTypeCfg[teamId] == nil then
            XLog.Error("team teamid error!")
            return
        end

        local teamData = nil
        if PlayerTeamGroupData[teamId] ~= nil then
            teamData = PlayerTeamGroupData[teamId].TeamData
        end

        if teamData == nil then
            teamData = {}
            for i = 1, MaxPos do
                teamData[i] = 0
            end
        end
        return teamData
    end
    
    function XTeamManager.GetTeamCaptainPos(teamId)
        if TeamTypeCfg[teamId] == nil then
            XLog.Error("team teamid error!")
            return
        end

        local captainPos = XTeamManager.GetCaptainPos()
        if PlayerTeamGroupData[teamId] ~= nil then
            captainPos = PlayerTeamGroupData[teamId].CaptainPos
        end
        return captainPos
    end

    function XTeamManager.GetTeamCaptainId(teamId)
        if TeamTypeCfg[teamId] == nil then
            XLog.Error("team teamid error!")
            return
        end

        if PlayerTeamGroupData[teamId] == nil then
            return nil
        end

        local captainPos = PlayerTeamGroupData[teamId].CaptainPos
        return PlayerTeamGroupData[teamId].TeamData[captainPos]
    end

    function XTeamManager.GetPlayerTeam(typeId, stageId)
        local curTeamId = XTeamManager.GetTeamId(typeId, stageId)
        if curTeamId == nil then
            XLog.Error("team id is nil!")
            return nil
        end

        local CurTeam = {
            ["TeamId"] = curTeamId,
            ["TeamData"] = XTeamManager.GetTeamData(curTeamId),
            ["CaptainPos"] = XTeamManager.GetTeamCaptainPos(curTeamId)
        }
        return CurTeam
    end

    function XTeamManager.CheckInTeam(characterId)
        local typeId = CS.XGame.Config:GetInt("TypeIdMainLine")
        local curTeamId = XTeamManager.GetTeamId(typeId)
        if curTeamId == nil then
            XLog.Error("team id is nil!")
            return nil
        end

        local teamData = XTeamManager.GetTeamData(curTeamId)
        for k, v in pairs(teamData) do
            if characterId == v then
                return true
            end
        end
        return false
    end

    function XTeamManager.GetInTeamCheckTable()
        local inTeamCheckTable = {}

        local typeId = CS.XGame.Config:GetInt("TypeIdMainLine")
        local curTeamId = XTeamManager.GetTeamId(typeId)
        local teamData = XTeamManager.GetTeamData(curTeamId)
        for _, v in pairs(teamData) do
            if v > 0 then
                inTeamCheckTable[v] = true
            end
        end

        return inTeamCheckTable
    end

    function XTeamManager.InitTeamGroupData(teamGroupData)
        if teamGroupData == nil then
            return
        end

        local teamGroupTemp = {}

        for key, value in pairs(teamGroupData) do
            local teamTemp = {}
            for teamDataKey, teamDataValue in pairs(value.TeamData) do
                teamTemp[teamDataKey] = teamDataValue
            end

            PlayerTeamGroupData[key] = {}
            PlayerTeamGroupData[key].TeamId = value.TeamId
            PlayerTeamGroupData[key].CaptainPos = value.CaptainPos
            PlayerTeamGroupData[key].TeamData = teamTemp
        end
    end


    -- 预编译队伍
    function XTeamManager.InitTeamPrefabData(teamPrefabData)
        if teamPrefabData == nil then
            return
        end

        for key, value in pairs(teamPrefabData) do
            local teamTemp = {}
            for teamDataKey, teamDataValue in pairs(value.TeamData) do
                teamTemp[teamDataKey] = teamDataValue
            end

            PlayerTeamPrefabData[key] = {}
            PlayerTeamPrefabData[key].TeamId = value.TeamId
            PlayerTeamPrefabData[key].CaptainPos = value.CaptainPos
            PlayerTeamPrefabData[key].TeamData = teamTemp
        end
    end

    function XTeamManager.GetTeamCfg(id)
        return TeamCfg[id]
    end

    function XTeamManager.GetCaptainPos()
        return CaptainPos
    end

    function XTeamManager.GetMaxPos()
        return MaxPos
    end

    function XTeamManager.GetTeamMemberColor(id)
        local colorStr = TeamCfg[id].Color
        local color = XUiHelper.Hexcolor2Color(colorStr)
        return color
    end

    function XTeamManager.GetTeamPrefabData()
        return PlayerTeamPrefabData
    end

    XTeamManager.Init()
    return XTeamManager
end
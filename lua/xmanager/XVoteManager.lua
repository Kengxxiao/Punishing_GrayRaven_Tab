XVoteManagerCreator = function()
    local XVoteManager = {}

    ---key: voteId
    ---value: { voteNum: 投票数, group: 这个投票属于哪个 投票分组 }
    local VoteMap = {}

    --key: groupId(投票分组Id)
    --value: { groupId: 分组Id, TimeToClose: 分组关闭时间, VoteMap: 分组包括的投票Id }
    local GroupMap

    --- {Id: 分组Id，SelectId：选择投票Id}
    local VoteGroupInfo = {}

    local METHOD_NAME = {
        GetVoteGroupListRequest = "GetVoteGroupListRequest",
        AddVoteRequest = "AddVoteRequest",
    }

    function XVoteManager.GetVoteGroupListRequest(cb)
        XNetwork.Call(METHOD_NAME.GetVoteGroupListRequest, {}, function(res)
            VoteMap = {}
            GroupMap = {}
            local groupList = res.VoteGroupList
            for k, v in pairs(groupList) do
                local groupItem = {}
                groupItem.GroupId = v.Id
                groupItem.TimeToClose = v.TimeToClose
                groupItem.VoteMap = {}

                for voteId, voteNum in pairs(v.VoteDic) do
                    VoteMap[voteId] = {}
                    VoteMap[voteId].VoteNum = voteNum
                    VoteMap[voteId].GroupId = v.Id
                    table.insert(groupItem.VoteMap, voteId)
                end

                GroupMap[v.Id] = groupItem
            end

            XEventManager.DispatchEvent(XEventId.EVENT_VOTE_REFRESH)
            if cb then
                cb()
            end
        end)
    end

    function XVoteManager.AddVote(voteId, cb)
        if not VoteMap[voteId] then
            XLog.Error(" XVoteManager.AddVote VoteId is not exist " .. voteId)
            return
        end

        XNetwork.Call(METHOD_NAME.AddVoteRequest, { VoteId = voteId }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end
            VoteMap[voteId].VoteNum = VoteMap[voteId].VoteNum + 1
            XEventManager.DispatchEvent(XEventId.EVENT_VOTE_REFRESH)
            if cb then
                cb()
            end
        end)
    end

    --判断是否已经从后端拿到 投票数据
    function XVoteManager.IsInit()
        return not (GroupMap == nil)
    end

    --判断投票是否已经关闭
    function XVoteManager.IsGroupVoteClose(groupId)
        if GroupMap == nil then
            return true
        else
            local groupMo = GroupMap[groupId]
            if not groupMo then
                XLog.Error(" XVoteManager.IsGroupVoteClose is not exist " .. groupId)
                return true
            end

            local remainTime = groupMo.TimeToClose - XTime.Now()
            if remainTime > 0 then
                return false
            else
                return true
            end
        end
    end

    --判断是否已经投过票
    function XVoteManager.IsGroupVoted(groupId)
        if not VoteGroupInfo[groupId] then
            return false
        else
            return true
        end
    end

    function XVoteManager.IsVoteSelected(groupId,voteId)
        local info = VoteGroupInfo[groupId]
        if not info then
            return false
        end

        if info.SelectId ~= voteId then
            return false
        end

        return true
    end

    --根据 VoteId 得到投票数据
    --如果已经请求过后端数据，直接return voteMo
    function XVoteManager.GetVote(voteId)
        if GroupMap == nil then
            return
        else
            local voteMo = VoteMap[voteId]
            if not voteMo then
                XLog.Error(" XVoteManager.GetVote voteId is not exist " .. voteId)
                return
            end
            return voteMo
        end
    end

    function XVoteManager.RefreshGroupInfo(groupData)
        VoteGroupInfo = {}
        for _, v in pairs(groupData) do
            VoteGroupInfo[v.Id] = v
        end
    end

    function XVoteManager.GetVoteIdListByGroupId(groupId)
        local group = GroupMap[groupId]
        if not group then
            XLog.Error("XVoteManager.GetVoteIdListByGroupId error. group id is not exist. groupId = " .. groupId)
            return {}
        end

        return group.VoteMap
    end

    return XVoteManager

end

XRpc.NotifyVoteData = function(data)
    XDataCenter.VoteManager.RefreshGroupInfo(data.VoteAlarmDic)
end
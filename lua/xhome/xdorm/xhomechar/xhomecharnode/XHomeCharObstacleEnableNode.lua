local XHomeCharObstacleEnableNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharObstacleEnable",CsBehaviorNodeType.Action,true,false)


function XHomeCharObstacleEnableNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["ObstackeEnable"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.ObstackeEnable = self.Fields["ObstackeEnable"]
end

function XHomeCharObstacleEnableNode:OnEnter()
    self.AgentProxy:SetObstackeEnable(self.ObstackeEnable)
    self.Node.Status = CsNodeStatus.SUCCESS
end


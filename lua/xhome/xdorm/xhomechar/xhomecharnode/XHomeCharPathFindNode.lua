local XHomeCharPathFindNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharPathFind",CsBehaviorNodeType.Action,true,false)


function XHomeCharPathFindNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["MinDistance"] == nil or self.Fields["MaxDistance"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.MinDistance = self.Fields["MinDistance"]
    self.MaxDistance = self.Fields["MaxDistance"]
end

function XHomeCharPathFindNode:OnEnter()
    if self.AgentProxy:DoPathFind(self.MinDistance,self.MaxDistance) then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
    
end


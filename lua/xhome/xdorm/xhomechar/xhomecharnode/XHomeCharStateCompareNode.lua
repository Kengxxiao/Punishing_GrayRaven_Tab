local XHomeCharStateCompareNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharStateCompare",CsBehaviorNodeType.Action,true,false)

function XHomeCharStateCompareNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["State"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.State = self.Fields["State"]
end


function XHomeCharStateCompareNode:OnEnter()
    local result = self.AgentProxy:GetState()
    if result then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end


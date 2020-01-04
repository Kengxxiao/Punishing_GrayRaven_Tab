local XHomeCharEventTypeCompareNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharEventTypeCompare", CsBehaviorNodeType.Condition, true, false)

function XHomeCharEventTypeCompareNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["EventType"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.EventType = self.Fields["EventType"]
end


function XHomeCharEventTypeCompareNode:OnEnter()
    local result = self.AgentProxy:CheckEventCompleted(self.EventType,function()
        self.Node.Status = CsNodeStatus.SUCCESS
    end)

    if not result then
        self.Node.Status = CsNodeStatus.FAILED
    end
end
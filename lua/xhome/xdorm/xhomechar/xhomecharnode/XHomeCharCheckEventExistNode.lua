local XHomeCharCheckEventExistNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckEventExist", CsBehaviorNodeType.Condition, true, false)

function XHomeCharCheckEventExistNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["EventId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.EventId = self.Fields["EventId"]
end


function XHomeCharCheckEventExistNode:OnEnter()
    local result = self.AgentProxy:CheckEventExist(self.EventId)
       
    if result then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end
local XHomeCharInteractTypeCompareNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharInteractTypeCompare", CsBehaviorNodeType.Condition, true, false)

function XHomeCharInteractTypeCompareNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["TypeId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.TypeId = self.Fields["TypeId"]
end

function XHomeCharInteractTypeCompareNode:OnEnter()
    local fondleType = self.AgentProxy:GetFondleType() 
    if fondleType == self.TypeId then

        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end


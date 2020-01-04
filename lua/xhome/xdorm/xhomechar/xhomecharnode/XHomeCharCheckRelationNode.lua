local XHomeCharCheckRelationNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckRelation", CsBehaviorNodeType.Condition, true, false)
function XHomeCharCheckRelationNode:OnEnter()
    if  self.AgentProxy:CheckCharacterInteracter() then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end

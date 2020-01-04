local XHomeCharCompletedFondleNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCompletedFondle", CsBehaviorNodeType.Action, true, false)

function XHomeCharCompletedFondleNode:OnEnter()
    self.AgentProxy:DequeueFondleType()
    self.Node.Status = CsNodeStatus.SUCCESS
end


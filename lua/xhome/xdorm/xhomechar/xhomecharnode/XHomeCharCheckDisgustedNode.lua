local XHomeCharCheckDisgustedNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckDisgusted", CsBehaviorNodeType.Action, true, false)
function XHomeCharCheckDisgustedNode:OnEnter()
    self.Node.Status = CsNodeStatus.FAILED
end


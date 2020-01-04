local XHomeCharHideEffectNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharHideEffect", CsBehaviorNodeType.Action, true, false)

function XHomeCharHideEffectNode:OnEnter()
    self.AgentProxy:HideEffect() 
    self.Node.Status = CsNodeStatus.SUCCESS
end
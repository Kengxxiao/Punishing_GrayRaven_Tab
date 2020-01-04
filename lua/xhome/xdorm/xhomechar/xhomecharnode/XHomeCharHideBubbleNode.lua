local XHomeCharHideBubbleNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharHideBubble", CsBehaviorNodeType.Action, true, false)

function XHomeCharHideBubbleNode:OnEnter()
    self.AgentProxy:HideBubble() 
    self.Node.Status = CsNodeStatus.SUCCESS
end
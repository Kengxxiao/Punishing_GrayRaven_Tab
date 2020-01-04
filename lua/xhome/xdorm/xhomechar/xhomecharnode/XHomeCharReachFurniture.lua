local XHomeCharReachFurniture = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharReachFurniture", CsBehaviorNodeType.Action, true, false)
function XHomeCharReachFurniture:OnEnter()
    self.Node.Status = CsNodeStatus.SUCCESS
    self.AgentProxy:ReachFurniture()
end


local XHomeCharEventRewardNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharEventReward", CsBehaviorNodeType.Action, true, false)

function XHomeCharEventRewardNode:OnEnter()
    self.AgentProxy:ShowEventReward()
    self.Node.Status = CsNodeStatus.SUCCESS
   
end
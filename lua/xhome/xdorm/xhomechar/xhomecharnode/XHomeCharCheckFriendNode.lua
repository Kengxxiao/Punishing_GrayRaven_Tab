local XHomeCharCheckFriendNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckFriend", CsBehaviorNodeType.Condition, true, false)
function XHomeCharCheckFriendNode:OnEnter()
    self.Node.Status = CsNodeStatus.FAILED
end


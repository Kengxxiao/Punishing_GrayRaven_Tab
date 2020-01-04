local XHomeCharSetInteractOffsetNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharSetInteractOffset", CsBehaviorNodeType.Action, true, false)
function XHomeCharSetInteractOffsetNode:OnEnter()
    if self.AgentProxy:SetInteraterPosOffest() then
        self.Node.Status = CsNodeStatus.SUCCESS
    end
end
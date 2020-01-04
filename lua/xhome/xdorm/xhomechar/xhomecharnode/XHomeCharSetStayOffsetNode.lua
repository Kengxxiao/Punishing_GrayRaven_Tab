local XHomeCharSetStayOffsetNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharSetStayOffest", CsBehaviorNodeType.Action, true, false)
function XHomeCharSetStayOffsetNode:OnEnter()
    if self.AgentProxy:SetStayOffset() then
        self.Node.Status = CsNodeStatus.SUCCESS
    end
end


local XHomeCharRandomDialogNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharRandomDialog", CsBehaviorNodeType.Action, true, false)
function XHomeCharRandomDialogNode:OnEnter()
    self.AgentProxy:ShowRandomBubble(function()
        self.Node.Status = CsNodeStatus.SUCCESS
    end)
end


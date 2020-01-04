local XHomeCharInteractFunitureActionNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharInteractFunitureAction", CsBehaviorNodeType.Action, true, false)

function XHomeCharInteractFunitureActionNode:OnEnter()
    if self.AgentProxy:PlayInteractFurnitureAnimation() then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end
local XHomeCharInteractNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharInteract", CsBehaviorNodeType.Action, true, false)

function XHomeCharInteractNode:OnEnter()
    if self.AgentProxy:InteractFurniture() then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end
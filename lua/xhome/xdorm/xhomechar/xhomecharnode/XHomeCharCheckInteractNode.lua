local XHomeCharCheckInteractNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckInteract", CsBehaviorNodeType.Condition, true, false)
function XHomeCharCheckInteractNode:OnEnter()
    if  self.AgentProxy:CheckFurnitureInteract() then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end

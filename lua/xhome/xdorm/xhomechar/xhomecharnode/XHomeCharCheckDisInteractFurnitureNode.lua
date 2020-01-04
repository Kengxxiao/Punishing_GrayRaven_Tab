local XHomeCharCheckDisInteractFurnitureNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCHarCheckCanDisInteractFurniture", CsBehaviorNodeType.Action, true, false)
function XHomeCharCheckDisInteractFurnitureNode:OnEnter()
    if self.AgentProxy:CheckDisInteractFurniture() then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end


local XHomeCharCheckRayCastFurnitureNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckRayCastFurniture", CsBehaviorNodeType.Decorator, true, true)


function XHomeCharCheckRayCastFurnitureNode:OnUpdate(dt)
    local result = self.AgentProxy:CheckRayCastFurnitureNode()

    if not result then
        self.Node.ChildNode:OnReset()
        self.Node.Status = CsNodeStatus.FAILED
        return
    end

    self.Node.ChildNode:OnUpdate(dt);
    self.Node.Status = self.Node.ChildNode.Status
end
local XHomeCharForwardToFurnitureNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharForwardToFurniture", CsBehaviorNodeType.Action, true, false)


function XHomeCharForwardToFurnitureNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["Direction"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.Direction = self.Fields["Direction"]
end

function XHomeCharForwardToFurnitureNode:OnEnter()
    if self.AgentProxy:SetForwardToFurniture(self.Direction) then
        self.Node.Status = CsNodeStatus.SUCCESS
    end
end
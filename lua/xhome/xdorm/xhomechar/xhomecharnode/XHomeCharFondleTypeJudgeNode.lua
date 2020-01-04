local XHomeCharFondleTypeJudgeNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharFondleTypeJudge", CsBehaviorNodeType.Decorator, true, true)

function XHomeCharFondleTypeJudgeNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["FondleType"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.FondleType = self.Fields["FondleType"]
end

function XHomeCharFondleTypeJudgeNode:OnUpdate(dt)
    local fondleType = self.AgentProxy:GetFondleType() 

    if fondleType ~= self.FondleType then
        self.Node.ChildNode:OnReset()
        self.Node.Status = CsNodeStatus.FAILED
        return
    end

    --self.AgentProxy:DequeueFondleType() 

    self.Node.ChildNode:OnUpdate(dt);
    self.Node.Status = self.Node.ChildNode.Status
end


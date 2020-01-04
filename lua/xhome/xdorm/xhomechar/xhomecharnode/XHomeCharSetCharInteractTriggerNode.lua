local XHomeCharSetCharInteractTriggerNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharSetCharInteractTrigger", CsBehaviorNodeType.Action, true, false)

function XHomeCharSetCharInteractTriggerNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["Trigger"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.Trigger = self.Fields["Trigger"]
end

function XHomeCharSetCharInteractTriggerNode:OnEnter()
    self.Node.Status = CsNodeStatus.SUCCESS
    self.AgentProxy:SetCharInteractTrigger(self.Trigger)
end


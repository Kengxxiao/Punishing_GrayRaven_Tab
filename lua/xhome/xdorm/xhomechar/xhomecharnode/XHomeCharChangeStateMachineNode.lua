local XHomeCharChangeStateMachineNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharChangeStateMachine",CsBehaviorNodeType.Action,true,false)

function XHomeCharChangeStateMachineNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["StateMachine"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.StateMachine = self.Fields["StateMachine"]
end

function XHomeCharChangeStateMachineNode:OnEnter()
    self.AgentProxy:ChangeStateMachine(self.StateMachine)
    self.Node.Status = CsNodeStatus.SUCCESS
end


local XHomeCharDoRoleActionOnlyNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharDoRoleActionOnly",CsBehaviorNodeType.Action,true,false)

function XHomeCharDoRoleActionOnlyNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["ActionId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.ActionId = self.Fields["ActionId"]
    self.CrossDuration = self.Fields["CrossDuration"]
    self.NeedFadeCross = self.Fields["NeedFadeCross"]

end

function XHomeCharDoRoleActionOnlyNode:OnEnter()
    self.AgentProxy:DoAction(self.ActionId,self.NeedFadeCross,self.CrossDuration)
    self.Node.Status = CsNodeStatus.SUCCESS
end


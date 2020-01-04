local XHomeCharDialogNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharDialog", CsBehaviorNodeType.Action, true, false)

function XHomeCharDialogNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["DialogId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.DialogId = self.Fields["DialogId"]
end

function XHomeCharDialogNode:OnEnter()
    self.AgentProxy:ShowBubble(self.DialogId,function()
        self.Node.Status = CsNodeStatus.SUCCESS
    end) 
end


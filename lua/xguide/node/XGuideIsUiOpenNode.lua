local XGuideIsUiOpenNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "IsUiOpen", CsBehaviorNodeType.Condition, true, false)

function XGuideIsUiOpenNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["UiName"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.UiName = self.Fields["UiName"]
    self.RequireOnTop = self.Fields["RequireOnTop"]
end

function XGuideIsUiOpenNode:OnEnter()
    if self.AgentProxy:IsUiShowAndOnTop(self.UiName, self.RequireOnTop) then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end

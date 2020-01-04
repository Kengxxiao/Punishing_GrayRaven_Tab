local XGuideIsUiOpenNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "IsGameObjectActive", CsBehaviorNodeType.Condition, true, false)

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
    self.GameObject = self.Fields["GameObject"]
end

function XGuideIsUiOpenNode:OnEnter()
    if self.AgentProxy:IsUiActive(self.UiName, self.GameObject) then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end

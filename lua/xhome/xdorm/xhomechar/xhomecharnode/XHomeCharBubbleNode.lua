local XHomeCharBubbleNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharBubble", CsBehaviorNodeType.Action, true, false)

function XHomeCharBubbleNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["Content"] == nil or self.Fields["EffectId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.Content = self.Fields["Content"]
    self.EffectId = self.Fields["EffectId"]
end


function XHomeCharBubbleNode:OnEnter()
    self.AgentProxy:ShowBubble(self.Content,self.EffectId) 
    self.Node.Status = CsNodeStatus.SUCCESS
end
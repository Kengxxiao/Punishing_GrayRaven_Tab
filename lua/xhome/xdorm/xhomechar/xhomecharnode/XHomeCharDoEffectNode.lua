local XHomeCharDoEffectNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharDoEffect",CsBehaviorNodeType.Action,true,false)

function XHomeCharDoEffectNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["EffectId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.EffectId = self.Fields["EffectId"]
end


function XHomeCharDoEffectNode:OnEnter()
    local bindWorldPos = self.Agent:GetVarDicByKey("BindWorldPos")
    self.Agent:SetVarDicByKey("BindWorldPos", nil)

    self.AgentProxy:PlayEffect(self.EffectId, bindWorldPos)
    self.Node.Status = CsNodeStatus.SUCCESS
end


local XHomeCharCheckPlayAnimationNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckPlayAnimation", CsBehaviorNodeType.Condition, true, false)

function XHomeCharCheckPlayAnimationNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["AnimationName"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    local list = self.Fields["AnimationName"]

    self.AnimationName = {}

    local count = list.Count
    for i = 0, count - 1 do
        local v = list[i]
        table.insert(self.AnimationName, v)
    end
end


function XHomeCharCheckPlayAnimationNode:OnEnter()
    local result = self.AgentProxy:CheckIsPlayingAnimation(self.AnimationName)

    if result then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end
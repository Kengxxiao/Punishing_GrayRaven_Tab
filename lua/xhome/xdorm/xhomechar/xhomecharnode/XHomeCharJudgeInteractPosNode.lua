local XHomeCharJudgeInteractPosNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharJudgeInteractPos",CsBehaviorNodeType.Action,true,false)


function XHomeCharJudgeInteractPosNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["PositionIndex"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.PositionIndex = self.Fields["PositionIndex"]
end

function XHomeCharJudgeInteractPosNode:OnEnter()
    local result = self.AgentProxy:CheckCharInteractPosByIndex(self.PositionIndex)
    if result then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end
end


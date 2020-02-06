local XGuideFubenJumpToStageNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideFubenJumpToStage", CsBehaviorNodeType.Action, true, false)



--聚焦Ui
function XGuideFubenJumpToStageNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["StageId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.StageId = self.Fields["StageId"]
end

function XGuideFubenJumpToStageNode:OnEnter()
    self.AgentProxy:FubenJunmToStage(self.StageId)
    self.Node.Status = CsNodeStatus.SUCCESS
end
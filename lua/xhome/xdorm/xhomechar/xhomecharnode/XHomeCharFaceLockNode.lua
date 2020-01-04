local XHomeCharFaceLockNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharFaceLock",CsBehaviorNodeType.Action,true,false)

function XHomeCharFaceLockNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["FaceId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.FaceId = self.Fields["FaceId"]
end


function XHomeCharFaceLockNode:OnEnter()
    self.AgentProxy:PlayFace(self.FaceId)
    self.Node.Status = CsNodeStatus.SUCCESS
end


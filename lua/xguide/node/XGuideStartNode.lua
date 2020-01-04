local XGuideStartNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideStart",CsBehaviorNodeType.Action,true,false)
--引导开启节点
function XGuideStartNode:OnStart()
    self.GuideId = self.BehaviorTree:GetLocalField("GuideId").Value
end

function XGuideStartNode:OnEnter()
    self.AgentProxy:ShowMask(false,true)
    XDataCenter.GuideManager.ReqGuideOpen(self.GuideId,function()
        self.Node.Status = CsNodeStatus.SUCCESS
        CS.XGuideEventPass.IsFightGuide = false
        XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_START)
    end)
end


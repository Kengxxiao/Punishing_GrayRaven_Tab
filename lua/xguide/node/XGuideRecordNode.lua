local XGuideRecordNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideRecord",CsBehaviorNodeType.Action,true,false)
--显示对话头像
function XGuideRecordNode:OnStart()
    self.GuideId = self.BehaviorTree:GetLocalField("GuideId").Value
end

function XGuideRecordNode:OnGetEvents()
   return { XEventId.EVENT_GUIDE_COMPLETED_SUCCESS }
end

function XGuideRecordNode:OnEnter()

    if XDataCenter.GuideManager.CheckIsGuide(self.GuideId) then
        self.Node.Status = CsNodeStatus.SUCCESS
        return
    end

    local guideGroup = XGuideConfig.GetGuideGroupTemplatesById(self.GuideId)
    local config = XGuideConfig.GetGuideCompleteTemplatesById(guideGroup.CompleteId)

    if config.Param[1] == 1 then
        XDataCenter.GuideManager.ReqGuideComplete(self.GuideId)
    end
end   


function XGuideRecordNode:OnNotify(evt,...)
    
    local args = {...}
    
    if evt == XEventId.EVENT_GUIDE_COMPLETED_SUCCESS and args[1] == self.GuideId then
        self.Node.Status = CsNodeStatus.SUCCESS
    end
end
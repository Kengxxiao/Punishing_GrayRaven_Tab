local XGuideDynamicIndexNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideDynamicIndex",CsBehaviorNodeType.Action,true,false)
--索引动态列表
function XGuideDynamicIndexNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["UiName"] == nil or self.Fields["DynamicName"] == nil or self.Fields["IndexValue"] == nil then    
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.UiName = self.Fields["UiName"]
    self.DynamicName = self.Fields["DynamicName"]
    self.IndexValue = self.Fields["IndexValue"]
    self.IndexKey = self.Fields["IndexKey"]
    self.FocusTransform = self.Fields["FocusTransform"]
    self.PassEvent = self.Fields["PassEvent"]
end

function XGuideDynamicIndexNode:OnEnter()
    self.AgentProxy:IndexDynamicTable(self.UiName,self.DynamicName,self.IndexKey,self.IndexValue,self.FocusTransform,self.PassEvent)
end

function XGuideDynamicIndexNode:OnGetEvents()
    return { CS.XEventId.EVENT_GUIDE_CLICK_BTNPASS }
end

function XGuideDynamicIndexNode:OnNotify(evt, ...)

    if evt == CS.XEventId.EVENT_GUIDE_CLICK_BTNPASS then
        self.Node.Status = CsNodeStatus.SUCCESS
    end

end


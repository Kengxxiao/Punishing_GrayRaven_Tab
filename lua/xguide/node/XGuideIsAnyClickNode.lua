local XGuideIsAnyClickNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideIsAnyClick", CsBehaviorNodeType.Condition, true, false)
--点击任意位置
function XGuideIsAnyClickNode:OnGetEvents()
    return { CS.XEventId.EVENT_GUIDE_ANYCLICK }
end

function XGuideIsAnyClickNode:OnNotify(evt, ...)

    if evt == CS.XEventId.EVENT_GUIDE_ANYCLICK then
        self.Node.Status = CsNodeStatus.SUCCESS
    end

end


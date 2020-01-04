local XHomeCharCheckClick = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckClick",CsBehaviorNodeType.Condition,true,false)


function XHomeCharCheckClick:OnGetEvents()
   return { XEventId.EVENT_DORM_CHARACTER_CLICK_SUCCESS }
end

function XHomeCharCheckClick:OnEnter()
    self.Id = self.AgentProxy:GetId()
end   


function XHomeCharCheckClick:OnNotify(evt,...)
    
    local args = {...}
    
    if evt == XEventId.EVENT_DORM_CHARACTER_CLICK_SUCCESS and args[1] == self.Id then
        self.Node.Status = CsNodeStatus.SUCCESS
    end
end




local XHomeCharCheckPointerUpNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharCheckPointerUp",CsBehaviorNodeType.Condition,true,false)


function XHomeCharCheckPointerUpNode:OnGetEvents()
   return { XEventId.EVENT_DORM_CHARACTER_POINTER_UP_SUCCESS }
end

function XHomeCharCheckPointerUpNode:OnEnter()
    self.Id = self.AgentProxy:GetId()
    
end   


function XHomeCharCheckPointerUpNode:OnNotify(evt,...)
    
    local args = {...}
    
    if evt == XEventId.EVENT_DORM_CHARACTER_POINTER_UP_SUCCESS and args[1] == self.Id then
        self.Node.Status = CsNodeStatus.SUCCESS
    end
end


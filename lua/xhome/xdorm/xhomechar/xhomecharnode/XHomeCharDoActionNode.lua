local XHomeCharDoActionNode = {}--XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharDoAction",CsBehaviorNodeType.Action,true,false)


function XHomeCharDoActionNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["ActionId"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.ActionId = self.Fields["ActionId"]
    self.ShortNameHash = CS.UnityEngine.Animator.StringToHash(self.ActionId)
end

function XHomeCharDoActionNode:OnGetEvents()
    return {CS.XEventId.EVENT_HOMECHAR_ACTION_EXIT, CS.XEventId.EVENT_HOMECHAR_ACTION_ENTER }
end

function XHomeCharDoActionNode:OnEnter()
    self.AgentProxy:DoAction(self.ActionId)
    self.IsPlaying = true
end

function XHomeCharDoActionNode:OnNotify(evt,animator,stateInfo)


    if evt == CS.XEventId.EVENT_HOMECHAR_ACTION_EXIT then
        XLog.Error(CS.XEventId.EVENT_HOMECHAR_ACTION_EXIT)
        XLog.Error(stateInfo.shortNameHash )

        if self.Agent and self.Agent.gameObject == animator.gameObject and self.IsPlaying then
            self.Node.Status = CsNodeStatus.SUCCESS
            self.IsPlaying = false
        end

    elseif evt == CS.XEventId.EVENT_HOMECHAR_ACTION_ENTER then
      
        XLog.Error(CS.XEventId.EVENT_HOMECHAR_ACTION_ENTER)
        XLog.Error(stateInfo.shortNameHash )
    end
end

function XHomeCharDoActionNode:OnExit()

end

function XHomeCharDoActionNode:OnReset()
    self.IsPlaying = false
end
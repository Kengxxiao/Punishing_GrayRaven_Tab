XLuaBehaviorNode = Class("XLuaBehaviorNode")

function XLuaBehaviorNode:Ctor(className,nodeProxy)
    self.Name = className
    self.NodeProxy = nodeProxy
    self.Node = nodeProxy.Node
    self.BehaviorTree = nodeProxy.Node.BTree
    self:InitNodeData()
end

--初始化数据
function XLuaBehaviorNode:InitNodeData()

    if not self.Node.Fields then
        self.Fields = nil
        return
    end

    self.Fields = {}

    local fields = self.Node.Fields.Fields

    for k,v in pairs(fields) do
        self.Fields[v.FieldName] = v.Value
    end
end



function XLuaBehaviorNode:OnAwake(...)

end

function XLuaBehaviorNode:SetAgent(...)
    self.Agent = self.BehaviorTree.BTAgent
    self.Proxy = self.Agent.Proxy
    self.AgentProxy = self.Agent.Proxy.LuaAgentProxy
    self:OnStart()
end

function XLuaBehaviorNode:OnEnable()
 
end

function XLuaBehaviorNode:OnStart()

end

function XLuaBehaviorNode:OnRecycle()
    self.Agent = nil
    self.Proxy = nil
    self.AgentProxy = nil
end


function XLuaBehaviorNode:OnDisable()

end

function XLuaBehaviorNode:OnEnter()

end

function XLuaBehaviorNode:OnExit()
end

function XLuaBehaviorNode:OnReset()

end

function XLuaBehaviorNode:OnDestroy()

end

function XLuaBehaviorNode:OnUpdate(dt)

end

function XLuaBehaviorNode:OnFixedUpdate(dt)

end

function XLuaBehaviorNode:OnNotify(evt, ...)

end

function XLuaBehaviorNode:OnGetEvents()

end
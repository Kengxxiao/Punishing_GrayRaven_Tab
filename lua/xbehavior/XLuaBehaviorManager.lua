CsXBehaviorManager = CS.BehaviorTree.XBehaviorTreeManager
CsNodeStatus = CS.BehaviorTree.XNodeStatus
CsBehaviorNodeType = CS.BehaviorTree.XBehaviorNodeType
CsCompareSymbol = CS.BehaviorTree.CompareSymbol

XLuaBehaviorManager = {}

local NodeClassType = {}
local AgentClassType = {}
 
--注册行为节点
function XLuaBehaviorManager.RegisterNode(super, classType, nodeType,islua,needUpdate)
    super = XLuaBehaviorNode or super
    CsXBehaviorManager.Instance:RegisterLuaNodeProxy(classType,nodeType,islua,needUpdate)
    local behaviorNode = Class(classType, super)
    NodeClassType[classType] = behaviorNode
    return behaviorNode
end

--创建行为节点实例
function XLuaBehaviorManager.NewLuaNodeProxy(className,nodeProxy)
    local baseName = className
    local class = NodeClassType[baseName]
    if not class then
        class = NodeClassType[baseName]
        if not class then
            XLog.Error("XLuaBehaviorManager.NewLuaNodeProxy error, class not exist, name: " .. className)
            return nil
        end
    end
    local obj = class.New(className, nodeProxy)
    return obj
end
 
--注册行为主体
function XLuaBehaviorManager.RegisterAgent(super, classType)
    super = XLuaBehaviorAgent or super
    CsXBehaviorManager.Instance:RegisterLuaAgentProxy(classType)
    local behaviorNode = Class(classType, super)
    AgentClassType[classType] = behaviorNode
    return behaviorNode
end

--创建行为主体实例
function XLuaBehaviorManager.NewLuaAgentProxy(className,agentProxy)
    local baseName = className
    local class = AgentClassType[baseName]
    if not class then
        class = AgentClassType[baseName]
        if not class then
            XLog.Error("XLuaBehaviorManager.NewLuaAgentProxy error, class not exist, name: " .. className)
            return nil
        end
    end
    local obj = class.New(className, agentProxy)
    return obj
end
 

function XLuaBehaviorManager.PlayId(id,agent)
   agent:PlayBehavior(id)
end

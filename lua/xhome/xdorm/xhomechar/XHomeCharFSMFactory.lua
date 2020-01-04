--状态
XHomeCharFSMType = {
    EMPTY = "EMPTY", --空状态
    IDLE = "IDLE",   --游荡状态
    MOOD = "MOOD",   --心情状态
    INTERACT = "INTERACT", --交互状态
    CONTROL = "CONTROL", --控制状态
}

--状态工厂
XHomeCharFSMFactory = {}
--注册表
local Registry = {}

--注册状态机
function XHomeCharFSMFactory.RegisterFSM(name,state)
    local machine = Class(name,XHomeCharFSM)
    Registry[state] = machine
    machine.name = state
    return machine
end

--新建状态
function XHomeCharFSMFactory.New(state,agent)
    if not Registry[state] then
        XLog.Error("状态机未注册！！！StateMachine :"..tostring(state))
        return nil
    end

    return Registry[state].New(agent)
end

--清空注册表
function XHomeCharFSMFactory.ClearRegistry()
    Registry = {}
end
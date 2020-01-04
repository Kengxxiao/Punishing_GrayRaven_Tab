--红点通知
local Notify = {}

--单个红点类
local NotifyPoint = XClass()

function NotifyPoint:Ctor()
    self.data = { cnt = 0 } --?cnt条件
end

function NotifyPoint:BindTo(node , customFunc)
    return XBindTool.BindNode(node, self.data , "cnt" , function(v, oldV)
        if customFunc then 
            customFunc(v, oldV)
        else
            if node.SetActive then
                node:SetActive(v > 0)
            end
            local gameObject = node.gameObject or node.GameObject
            if gameObject and gameObject.SetActive then
                gameObject:SetActive(v > 0)
            end
        end
    end)
end

function NotifyPoint:SetBindCnt(cnt)
    self.data.cnt = cnt
end

function NotifyPoint:InitWrap()
    self:Init()
end

function NotifyPoint:Init()

end

function NotifyPoint:Check()
    
end

Notify.NotifyPoint = NotifyPoint
-----------------------------------------------------
local NotifyGroup = XClass(NotifyPoint)

function NotifyGroup:Ctor()
    self.handles = {}
    self.pointMap = {}
end

function NotifyGroup:GetPoint(key)
    return self.pointMap[key]
end

function NotifyGroup:AddPoint(item, key)
    if key ~= nil then
        self.pointMap[key] = item
    end
    local h = XBindTool.BindAttr(item.data , "cnt" , function ( v , o_v)
        o_v = o_v or 0
        self.data.cnt = self.data.cnt + ( v - o_v )
    end)
    self.handles[item] = h
    if self.isInit then
        item:InitWrap()
        item:Check()
    end
end

function NotifyGroup:RemovePoint(item)
    self.data.cnt = self.data.cnt - item.data.cnt
    XBindTool.UnBind(self.handles[item])
    self.handles[item] = nil
end

function NotifyGroup:InitWrap()
    if self.isInit then return end
    self.isInit = true
    self:Init()
    for item , _ in pairs(self.handles) do
        item:InitWrap()
    end
end

function NotifyGroup:Check(...)
    for item , _ in pairs(self.handles) do
        item:Check(...)
    end
end

Notify.NotifyGroup = NotifyGroup
-----------------------------------------------------
local NotifyMgr = XClass()
local UpdateTime = 10 * CS.XScheduleManager.SECOND

function NotifyMgr:Ctor()
    self.mapValue = {}
    self.updateArr = {}
end

function NotifyMgr:RegistPoint(pType, point)
    self.mapValue[pType] = point
    if self.isStart then
        point:InitWrap()
        point:Check()
    end
end

function NotifyMgr:RemovePoint(ptype)
    local point = self.mapValue[ptype]
    if point then
        self.mapValue[ptype] = nil
        for index , v in ipairs(self.updateArr) do
            if v == point then
                table.remove(self.updateArr , index)
                return
            end
        end
    end
end

function NotifyMgr:RegistUpdatePoint(pType, point)
    self.mapValue[pType] = point;
    table.insert(self.updateArr , point)
    if self.isStart then
        point:InitWrap()
        point:Check()
        self:CheckRecycle()
    end
end

function NotifyMgr:GetPoint(pType)
    return self.mapValue[pType]
end

function NotifyMgr:Start()
    if self.isStart then return end
    self.isStart = true;
    for _ , point in pairs(self.mapValue) do
        point:InitWrap();
        point:Check();
    end
    self:CheckRecycle()
end

function NotifyMgr:CheckRecycle()
    if #self.updateArr > 0 and not self.updateHandler then
        self.updateHandler = CS.XScheduleManager.ScheduleForever(function(timer)
            self:Update(timer)
        end, UpdateTime, 0)
        self:Update(0)
    else
        if #self.updateArr == 0 and self.updateHandler then
            CS.XScheduleManager.UnSchedule(self.updateHandler)
            self.updateHandler = nil
        end
    end
end

function NotifyMgr:Update(timer)
    for _ , v in pairs(self.updateArr) do
        v:Check()
    end
end

Notify.NotifyMgr = NotifyMgr.New()

------------------------------------------------------------
-------------------下面是对外的接口---------------------------
XNotifyManager = XNotifyManager or {}

function XNotifyManager.BindNode(node , types , customFunc)
    local group = NotifyGroup.New()
    for _ , ptype in ipairs(types) do
        local point = Notify.NotifyMgr:GetPoint(ptype)
        if point then
            group:AddPoint(point)
        end
    end
    group:BindTo(node, customFunc)
end

function XNotifyManager.BindNodeWithKey(node, ptype, keys, customFunc)
    local point = Notify.NotifyMgr:GetPoint(ptype)
    for _, v in ipairs(keys) do
        if point and point.GetPoint then
            point = point:GetPoint(v)
        else
            break
        end
    end
    if point then 
        point:BindTo(node, customFunc)
    end
end

-- 考虑放在登录后再开启
function XNotifyManager.Start()
    Notify.NotifyMgr:Start()
end

-----------------------------------------------------

--这里添加所有的红点系统的名字
XNotifyManager.GNotifyName = {
    UrgentEvent = "UrgentEvent",
    CharacterStory = "CharacterStory",
}

return Notify
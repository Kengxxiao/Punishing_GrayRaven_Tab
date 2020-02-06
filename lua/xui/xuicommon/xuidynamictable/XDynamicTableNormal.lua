XDynamicTableNormal = {}

DYNAMIC_DELEGATE_EVENT = {
    DYNAMIC_GRID_RELOAD_COMPLETED = 1,
    DYNAMIC_GRID_TOUCHED = 2,
    DYNAMIC_GRID_ATINDEX = 3,
    DYNAMIC_GRID_RECYCLE = 4,
    DYNAMIC_TWEEN_OVER = 5,

    DYNAMIC_GRID_INIT = 100
}

function XDynamicTableNormal.New(gameObject)
    if gameObject == nil then
        return nil
    end

    local dynamicTable = {}
    setmetatable(dynamicTable, { __index = XDynamicTableNormal })

    local imp = dynamicTable:Init(gameObject)

    if not imp then
        return nil
    end

    return dynamicTable
end

--初始化
function XDynamicTableNormal:Init(gameObject)
    local imp = gameObject:GetComponent(typeof(CS.XDynamicTableNormal))
    if not imp then
        return false
    end

    self.Proxy = nil
    self.ProxyMap = {}
    self.ProxyImpMap = {}
    self.DataSource = {}
    self.DynamicEventDelegate = nil
    
    self.Imp = imp
    self.Imp:SetViewSize(imp.ScrRect.viewport.rect.size)
    self.Imp.DynamicTableGridDelegate = function(event, index, grid)
        self:OnDynamicTableEvent(event, index, grid)
    end

    return true
end

--获取实体组件
function XDynamicTableNormal:GetImpl()
    return self.Imp
end


--设置回调主体
function XDynamicTableNormal:SetDelegate(delegate)
    if not self.Imp then
        return
    end

    self.Imp:SetDelegate(self)
    self.Delegate = delegate
end


--事件回调
function XDynamicTableNormal:OnDynamicTableEvent(event, index, grid)

    if not self.Proxy then
        XLog.Warning("XDynamicTableNormal Proxy is nil,Please Setup First!!")
        return
    end

    if not self.Delegate then
        XLog.Warning("XDynamicTableNormal Delegate is nil,Please Setup First!!")
        return
    end

    if not self.Delegate.OnDynamicTableEvent and not self.DynamicEventDelegate then
        XLog.Warning("XDynamicTableNormal Delegate func OnDynamicTableEvent is nil,Please Setup First!!")
        return
    end

    --使用代理器，Lua代理器是一个 Table,IL使用C#脚本
    local proxy = nil
    if grid ~= nil then
        proxy = self.ProxyMap[grid]
        if not proxy then
            proxy = self.Proxy.New(grid)
            self.ProxyMap[grid] = proxy
            --初始化只调动一次
            proxy.Index = index
            proxy.DynamicGrid = grid

            if self.DynamicEventDelegate then
                self.DynamicEventDelegate(DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT, index, proxy)
            else
                self.Delegate.OnDynamicTableEvent(self.Delegate, DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT, index, proxy)
            end

        end
    end
    
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        proxy.Index = index
        proxy.DynamicGrid = grid
        self.ProxyImpMap[index] = proxy
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        proxy.Index = -1
        proxy.DynamicGrid = nil
        self.ProxyImpMap[index] = nil
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT, self.Imp.name)
    end

    if self.DynamicEventDelegate then
        self.DynamicEventDelegate(event, index, proxy)
    else
        self.Delegate.OnDynamicTableEvent(self.Delegate, event, index, proxy)
    end
end


--设置事件回调
function XDynamicTableNormal:SetDynamicEventDelegate(fun)
    self.DynamicEventDelegate = fun
end

--设置代理器
function XDynamicTableNormal:SetProxy(proxy)
    self.ProxyMap = {}
    self.ProxyImpMap = {}
    self.Proxy = proxy
end

--设置总数
function XDynamicTableNormal:SetTotalCount(totalCout)
    if not self.Imp then
        return
    end

    self.Imp:SetTotalCount(totalCout)
end

--设置总数
function XDynamicTableNormal:SetDataSource(datas)
    if not datas or not self.Imp then
        return
    end

    self.DataSource = datas
    self.Imp:SetTotalCount(#self.DataSource)
end

--获取代理器
function XDynamicTableNormal:GetGridByIndex(index)
    return self.ProxyImpMap[index]
end

--获取所有代理器
function XDynamicTableNormal:GetGrids()
    return self.ProxyImpMap
end

--设置可视区域
function XDynamicTableNormal:SetViewSize(viewSize)
    if not self.Imp then
        return
    end

    self.Imp:SetViewSize(viewSize)
end

--刷新可视区域
function XDynamicTableNormal:UpdateViewSize()
    if not self.Imp then
        return
    end

    self.Imp:SetViewSize(self.Imp.rectTransform.rect.size)
end

--同步重载数据
function XDynamicTableNormal:ReloadDataSync(startIndex,forceReload)
    startIndex = startIndex or -1
    if not self.Imp then
        return
    end

    if forceReload == nil then
        forceReload = true
    end

    self.Imp:ReloadDataSync(startIndex,forceReload)
end

--异步重载数据
function XDynamicTableNormal:ReloadDataASync(startIndex,forceReload)
    startIndex = startIndex or -1
    if not self.Imp then
        return
    end

    if forceReload == nil then
        forceReload = true
    end

    self.Imp:ReloadDataAsync(startIndex,forceReload)
end


--回收所有节点
function XDynamicTableNormal:RecycleAllTableGrid()
    if not self.Imp then
        return
    end

    self.Imp:RecycleAllTableGrid()
end

--清空节点
function XDynamicTableNormal:Clear()
    if not self.Imp then
        return
    end

    self.Imp:Clear()
end

--设置节点大小
function XDynamicTableNormal:SetGridSize(GridSize)
    if not self.Imp then
        return
    end

    self.Imp.OriginGridSize = GridSize
end

function XDynamicTableNormal:GetGridSize()
    return self.Imp and self.Imp.GridSize
end

function XDynamicTableNormal:GuideGetDynamicTableIndex(key, id)
    if not self.DataSource then
        return -1
    end

    if (not key or key == "") then
        return self.Delegate:GuideGetDynamicTableIndex(id)
    end


    for i, v in ipairs(self.DataSource) do
        if (type(v) ~= "table" and tostring(v) == id) or tostring(v[key]) == id then
            return i
        end
    end


    XLog.Error("Can not find key:" .. key .. " Value:" .. tostring(id) .. " in DataSource ")

    return -1
end

--todo 其他布局接口这里暂时不一一实现，因为布局属性在编辑阶段已经设置过
return XDynamicTableNormal
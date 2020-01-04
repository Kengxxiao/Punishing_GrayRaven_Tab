XDynamicTableIrregular = {}

function XDynamicTableIrregular.New(gameObject)
    if gameObject == nil then
        return nil
    end

    local dynamicTable = {}
    setmetatable(dynamicTable, { __index = XDynamicTableIrregular })

    local imp = dynamicTable:Init(gameObject)

    if not imp then
        return nil
    end

    return dynamicTable
end

--初始化
function XDynamicTableIrregular:Init(gameObject)
    local imp = gameObject:GetComponent(typeof(CS.XDynamicTableIrregular))
    if not imp then
        return false
    end

    self.Proxy = nil
    self.ProxyMap = {}
    self.ProxyImpMap = {}
    self.DataSource = {}

    self.Imp = imp
    self.Imp:SetViewSize(imp.rectTransform.rect.size)
    self.Imp.DynamicTableGridDelegate = function(event, index, grid)
        self:OnDynamicTableEvent(event, index, grid)
    end

    return true
end

--事件回调
function XDynamicTableIrregular:OnDynamicTableEvent(event, index)

    if not self.Proxy then
        XLog.Warning("XDynamicTableIrregular Proxy is nil,Please Setup First!!")
        return
    end

    if not self.Delegate then
        XLog.Warning("XDynamicTableIrregular Delegate is nil,Please Setup First!!")
        return
    end

    if not self.Delegate.OnDynamicTableEvent then
        XLog.Warning("XDynamicTableIrregular Delegate func OnDynamicTableEvent is nil,Please Setup First!!")
        return
    end

    if not self.Delegate.GetProxyType then
        XLog.Warning("XDynamicTableIrregular Delegate func GetProxyType is nil,Please Setup First!!")
        return
    end

    --获取当前代理的类型
    local proxy = self:GetGridByIndex(index)

    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then

        local proxyType = self.Delegate:GetProxyType(index)
        local grid = self.Imp:PreDequeueGrid(proxyType, index)

        if not self.Proxy[proxyType] then
            XLog.Error(string.format("XDynamicTableIrregular Proxy Type: %s not exist,Please Setup First!!", proxyType))
            return
        end

        --使用代理器，Lua代理器是一个 Table,IL使用C#脚本
        if grid ~= nil then
            proxy = self.ProxyMap[grid]
            if not proxy then
                proxy = self.Proxy[proxyType].New(grid)
                self.ProxyMap[grid] = proxy
                --初始化只调动一次
                proxy.Index = index
                proxy.DynamicGrid = grid
                self.Delegate.OnDynamicTableEvent(self.Delegate, DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT, index, proxy)
            end
        end

        proxy.Index = index
        proxy.DynamicGrid = grid
        self.ProxyImpMap[index] = proxy
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        proxy.Index = -1
        proxy.DynamicGrid = nil
        self.ProxyImpMap[index] = nil
    end

    self.Delegate:OnDynamicTableEvent(event, index, proxy)
end

--回收所有节点
function XDynamicTableIrregular:RecycleAllTableGrid()
    if not self.Imp then
        return
    end

    self.Imp:RecycleAllGrids()
end


--获取实体组件
function XDynamicTableIrregular:GetImpl()
    return self.Imp
end


--设置回调主体
function XDynamicTableIrregular:SetDelegate(delegate)
    if not self.Imp then
        return
    end

    self.Delegate = delegate
end

--设置代理器
function XDynamicTableIrregular:SetProxy(proxyType, proxy, prefab)
    if not self.Imp or not self.Imp.ObjectPool then
        return
    end

    self.Proxy = self.Proxy or {}
    self.Proxy[proxyType] = proxy

    self.Imp.ObjectPool:Add(proxyType, self.Imp.Content, prefab)
end

--设置总数
function XDynamicTableIrregular:SetTotalCount(totalCout)
    if not self.Imp then
        return
    end

    self.Imp.TotalCount = totalCout
end

--设置总数
function XDynamicTableIrregular:SetDataSource(datas)
    if not datas or not self.Imp then
        return
    end

    self.DataSource = datas
    self.Imp.TotalCount = #self.DataSource
end

--获取代理器
function XDynamicTableIrregular:GetGridByIndex(index)
    return self.ProxyImpMap[index]
end

--设置可视区域
function XDynamicTableIrregular:SetViewSize(viewSize)
    if not self.Imp then
        return
    end

    self.Imp:SetViewSize(viewSize)
end

--同步重载数据
function XDynamicTableIrregular:ReloadDataSync(startIndex)
    startIndex = startIndex or -1
    if not self.Imp then
        return
    end

    self.Imp:ReloadDataSync(startIndex)
end

--异步重载数据
function XDynamicTableIrregular:ReloadDataASync(startIndex)
    startIndex = startIndex or -1
    if not self.Imp then
        return
    end

    self.Imp:ReloadDataAsync(startIndex)
end


--清空节点
function XDynamicTableIrregular:Clear()
    if not self.Imp then
        return
    end

    self.Imp:Clear()
end

--todo 其他布局接口这里暂时不一一实现，因为布局属性在编辑阶段已经设置过
return XDynamicTableIrregular
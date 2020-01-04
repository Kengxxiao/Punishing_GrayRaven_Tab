XDynamicList = XClass()

DLScrollStatus = {
    SCROLLING = 0, 
    TOP = 1,
    BOTTOM = 2, 
    BEYOUD_TOP = 3, 
    BEYOUD_BOTTOM = 4
}

DLDelegateEvent = {
    DYNAMIC_GRID_TOUCHED = 5,
    DYNAMIC_GRID_ATINDEX = 6 , 
    DYNAMIC_GRID_RECYCLE = 7,
}

DLInsertDataDir = {
    None = 0,
    Head = 1,
    Tail = 2,
}

DLScrollDataDir = {
    None = 0, 
    Head = 1,
    Tail = 2
}

function XDynamicList:DebugLog( ... )
    if self.showLog then
        XLog.Error(...)
    end
end

function XDynamicList:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ItemCache = {}

    self.showLog = false

    self:ResetData()
    self:InitView()
end

function XDynamicList:ResetData()--重置数据
    self.Data = {}
    self.curDataMaxIndex = 0--当前数据最大的索引
    self.dataHeadIndex = -1 --当前数据头索引
    self.dataTailIndex = -1--当前数据尾索引
    self.NodeListData = {}

    self.curShowHeadIndex = -1--当前展示的头索引
    self.curShowTailIndex = -1--当前展示的尾索引
end

function XDynamicList:InitView()
    self.DynamicList = self.Transform:GetComponent("XVerticalDynamicList")
    self.DynamicListBar = self.DynamicList.verticalScrollbar
    if self.DynamicList == nil then
        XLog.Error("Not Find XVerticalDynamicList Component!")
        return 
    end
    self.DynamicList:SetViewSize(self.Transform:GetComponent("RectTransform").rect.size)
end

function XDynamicList:SetData(data,cb)--设置数据
    self:DebugLog("------数据初始化----",data)
    self:ResetData()
    self.CallBack = cb
    self.DynamicList.tableViewGridDelegate = function(evt,index,dir)
        return self:GenerateItem(evt,dir,index)
    end
    self:FormatData(data)
end

function XDynamicList:FormatData(data)--格式化数据
    if data == nil then
        XLog.Error("------FormatData is error!------> data is nil! please check!")
        return
    end
    self.dataHeadIndex = 1 
    self.dataTailIndex = #data
    self.NodeListData = {}
    for i = 1, self.dataTailIndex do
        self.curDataMaxIndex = self.curDataMaxIndex + 1
        local temp = {}
        temp.data = data[i]
        temp.index = self.curDataMaxIndex
        temp.Pre = (i == 1) and -1 or self.curDataMaxIndex - 1
        temp.Next = (i == #data) and -1 or self.curDataMaxIndex + 1
        self.NodeListData[self.curDataMaxIndex] = temp
    end
    self:DebugLog("------FormatData------",self.NodeListData)
    self:ReloadData()
end

function XDynamicList:ReloadData()
    -- if #self.NodeListData <= 0 then
    --     return 
    -- end
    self.curShowTailIndex = -1
    self.curShowHeadIndex = -1
    self.DynamicList.TotalCount = #self.NodeListData
    self.DynamicList:ReloadData(true)
    self:DebugLog("------ReloadData------",self.NodeListData)
end

function XDynamicList:InsertData(insertData,dir,isReload)--插入数据
    if #insertData == 0 then
        XLog.Error("-----------insertData is null--------------")
        return 
    end
    local tempDataHeadIndex = self.dataHeadIndex
    local tempDataTailIndex = self.dataTailIndex
    for i = 1, #insertData do
        self.curDataMaxIndex = self.curDataMaxIndex + 1
        local temp = {}
        temp.data = insertData[i]
        temp.index = self.curDataMaxIndex
        if dir == DLInsertDataDir.Head then
            temp.Pre = (i == 1) and -1 or self.curDataMaxIndex - 1
            if #self.NodeListData == 0 then
                temp.Next = -1
            else
                temp.Next = (i == #insertData) and self.dataHeadIndex or self.curDataMaxIndex + 1
            end
            if i == 1 then
                tempDataHeadIndex = self.curDataMaxIndex
            end
            if i == #insertData and #self.NodeListData > 0 then
                self.NodeListData[self.dataHeadIndex].Pre = self.curDataMaxIndex
            end
        elseif dir == DLInsertDataDir.Tail then
            if #self.NodeListData == 0 then
                temp.Pre = -1
            else
                temp.Pre = (i == 1) and self.dataTailIndex or self.curDataMaxIndex - 1
            end
            temp.Next = (i == #insertData) and -1 or self.curDataMaxIndex + 1
            if i == 1 and #self.NodeListData > 0 then
                self.NodeListData[self.dataTailIndex].Next = self.curDataMaxIndex
            end
            if i == #insertData then
                tempDataTailIndex = self.curDataMaxIndex
            end
        end
        self.NodeListData[self.curDataMaxIndex] = temp
    end 
    self.dataHeadIndex = tempDataHeadIndex
    self.dataTailIndex = tempDataTailIndex
    self:AddTotalCount(#insertData,dir)
    if isReload then
        self:ReloadData()
    end
end

function XDynamicList:AddTotalCount(addCount,dir)
    self.DynamicList.TotalCount = self.DynamicList.TotalCount + addCount;
    if dir == DLInsertDataDir.Head then
        self.DynamicList.StartIndex = self.DynamicList.StartIndex + addCount
        -- self.DynamicList.EndIndex = self.DynamicList.EndIndex + addCount
    elseif dir == DLInsertDataDir.Tail then
        -- self.DynamicList.EndIndex = self.DynamicList.EndIndex + addCount
    end
end

function XDynamicList:GenerateItem(evt,dir,index)
    if self.DynamicListBar then
        if self:GetBarValue() <= 0 then--拉到底了
            XEventManager.DispatchEvent(XEventId.EVENT_PULL_SCROLLVIEW_END, 0)
            -- 添加新事件系统触发
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_PULL_SCROLLVIEW_END, 0)
        elseif self:GetBarValue() >= 1 then--拉到顶了
            XEventManager.DispatchEvent(XEventId.EVENT_PULL_SCROLLVIEW_UP, 0)
            -- 添加新事件系统触发
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_PULL_SCROLLVIEW_UP, 0)
        end
    end
    if not self.CallBack then
        XLog.Error("You must be set callBack......")
        return 
    end
    if evt == DLDelegateEvent.DYNAMIC_GRID_ATINDEX then
        if #self.NodeListData == 0 then
            return true
        end
        local curShowDataIndex = nil--下一个需要展示的数据index
        if dir == DLScrollDataDir.Head then
            if not self.NodeListData[self.curShowHeadIndex] then
                return true
            end
            if self.NodeListData[self.curShowHeadIndex].Pre == -1 then
                return true
            end
            self.curShowHeadIndex = self.NodeListData[self.curShowHeadIndex].Pre
            curShowDataIndex = self.curShowHeadIndex
        elseif dir == DLScrollDataDir.Tail then
            if self.curShowTailIndex == -1 and self.curShowHeadIndex == -1 then
                self.curShowHeadIndex = self.dataHeadIndex
                self.curShowTailIndex = self.dataHeadIndex
            else
                if not self.NodeListData[self.curShowTailIndex] then
                    return true
                end
                if self.NodeListData[self.curShowTailIndex].Next == -1 then
                    return true
                end
                self.curShowTailIndex = self.NodeListData[self.curShowTailIndex].Next
            end
            curShowDataIndex = self.curShowTailIndex
        end
        self.CallBack(self.NodeListData[curShowDataIndex].data,function(poolName,ctor)
            local item = self.DynamicList:PreDequeueGrid(poolName,index)
            local xlayoutNode = item:GetComponent("XLayoutNode")
            if self.DynamicList and xlayoutNode then
                xlayoutNode.minSize = CS.UnityEngine.Vector2(self.DynamicList.transform:GetComponent("RectTransform").rect.width,0)
            end
            if item == nil then
                XLog.Error("GenerateItem is Fail......index = ",index)
                return false
            end
            local key = item.gameObject:GetHashCode()
            local itemScript = self.ItemCache[key]
            if itemScript ~= nil then
                return itemScript
            else
                local itemScript = ctor(item.gameObject)
                self.ItemCache[key] = itemScript
                return itemScript
            end
            
        end)
        return false
    elseif evt == DLDelegateEvent.DYNAMIC_GRID_RECYCLE then
        if dir == DLScrollDataDir.Head then
            self.curShowHeadIndex = self.NodeListData[self.curShowHeadIndex].Next
        elseif dir == DLScrollDataDir.Tail then
            self.curShowTailIndex = self.NodeListData[self.curShowTailIndex].Pre
        end
        
    end
    
end

--------------------------Set-------------------

function XDynamicList:SetReverse(code)
    self.DynamicList.Reverse = code
end

function XDynamicList:SetBarValue(value)
    self.DynamicListBar.value = value
end


---------------------------Get-----------------

function XDynamicList:GetBarValue()
    if self.DynamicListBar then
        return self.DynamicListBar.value
    else
        XLog.Error("------DynamicList Not ScrollBar Component!------")
        return nil
    end
end

function XDynamicList:GetCurDataCount()
    return #self.NodeListData
end

function XDynamicList:AddObjectPools( poolName,prefab )
    self.DynamicList.ObjectPool:Add(poolName,prefab)
end
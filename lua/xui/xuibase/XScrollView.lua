XScrollView = XClass(XLuaBehaviour)

local MAX_SCALE = 1
local DEFAULT_START_VALUE = 0.1                 -- 默认起始坐标参数值
local DEFAULT_OFFSET_VALUE = 0.2                -- 默认间隔坐标参数值
local DEFAULT_MIN_VALUE = 0.1                   -- 默认最小坐标参数值
local DEFAULT_MAX_VALUE = 0.9                   -- 默认最大坐标参数值

local DEFAULT_ANIM_SPEED = 0.5                  -- 默认动画速度


--==============================--
--desc: 构造函数
--@ui: 滑动展示区域Ui
--@scrollItems: 滑动列表
--@paramsObj: 扩展参数
--note: 可用扩展参数 selectIndex（默认显示第几条）、offsetValue（滑动列表间偏移量）、animSpeed（滑动速度）、
--  moveEndCb（滑动结束回掉）、direction（滑动方向，水平或者垂直）、isLoop（滑动列表是否循环）
--==============================--
function XScrollView:Ctor(rootUi, ui, scrollItems, paramsObj)
    self.ScrollItems = {}
    self.MoveEndCb = function () end
    self.SelectItemCb = function() end
    self.Direction = XScrollConfig.HORIZONTAL

    self.Rect = self.Transform:GetComponent("RectTransform")
    self.ContentSize = self.Rect.sizeDelta

    self.StartValue = DEFAULT_START_VALUE
    self.OffsetValue = DEFAULT_OFFSET_VALUE
    self.MinValue = DEFAULT_MIN_VALUE
    self.MaxValue = DEFAULT_MAX_VALUE
    self.MinBorder = DEFAULT_MIN_VALUE
    self.MaxBorder = DEFAULT_MAX_VALUE
    self.AnimSpeed = DEFAULT_ANIM_SPEED
    self.ItemsCount = #scrollItems
    self.IsLoop = false

    self.TotalOffset = 0    -- 重置总的滑动偏移计算

    self:InitParams(paramsObj)
    self:RegisterListener()
    self:InitAnimationCurve()
    self:InitScorllItems(scrollItems)
end

function XScrollView:AddSelectItemCallback(callback)
    self.SelectItemCb = callback
end

function XScrollView:RemoveSelectItemCallback(callback)
    self.SelectItemCb = nil
end

function XScrollView:RegisterListener()
    self.UiWidget = self.GameObject:AddComponent(typeof(CS.XUiWidget))
    self.UiWidget:AddBeginDragListener(function(eventData) 
        self:OnBeginDrag(eventData)
    end)
    self.UiWidget:AddEndDragListener(function(eventData)
        self:OnEndDrag(eventData)
    end)
    self.UiWidget:AddDragListener(function (eventData)
        self:OnDrag(eventData)
    end)
    self.UiWidget:AddPointerClickListener(function (eventData)
        self:OnPointerClick(eventData)
    end)
end

function XScrollView:InitScorllItems(scrollItems)
    local count = #scrollItems
    
    for i = 1, count do
        local item = scrollItems[i]
        item:SetIndex(i)
        item:SetParent(self)
        item:OnDrag(self.StartValue + (i - 1) * self.OffsetValue)
        if (not self.CurrentItem) and item.CurveValue - 0.5 < 0.05 then
            self.CurrentItem = item
        end

        table.insert(self.ScrollItems, item)
    end    

    local minCount = math.floor(1 / self.OffsetValue)   -- 滑动区域可展示条目数
    if #self.ScrollItems < minCount then
        self.MaxValue = self.StartValue + (minCount - 1) * self.OffsetValue
    else
        self.MaxValue = self.StartValue + (count - 1) * self.OffsetValue
    end

    if self.SelectIndex then
        self:SetSelectItem(self.SelectIndex)
    end
end

function XScrollView:InitParams(paramsObj)
    if not paramsObj or type(paramsObj) ~= "table" then
        return
    end

    if paramsObj.selectIndex then
        local selectIndex = paramsObj.selectIndex
        if selectIndex < 1 or selectIndex > self.ItemsCount then
            XLog.Warning("XScrollView InitParams use a Invalid selectIndex, selectIndex = " .. selectIndex)
        else
            self.SelectIndex = selectIndex
        end
    end

    if paramsObj.offsetValue then
        if paramsObj.offsetValue < 0 then
            XLog.Warning("XScrollView InitParams use a Invalid offsetValue, offsetValue = " .. paramsObj.offsetValue)
        else
            self.OffsetValue = paramsObj.offsetValue
        end
    end

    if paramsObj.animSpeed then
        if paramsObj.animSpeed < 0 then
            XLog.Warning("XScrollView InitParams use a Invalid animSpeed, animSpeed = " .. paramsObj.animSpeed)
        else
            self.AnimSpeed = paramsObj.animSpeed
        end
    end

    if paramsObj.moveEndCb then
        self.MoveEndCb = paramsObj.moveEndCb
    end

    if paramsObj.direction then
        local direction = paramsObj.direction
        if direction ~= XScrollConfig.HORIZONTAL and direction ~= XScrollConfig.VERTICAL then
            XLog.Warning("XScrollView InitParams use a Invalid direction, direction = " .. direction)
        else
            self.Direction = direction
        end
    end

    if paramsObj.isLoop ~= nil then
        self.IsLoop = paramsObj.isLoop 
    end
end

function XScrollView:SetSelectItem(index)
    self.CurrentItem = self.ScrollItems[index]
    local offset = 0.5 - self.CurrentItem.CurveValue
    for i = 1, #self.ScrollItems do
        local item = self.ScrollItems[i]
        item:OnDrag(offset)
    end
    
    self:AdjustScrollItems(offset)
    if (self.SelectItemCb) then
        self.SelectItemCb(self.CurrentItem)
    end
end

function XScrollView:InitAnimationCurve()
    -- Override this function
end

function XScrollView:OnBeginDrag(eventData)
    self.StartPoint = eventData.position
    self.AddVector = CS.UnityEngine.Vector3.zero
    self.Anim = false
end

--==============================--
--desc: 滑动过程回掉
--@eventData: 回掉数据
--==============================--
function XScrollView:OnDrag(eventData)
    -- Override this function
end

--==============================--
--desc: 滑动结束回掉滑动结束回掉
--@eventData: 回掉数据
--==============================--
function XScrollView:OnEndDrag(eventData)
    -- Override this function
end

--==============================--
--desc: 动画曲线值计算接口
--@curveValue: 曲线值
--@return 动画计算产生的结果 
--==============================--
function XScrollView:Evaluate(curveValue)
    -- Override this function
end

--==============================--
--desc: 调整滑动列表元素
--@addValue: 增加的偏移量
--==============================--
function XScrollView:AdjustScrollItems(addValue)
    if not self.IsLoop then
        return
    end

    local itemCount = #self.ScrollItems
    if addValue < 0 then    -- left or down
        local moveCount = 0
        for i = 1, itemCount do
            local item = self.ScrollItems[i]
            if item.CurveValue < (self.MinValue - self.OffsetValue / 2) then
                moveCount = moveCount + 1        
            end
        end

        if moveCount > 0 then
            for i = 1, moveCount do
                local lastCurveValue = self.ScrollItems[itemCount].CurveValue
                local item = table.remove(self.ScrollItems, 1)
                item.CurveValue = lastCurveValue + self.OffsetValue
                table.insert(self.ScrollItems, item)
            end
        end
    elseif addValue > 0 then    -- right or up
        local moveCount = 0
        for i = 1, itemCount do
            local item = self.ScrollItems[i]
            if item.CurveValue >= self.MaxValue then
                moveCount = moveCount + 1
            end

            if moveCount > 0 then
                local firstCurveValue = self.ScrollItems[1].CurveValue
                local item = table.remove(self.ScrollItems, itemCount)
                item.CurveValue = firstCurveValue - self.OffsetValue
                table.insert(self.ScrollItems, 1, item)
            end
        end
    end
end

--==============================--
--desc: 滑动结束动画处理
--@offset: 偏移量
--==============================--
function XScrollView:Anim2End(offset)
    self.NeedOffset = offset     -- 所需偏移量
    if offset == 0 then
        return
    end

    if offset > 0 then      -- 正方向，向右/向上
        self.MoveDir = 1
    else                    -- 反方向，向左/向下
        self.MoveDir = -1
    end

    self.Anim = true
    self.TotalOffset = 0    -- 重置已偏移统计
end

--==============================--
--desc: 点击回掉，判断点中节点
--@eventData: 点击回掉数据
--==============================--
function XScrollView:OnPointerClick(eventData)
    local gameObject = eventData.pointerPressRaycast.gameObject
    for i = 1, #self.ScrollItems do
        local item = self.ScrollItems[i]
        if item.GameObject == gameObject then
            if item.GameObject ~= self.CurrentItem.GameObject then
            self.CurrentItem = item
                self:Anim2End(0.5 - item.CurveValue)
            end
            break
        end
    end
end

function XScrollView:Update()
    if not self.Anim then
        return
    end

    local addOffset = CS.UnityEngine.Time.deltaTime * self.AnimSpeed * self.MoveDir
    local totalOffset = self.TotalOffset + addOffset

    if totalOffset > 0 and totalOffset >= self.NeedOffset then
        self.Anim = false
        addOffset = self.NeedOffset - self.TotalOffset
    end

    if totalOffset < 0 and totalOffset <= self.NeedOffset then
        self.Anim = false
        addOffset = self.NeedOffset - self.TotalOffset
    end

    for i = 1, #self.ScrollItems do
        local item = self.ScrollItems[i]
        item:OnDrag(addOffset)
        if math.abs(item.CurveValue - 0.5) < 0.05 then    -- 当前选中节点
            self.CurrentItem = item 
        end
    end

    self:AdjustScrollItems(addOffset)
    self.TotalOffset = totalOffset

    if not self.Anim then
        self.MoveEndCb(self.CurrentItem)
    end
end

function XScrollView:LateUpdate()
    local sortValues = {}

    local midItem
    local minOffset = 1
    for i = 1, #self.ScrollItems do
        local item = self.ScrollItems[i]
        local v = math.abs(item.CurveValue - 0.5)
        -- if math.abs(item.CurveValue - 0.5) < 0.05 then    -- 当前选中节点
        --     midItem = item
        -- end

        if v < minOffset then
            minOffset = v
            midItem = item
        end

    end

    if not midItem then
        return
    end

    local midIndex = midItem.Index
    local maxIndex = #self.ScrollItems

    for i = 1, midIndex - 1 do
        local item = self.ScrollItems[i]         
        -- if item.CurveValue >= self.MinBorder then
        item.Rect:SetSiblingIndex(i)
        -- else 
        --     break
        -- end
    end

    for i = midIndex + 1, maxIndex do
        local item = self.ScrollItems[i]         
        -- if item.CurveValue <= self.MaxBorder then
        item.Rect:SetSiblingIndex(maxIndex - i)
        -- else
        --     break
        -- end
    end
    
    midItem.Rect:SetSiblingIndex(maxIndex)
end

function XScrollView:Dispose()
    local xLuaBehaviour = self.Transform:GetComponent("XLuaBehaviour")
    if (xLuaBehaviour) then
        CS.UnityEngine.GameObject.Destroy(xLuaBehaviour)
    end

    if (self.UiWidget) then
        CS.UnityEngine.GameObject.Destroy(self.UiWidget)
    end
end
XScrollFlowHelper = {}

local EDGE_SCALE = 0.35

local ScrollFlowList = {}

function XScrollFlowHelper.GetScrollFlow(uiName)
    return ScrollFlowList[uiName]
end

XScrollFlow = XClass(XScrollView)

function XScrollFlow:Ctor(rootUi, ui, scrollItems, paramsObj)
    self.paramsObj = paramsObj

    ScrollFlowList[ui.name] = self
end

function XScrollFlow:AddKeys(animationCurve, keys)
    for i = 1, #keys do
        local key = keys[i]
        local keyframe = CS.UnityEngine.Keyframe()
        for k, v in pairs(key) do
            keyframe[k] = v
        end
        animationCurve:AddKey(keyframe)
    end
end

function XScrollFlow:InitAnimationCurve()
    local AnimationCurve = CS.UnityEngine.AnimationCurve
    self.PositionCurve = AnimationCurve()
    self.ScaleCurve = AnimationCurve()
    self.AlphaCurve = AnimationCurve()

    self:AddKeys(self.PositionCurve, XScrollConfig.POSITION_KEY_FRAMES)
    self:AddKeys(self.ScaleCurve, XScrollConfig.SCALE_KEY_FRAMES)
    self:AddKeys(self.AlphaCurve, XScrollConfig.ALPHA_KEY_FRAMES)
end


function XScrollFlow:OnDrag(eventData)
    self.AddVector = eventData.position - self.StartPoint
    local addValue = eventData.delta.x * 1.0 / self.ContentSize.x
    
    if self.Direction == XScrollConfig.VERTICAL then
        addValue = eventData.delta.y * 1.0 / self.ContentSize.y
    end

    local count = #self.ScrollItems
    if self.ScrollItems[1].CurveValue > (1 - EDGE_SCALE) or self.ScrollItems[count].CurveValue < EDGE_SCALE then
        addValue = 0
    end

    for i = 1, #self.ScrollItems do
        self.ScrollItems[i]:OnDrag(addValue)
    end
    -- self:AdjustScrollItems(addValue)
end

function XScrollFlow:OnEndDrag(eventData)
    local offset = 0
    local count = #self.ScrollItems

    if self.ScrollItems[1].CurveValue > 0.5 then
        offset = 0.5 - self.ScrollItems[1].CurveValue
    elseif self.ScrollItems[count].CurveValue < 0.5 then
        offset = 0.5 - self.ScrollItems[count].CurveValue
    else
        for i = 1, count do
            if self.ScrollItems[i].CurveValue >= self.MinBorder then -- 获取偏移量
                offset = self.OffsetValue / 2 + self.ScrollItems[i].CurveValue
                offset = self.OffsetValue / 2 - (offset + self.OffsetValue / 2) % self.OffsetValue
                break
            end
        end
    end
    self.AddVector = CS.UnityEngine.Vector3.zero
    self:Anim2End(offset)
end

function XScrollFlow:Evaluate(curveValue, transform)
    local position = transform and transform.localPosition or CS.UnityEngine.Vector3.zero
    if self.Direction == XScrollConfig.HORIZONTAL then
        position.x = self.PositionCurve:Evaluate(curveValue) * self.ContentSize.x - self.ContentSize.x / 2
    else
        position.y = self.PositionCurve:Evaluate(curveValue) * self.ContentSize.y - self.ContentSize.y / 2
    end

    local alpha = self.AlphaCurve:Evaluate(curveValue) 
    local scale = self.ScaleCurve:Evaluate(curveValue)

    return position, alpha, scale
end

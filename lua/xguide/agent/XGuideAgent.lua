local XGuideAgent = XLuaBehaviorManager.RegisterAgent(XLuaBehaviorAgent, "Guide")

function XGuideAgent:OnAwake(...)
    self.UiGude = nil
end

--获取Ui
function XGuideAgent:GetUi(uiName)
    local isUiShow = CsXUiManager.Instance:IsUiShow(uiName)
    if not isUiShow then
        XLog.Error(uiName .. " is not showing")
        return
    end

    local ui = CsXUiManager.Instance:FindTopUi(uiName)
    if not ui then
        XLog.Error(uiName .. " is not on Top")
        return
    end

    local proxy = nil
    proxy = ui.UiProxy.UiLuaTable
    return proxy
end

--获取UiGuide
function XGuideAgent:GetUiGuide()
    if self.UiGude and self.UiGude.Transform and self.UiGude.Transform:Exist() then
        return self.UiGude
    end

    local isUiGuideShow = CsXUiManager.Instance:IsUiShow("UiGuide")
    if not isUiGuideShow then
        XLuaUiManager.Open("UiGuide")
    end

    local uiGuide = CsXUiManager.Instance:FindTopUi("UiGuide")
    local proxy = nil
    if uiGuide then
        proxy = uiGuide.UiProxy.UiLuaTable
    end

    self.UiGude = proxy

    return proxy
end


--UI是否显示中
function XGuideAgent:IsUiShowAndOnTop(uiName,needOnTop)
    local isUiShow = CsXUiManager.Instance:IsUiShow(uiName)
    if not isUiShow then
        return false
    end

    if not needOnTop then
        return true
    end

    local ui = CsXUiManager.Instance:FindTopUi(uiName)
    if not ui then
        return false
    end

    return true
end

---显示对话头像
function XGuideAgent:ShowDialog(image, name, content,pos)
    local uiGuide = self:GetUiGuide()
    uiGuide:ShowDialog(image, name, content, pos)
end

---隐藏对话头像
function XGuideAgent:HideDialog()
    local uiGuide = self:GetUiGuide()
    uiGuide:HideDialog()
end

---显示遮罩
function XGuideAgent:ShowMask(isShowMask, isBlockRaycast)
    local uiGuide = self:GetUiGuide()
    uiGuide:ShowMark(isShowMask, isBlockRaycast)
end

--ui是否显示中
function XGuideAgent:IsUiActive(uiName, panel)
    local target = self:FindTransformInUi(uiName, panel)

    if not target then
        return false
    end

    return target.gameObject.activeSelf
end

--聚焦UI
function XGuideAgent:FocusOn(uiName, panel, eulerAngles, passEvent)
    local target = self:FindTransformInUi(uiName, panel)
    local uiGuide = self:GetUiGuide()
    uiGuide:FocuOnPanel(target, eulerAngles, passEvent)
end

--索引动态列表
function XGuideAgent:IndexDynamicTable(uiName,dynamicName,indexKey,indexValue,focusTransform,passEvent)
    local target = self:FindTransformInUi(uiName,dynamicName)

    local dynamicTable = target:GetComponent(typeof(CS.XDynamicTableNormal))
    if not dynamicTable then
        XLog.Error(string.format("DynamicTable is null uiName:%s dynamicName:%s",uiName,dynamicName))
        return
    end


    local gridIndex = dynamicTable.LuaTableDelegate:GuideGetDynamicTableIndex(indexKey, indexValue)
    dynamicTable:ReloadDataSync(gridIndex)
    if gridIndex == -1 then
        XLog.Error("找不到该动态节点,请检查ID参数是否正确 KEY:" .. tostring(indexKey) .. " ID:" .. tostring(indexValue))
        return nil
    end

    local grid = dynamicTable:GetGridByIndex(gridIndex)
    if not grid then
        XLog.Error("找不到该动态节点,请检查ID参数是否正确 KEY:" .. tostring(indexKey) .. " ID:" .. tostring(indexValue) .." Index:"..tostring(gridIndex))
        return nil
    end

    if focusTransform == nil or focusTransform == "" or focusTransform == "@" then
        self.UiGude:FocuOnPanel(grid.transform,nil,passEvent)
    else
        local target = grid.transform:FindTransformWithSplit(focusTransform)
        self.UiGude:FocuOnPanel(target,nil,passEvent)
    end
end

--寻找Ui
function XGuideAgent:FindTransformInUi(uiName,panel)
    local ui = self:GetUi(uiName)
    if ui == nil then
        XLog.Error("错误!!引导未能找到 Ui:"..uiName .." 请检查引导流程")
        return
    end

    local target = ui.Transform:FindTransformWithSplit(panel)
    if not target then
        XLog.Error(uiName .. " 未能找到该节点："..panel)
        return
    end

    return target
end

--跳转关卡
function XGuideAgent:FubenJunmToStage(stageId)

    local uiFubenMainLineChapter = CsXUiManager.Instance:FindTopUi("UiFubenMainLineChapter")
    local proxy = nil
    if uiFubenMainLineChapter then
        proxy = uiFubenMainLineChapter.UiProxy.UiLuaTable
    end

    if proxy then
        proxy:GoToStage(stageId)
    end

end

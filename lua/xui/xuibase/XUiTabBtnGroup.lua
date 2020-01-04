XUiTabBtnGroup = XClass(XUiTabBtnGroup)
XUiTabBtnGroup.TabBtnType = 
{
    Normal = 1,
    Chapter = 2,
}

function XUiTabBtnGroup:Ctor(btnList, callback, clickCheck, isLockClick, tabType)
    self.TabBtnList = {}
    self.Callback = callback
    self.ClickCheck = clickCheck
    if tabType == nil then
        for index, btn in ipairs(btnList) do
            local tabBtn = XUiBtnTab.New(btn, index, function(i) self:SelectIndex(i) end, isLockClick)
            table.insert(self.TabBtnList, tabBtn)
        end
    elseif tabType == XUiTabBtnGroup.TabBtnType.Chapter then
        for index, btn in ipairs(btnList) do
            local tabBtn = XUiChapterBtnTab.New(btn, index, function(i) self:SelectIndex(i) end, isLockClick)
            table.insert(self.TabBtnList, tabBtn)
        end
    end
end

function XUiTabBtnGroup:SelectIndex(index)

    if self.ClickCheck then
        local success = false
        for i, btn in ipairs(self.TabBtnList) do
            if (i == index) then
                if self.ClickCheck(index) then
                    btn:OnSelect(true)
                    success = true
                end
            end
        end
        if not success then return end
        for i, btn in ipairs(self.TabBtnList) do
            if (i ~= index) then
                btn:OnSelect(false)
            end
        end
    else
        for i, btn in ipairs(self.TabBtnList) do
            if (i == index) then
                btn:OnSelect(true)
            else
                btn:OnSelect(false)
            end
        end
    end

    if (self.Callback) then
        self.Callback(index)
    end
end

function XUiTabBtnGroup:LockIndex(index)
    local btn = self.TabBtnList[index]
    if (btn) then
        btn:Lock(true)
    end
end

function XUiTabBtnGroup:UnLockIndex(index)
    local btn = self.TabBtnList[index]
    if (btn) then
        btn:Lock(false)
    end
end

function XUiTabBtnGroup:Dispose()
    for index, btn in ipairs(self.TabBtnList) do
        btn:Dispose()
    end
    self.Callback = nil
    self.TabBtnList = nil
end
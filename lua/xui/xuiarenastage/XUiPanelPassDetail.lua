local XUiPanelPassDetail = XClass()

local XUiGridArenaPassContent = require("XUi/XUiArenaStage/ArenaStageCommon/XUiGridArenaPassContent")

function XUiPanelPassDetail:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.IsShow = false
    self.GameObject:SetActive(false)

    self.GridPassTitle.gameObject:SetActive(false)
    self.GridPassContent.gameObject:SetActive(false)

    self.TitleList = {}
    table.insert(self.TitleList, self.GridPassTitle)
    self.ContentList = {}
    local gridContent = XUiGridArenaPassContent.New(self.GridPassContent, self)
end

function XUiPanelPassDetail:Show(stageIds, dataMap)
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)

    self:Refresh(stageIds, dataMap)
end

function XUiPanelPassDetail:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelPassDetail:Refresh(stageIds, dataMap)
    if not stageIds then
        return
    end

    if not dataMap then
        return
    end

    for i, v in ipairs(self.TitleList) do
        v.gameObject:SetActive(false)
    end

    for i, v in ipairs(self.ContentList) do
        v.GameObject:SetActive(false)
    end

    for i, id in ipairs(stageIds) do
        --标题
        local title_grid = self.TitleList[i]
        if not title_grid then
            local go = CS.UnityEngine.GameObject.Instantiate(self.GridPassTitle.gameObject)
            title_grid = go.transform
            title_grid:SetParent(self.GridPassTitle.parent, false)
            table.insert(self.TitleList, title_grid)
        end
        title_grid.gameObject:SetActive(true)

        local title = XUiHelper.TryGetComponent(title_grid, "Image/TxtTitle", "Text")
        title.text = CS.XTextManager.GetText("ArenaActivityStage", i)
        title_grid:SetSiblingIndex(0)

        --玩家信息
        local content_grid = self.ContentList[i]
        if not content_grid then
            local go = CS.UnityEngine.GameObject.Instantiate(self.GridPassContent.gameObject)
            content_grid = XUiGridArenaPassContent.New(go.transform, self)
            go.transform:SetParent(self.GridPassContent.parent, false)
            table.insert(self.ContentList, content_grid)
        end
        content_grid.GameObject:SetActive(true)
        content_grid:SetMetaData(dataMap[id])
        content_grid.Transform:SetSiblingIndex(1)
    end
end

return XUiPanelPassDetail

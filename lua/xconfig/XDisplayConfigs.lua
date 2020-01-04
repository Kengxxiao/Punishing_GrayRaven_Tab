XDisplayConfigs = XDisplayConfigs or  {}

local tableInsert = table.insert

local TABLE_DISPLAY_PATH = "Client/Display/Display.tab"
local TABLE_CONTENT_PATH = "Client/Display/DisplayContent.tab"

local DisplayTable = {}
local ContentTable = {}
local Groups = {}

function XDisplayConfigs.Init()
    DisplayTable = XTableManager.ReadByIntKey(TABLE_DISPLAY_PATH, XTable.XTableDisplay, "Id")
    if not DisplayTable then
        XLog.Error("XDisplayManager.Init : Display.rab read fail")
    end

    ContentTable = XTableManager.ReadByIntKey(TABLE_CONTENT_PATH, XTable.XTableDisplayContent, "Id")
    for _, tab in pairs(DisplayTable) do
        local group = Groups[tab.Model]
        if not group then
            group = { Ids = {}, Weights = {} }
            Groups[tab.Model] = group
        end
        tableInsert(group.Ids, tab.Id)
        tableInsert(group.Weights, tab.Weight)
    end
end

function XDisplayConfigs.GetDisplayTable()
    return DisplayTable
end

function XDisplayConfigs.GetContentTable()
    return ContentTable
end

function XDisplayConfigs.GetGroups()
    return Groups
end
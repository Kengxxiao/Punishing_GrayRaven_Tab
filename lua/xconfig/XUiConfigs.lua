XUiConfigs = XUiConfigs or {}

local TABLE_UICOMPONENT_PATH = "Client/Ui/UiComponent.tab"

local UiComponentTemplates = {}

function XUiConfigs.Init()
    UiComponentTemplates = XTableManager.ReadByStringKey(TABLE_UICOMPONENT_PATH, XTable.XTableUiComponent, "Key")
end

function XUiConfigs.GetComponentUrl(key)
    local template = UiComponentTemplates[key]

    if not template then
        XLog.Error("XUiConfigs.GetComponentUrl error: can not found template, key is " .. key)
        return
    end

    return template.PrefabUrl
end

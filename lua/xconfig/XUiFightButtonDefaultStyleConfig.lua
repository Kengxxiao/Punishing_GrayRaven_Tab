XUiFightButtonDefaultStyleConfig = XUiFightButtonDefaultStyleConfig or {}
local TABLE_UIFIGHT_BUTTON_DEFAULTSTYLE = "Client/Fight/UiFightButtonDefaultStyle.tab"
local UiFightButtonDefaultStyle = nil

function XUiFightButtonDefaultStyleConfig.Init()
    UiFightButtonDefaultStyle = XTableManager.ReadByIntKey(TABLE_UIFIGHT_BUTTON_DEFAULTSTYLE, XTable.XTableUiFightButtonDefaultStyle, "Id")
end

function XUiFightButtonDefaultStyleConfig.GetStyleById(id)
    return UiFightButtonDefaultStyle[id]
end

function XUiFightButtonDefaultStyleConfig.SaveDefaultStyleById(id)
    if not UiFightButtonDefaultStyle then
        UiFightButtonDefaultStyle = XTableManager.ReadByIntKey(TABLE_UIFIGHT_BUTTON_DEFAULTSTYLE, XTable.XTableUiFightButtonDefaultStyle, "Id")
    end
    
    if not UiFightButtonDefaultStyle then
        return 
    end

    local config = UiFightButtonDefaultStyle[id]
    if config and config.Scheme then   
        CS.XCustomUi.Instance:SaveButtonCustom(config.Scheme)
    end
end

function XUiFightButtonDefaultStyleConfig.GetDefaultStyle()
    return CS.UnityEngine.PlayerPrefs.GetString("CustomUI");
end

function XUiFightButtonDefaultStyleConfig.GetCurSchemeStyle()
    return CS.XCustomUi.Instance.CurScheme or 0
end

function XUiFightButtonDefaultStyleConfig.IsHaveCurSchemeStyle()
    return CS.UnityEngine.PlayerPrefs.HasKey("CustomUI")
end
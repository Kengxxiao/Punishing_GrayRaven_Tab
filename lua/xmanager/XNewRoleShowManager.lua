XNewRoleShowManager = XNewRoleShowManager or {}

local TABLE_NEWROLE_PATH = "Client/Story/StoryRole.tab"
local RoleTemplate = {}

function XNewRoleShowManager.Init()
    RoleTemplate = XTableManager.ReadByIntKey(TABLE_NEWROLE_PATH, XTable.XTableStoryRole, "RoleId")
end

function XNewRoleShowManager.GetNewRoleShowTemplate(roleid)
    if not roleid then
        XLog.Error("XNewRoleShowManager.GetNewRoleShowTemplate error: id is nil")
        return
    end
    local result = RoleTemplate[roleid]
    if not result then
        XLog.Error("XNewRoleShowManager.GetNewRoleShowTemplate error: id not exist id = " .. roleid)
        return
    end
    return result
end

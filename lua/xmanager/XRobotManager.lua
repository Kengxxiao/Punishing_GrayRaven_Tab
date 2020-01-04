XRobotManager = XRobotManager or {}

local TABLE_ROBOT = "Share/Robot/Robot.tab";
local RobotTemplates = {}

function XRobotManager.Init() 
    RobotTemplates = XTableManager.ReadByIntKey(TABLE_ROBOT, XTable.XTableRobot, "Id")
end

function XRobotManager.GetCharaterId(robotId)
    local charId = 0
    if RobotTemplates[robotId] then
        charId = RobotTemplates[robotId].CharacterId
    end
    return charId
end

function XRobotManager.GetRobotTemplate(robotId)
    return RobotTemplates[robotId]
end
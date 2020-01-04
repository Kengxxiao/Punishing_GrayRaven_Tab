XCommunicationConfig = {}

local TABLE_FUNCTION_COMMUNICATION_PATH = "Share/Functional/FunctionalCommunication.tab"
local FunctionCommunicationConfig = {}

function XCommunicationConfig.Init()
    FunctionCommunicationConfig = XTableManager.ReadByIntKey(TABLE_FUNCTION_COMMUNICATION_PATH, XTable.XTableFunctionalCommunication, "Id")
end

function XCommunicationConfig.GetFunctionCommunicationConfig()
    return FunctionCommunicationConfig
end





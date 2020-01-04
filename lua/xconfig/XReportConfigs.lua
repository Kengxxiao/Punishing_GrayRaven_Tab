XReportConfigs = XReportConfigs or {}

local TABLE_REPORT_PATH = "Share/Report/ReportTag.tab"

local ReportCfg = {}

function XReportConfigs.Init()
    ReportCfg = XTableManager.ReadByIntKey(TABLE_REPORT_PATH, XTable.XTableReportTag, "Id")
end

function XReportConfigs.GetReportCfg()
    return ReportCfg
end
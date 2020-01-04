XGuideConfig = {}

local TABLE_GUIDE_COMPLETE_PATH = "Share/Guide/GuideComplete.tab"
local TABLE_GUIDE_STEP_PATH = "Share/Guide/GuideStep.tab"
local TABLE_GUIDE_GROUP_PATH = "Share/Guide/GuideGroup.tab"
local TABLE_GUIDE_FIGHT_PATH = "Share/Guide/GuideFight.tab"

-- 配置相关
local GuideCompleteTemplates = {}
local GuideStepTemplates = {}
local GuideGroupTemplates = {}
local GuideFightTemplates = {}

function XGuideConfig.Init()
    GuideCompleteTemplates = XTableManager.ReadByIntKey(TABLE_GUIDE_COMPLETE_PATH, XTable.XTableGuideComplete, "Id")
    GuideStepTemplates = XTableManager.ReadByIntKey(TABLE_GUIDE_STEP_PATH, XTable.XTableGuideStep, "Id")
    GuideGroupTemplates = XTableManager.ReadByIntKey(TABLE_GUIDE_GROUP_PATH, XTable.XTableGuideGroup, "Id")
    GuideFightTemplates = XTableManager.ReadByIntKey(TABLE_GUIDE_FIGHT_PATH, XTable.XTableGuideFight, "Id")

    for _, temp in pairs(GuideGroupTemplates) do
        local completeTemp = GuideCompleteTemplates[temp.CompleteId]
        if (not completeTemp) then
            XLog.Error("InitGuideGroupConfig error: can not found complete template, complete id is " .. temp.CompleteId .. ", group id is " .. temp.Id)
        end

        -- for i, stepId in ipairs(temp.StepIds) do
        --     local stepTemp = GuideStepTemplates[stepId]
        --     if (not stepTemp) then
        --         XLog.Error("InitGuideGroupConfig error: can not found step template, step id is " .. stepId .. ", group id is " .. temp.Id)
        --     end
        -- end
    end
end

function XGuideConfig.GetGuideCompleteTemplates()
    return GuideCompleteTemplates
end

function XGuideConfig.GetGuideCompleteTemplatesById(id)
    if not GuideCompleteTemplates then
        return
    end
    
    return GuideCompleteTemplates[id]
end


function XGuideConfig.GetGuideStepTemplates()
    return GuideStepTemplates
end

function XGuideConfig.GetGuideStepTemplatesById(id)
    if not GuideStepTemplates then
        return
    end
    
    return GuideStepTemplates[id]
end

function XGuideConfig.GetGuideGroupTemplates()
    return GuideGroupTemplates
end

function XGuideConfig.GetGuideGroupTemplatesById(id)
    if not GuideGroupTemplates then
        return
    end
    
    return GuideGroupTemplates[id]
end

function XGuideConfig.GetGuideFightTemplates()
    return GuideFightTemplates
end


function XGuideConfig.GetGuideFightTemplatesById(id)
    if not GuideFightTemplates then
        return
    end
    
    return GuideFightTemplates[id]
end
-- 红点条件检测器
--默认
local XRedPointConditionExplore = {}
XRedPointConditionExplore.__index = XRedPointConditionExplore

--检测
function XRedPointConditionExplore.Check(args)
    return XDataCenter.FubenExploreManager.IsRedPoint()
end

return XRedPointConditionExplore 
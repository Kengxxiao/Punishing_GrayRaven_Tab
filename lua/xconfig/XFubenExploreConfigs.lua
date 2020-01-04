XFubenExploreConfigs = XFubenExploreConfigs or {}

local TABLE_EXPLORE_BANNER =        "Client/Fuben/Explore/ExploreChapter.tab"
local TABLE_EXPLORE_BUFF =        "Share/Fuben/Explore/ExploreBuffItem.tab"
local TABLE_EXPLORE_CHAPTER =    "Share/Fuben/Explore/ExploreChapter.tab"
local TABLE_EXPLORE_NODE =        "Share/Fuben/Explore/ExploreNode.tab"
local TABLE_EXPLORE_STORYTEXT =    "Share/Fuben/Explore/ExploreStoryText.tab"

local ExploreBuffCfg = {}
local ExploreChapterCfg = {}
local ExploreNodeCfg = {}
local ExploreStoryTextCfg = {}

XFubenExploreConfigs.NodeStateEnum =    {
    Complete = 1, --已完成
    Availavle = 2, --可打
    Visivle = 3, --可看到不可打
    Invisivle = 4, --不可见
}

XFubenExploreConfigs.NodeTypeEnum =    {
    Stage = 1, --战斗
    Story = 2, --剧情
    Arena = 3, --竞技
}

function XFubenExploreConfigs.Init()
    ExploreBuffCfg = XTableManager.ReadByIntKey(TABLE_EXPLORE_BUFF, XTable.XTableExploreBuffItem, "Id")
    ExploreChapterCfg = XTableManager.ReadByIntKey(TABLE_EXPLORE_CHAPTER, XTable.XTableExploreChapter, "Id")
    ExploreNodeCfg = XTableManager.ReadByIntKey(TABLE_EXPLORE_NODE, XTable.XTableExploreNode, "Id")
    ExploreStoryTextCfg = XTableManager.ReadByIntKey(TABLE_EXPLORE_STORYTEXT, XTable.XTableExploreStoryText, "Id")
end

function XFubenExploreConfigs.GetExploreBuffCfg()
    return ExploreBuffCfg
end

function XFubenExploreConfigs.GetExploreChapterCfg()
    return ExploreChapterCfg
end

function XFubenExploreConfigs.GetExploreNodeCfg()
    return ExploreNodeCfg
end

function XFubenExploreConfigs.GetExploreStoryTextCfg()
    return ExploreStoryTextCfg
end

--获取某一章的全部关卡表数据
function XFubenExploreConfigs.GetAllLevel(chapterId)
    local tempList = {}
    for k, v in pairs(ExploreNodeCfg) do
        if v.ChapterId == chapterId then
            table.insert(tempList, v)
        end
    end
    return tempList
end

--获取某一关的表数据
function XFubenExploreConfigs.GetLevel(nodeId)
    if ExploreNodeCfg[nodeId] then
        return ExploreNodeCfg[nodeId]
    end
    XLog.Error("Can not find nodeId with id:", nodeId)
    return nil
end

--获取某一章的表数据
function XFubenExploreConfigs.GetChapterData(chapterId)
    return ExploreChapterCfg[chapterId]
end

--获取某一章的全部StoryText
function XFubenExploreConfigs.GetChapterStoryText(chapterId)
    local tempList = {}
    for i = 1, #ExploreStoryTextCfg do
        if ExploreStoryTextCfg[i].ChapterId == chapterId then
            table.insert(tempList, ExploreStoryTextCfg[i])
        end
    end
    return tempList
end

--获取某一章所有的buff
function XFubenExploreConfigs.GetChapterBuff(chapterId)
    local tempList = {}
    for i = 1, #ExploreBuffCfg do
        if ExploreBuffCfg[i].ChapterId == chapterId then
            table.insert(tempList, ExploreBuffCfg[i])
        end
    end
    return tempList
end

--获取某一个buff
function XFubenExploreConfigs.GetBuff(buffId)
    for i = 1, #ExploreBuffCfg do
        if ExploreBuffCfg[i].Id == buffId then
            return ExploreBuffCfg[i]
        end
    end
    return nil
end
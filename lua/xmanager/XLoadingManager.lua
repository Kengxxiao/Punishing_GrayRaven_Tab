LoadingType =
{
    Fight = "10101",--战斗
    Dormitory = "902",--宿舍
}

XLoadingManagerCreator = function()
    
    local XLoadingManager = {}

    local TABLE_LOADING_PATH = "Client/Loading/Loading.tab"

    --初始化
    function XLoadingManager.Init()

        local LoadingTemplate = XTableManager.ReadByIntKey(TABLE_LOADING_PATH, XTable.XTableLoading,"Id")

        local typeDic = {}

        --过滤Type
        for k, v in pairs(LoadingTemplate) do
            local type = v.Type
            local list = typeDic[type]
            if list == nil then
                list = {}
                typeDic[type] = list
            end
            table.insert(list,v)
        end

        XLoadingManager.TypeDic = typeDic

    end

    --根据类型以及权重取出loading的tab数据
    function XLoadingManager.GetLoadingTab(type)

        if not type then
            return
        end

        local loadingList = XLoadingManager.TypeDic[type]

        if not loadingList then
            XLog.Error(string.format("XLoadingManager.GetLoadingTab() error: not exist type:%s.",type))
            return
        end

        local count = #loadingList

        if count == 0 then
            XLog.Error(string.format("XLoadingManager.GetLoadingTab() error: Type:%s 未配置.",type))
            return
        end

        --只有一个直接返回
        if count == 1 then
            return loadingList[1]
        end

		--打乱数组
		for i = 1, count do
            if i < count then
                local temp = loadingList[i]
                local next = i + 1
                local swapIndex = math.random(next,count)
                loadingList[i] = loadingList[swapIndex]
                loadingList[swapIndex] = temp
            end
        end
		
        --根据权重获取
        local TotalWeight = 0

        --先计算权重总和
        for k,v in ipairs(loadingList) do
            TotalWeight = TotalWeight + v.Weight
        end

        local maxValue = 0
        local index = 1
        
        --选择权重最高的值
        for k,v in ipairs(loadingList) do
            local weight = math.random(0,TotalWeight)
            weight = weight + v.Weight
            if maxValue < weight then
                maxValue = weight
                index = k
            end
        end

        return loadingList[index]
    end


    XLoadingManager.Init()

    return XLoadingManager
    
end
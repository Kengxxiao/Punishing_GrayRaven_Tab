local table = table
local tableInsert = table.insert
local tableSort = table.sort

XDrawConfigs = XDrawConfigs or {}

XDrawConfigs.CombinationsTypes = {
    Normal       = 1,
    Aim          = 2,
    NewUp        = 3,
    Furniture    = 4,
    CharacterUp  = 5,
    EquipSuit    = 6,
}


local TABLE_DRAW_PREVIEW = "Client/Draw/DrawPreview.tab"
local TABLE_DRAW_PREVIEW_GOODS = "Client/Draw/DrawPreviewGoods.tab"
local TABLE_DRAW_COMBINATIONS = "Client/Draw/DrawCombinations.tab"
local TABLE_DRAW_PROB = "Client/Draw/DrawProbShow.tab"
local TABLE_GROUP_RULE = "Client/Draw/DrawGroupRule.tab"
local TABLE_DRAW_SHOW = "Client/Draw/DrawShow.tab"
local TABLE_DRAW_CAMERA = "Client/Draw/DrawCamera.tab"
local TABLE_DRAW_TABS = "Client/Draw/DrawTabs.tab"
local TABLE_DRAW_SHOW_CHARACTER = "Client/Draw/DrawShowCharacter.tab"

local DrawPreviews = {}
local DrawCombinations = {}
local DrawProbs = {}
local DrawGroupRule = {}
local DrawShow = {}
local DrawCamera = {}
local DrawTabs = {}
local DrawShowCharacter = {}

function XDrawConfigs.Init()
    DrawCombinations = XTableManager.ReadByIntKey(TABLE_DRAW_COMBINATIONS, XTable.XTableDrawCombinations, "Id")
    DrawGroupRule = XTableManager.ReadByIntKey(TABLE_GROUP_RULE, XTable.XTableDrawGroupRule, "Id")
    DrawShow = XTableManager.ReadByIntKey(TABLE_DRAW_SHOW, XTable.XTableDrawShow, "Type")
    DrawCamera = XTableManager.ReadByIntKey(TABLE_DRAW_CAMERA, XTable.XTableDrawCamera, "Id")
    DrawTabs = XTableManager.ReadByIntKey(TABLE_DRAW_TABS, XTable.XTableDrawTabs, "Id")
    DrawShowCharacter = XTableManager.ReadByIntKey(TABLE_DRAW_SHOW_CHARACTER, XTable.XTableDrawShowCharacter, "Id")
    
    local previews = XTableManager.ReadByIntKey(TABLE_DRAW_PREVIEW, XTable.XTableDrawPreview, "Id")
    local previewGoods = XTableManager.ReadByIntKey(TABLE_DRAW_PREVIEW_GOODS, XTable.XTableRewardGoods, "Id")
    local previewGoodsList = {}

    for drawId, preview in pairs(previews) do
        local upGoodsIds = preview.UpGoodsId
        local upGoods = {}
        for i = 1, #upGoodsIds do
            tableInsert(upGoods, XRewardManager.CreateRewardGoodsByTemplate(previewGoods[upGoodsIds[i]]))
        end

        local goodsIds = preview.GoodsId
        local goods = {}
        for i = 1, #goodsIds do
            tableInsert(goods, XRewardManager.CreateRewardGoodsByTemplate(previewGoods[goodsIds[i]]))
        end

        local drawPreview = {}
        drawPreview.UpGoods = upGoods
        drawPreview.Goods = goods
        DrawPreviews[drawId] = drawPreview
    end

    local drawProbList = XTableManager.ReadByIntKey(TABLE_DRAW_PROB, XTable.XTableDrawProbShow, "Id")
    for k, v in pairs(drawProbList) do
        if not DrawProbs[v.DrawId] then
            DrawProbs[v.DrawId] = {}
        end
        tableInsert(DrawProbs[v.DrawId], v)
    end
end

function XDrawConfigs.GetDrawCombinations()
    return DrawCombinations
end

function XDrawConfigs.GetDrawGroupRule()
    return DrawGroupRule
end

function XDrawConfigs.GetDrawShow()
    return DrawShow
end

function XDrawConfigs.GetDrawShowCharacter()
    return DrawShowCharacter
end

function XDrawConfigs.GetDrawCamera()
    return DrawCamera
end

function XDrawConfigs.GetDrawTabs()
    return DrawTabs
end

function XDrawConfigs.GetDrawPreviews()
    return DrawPreviews
end

function XDrawConfigs.GetDrawProbs()
    return DrawProbs
end

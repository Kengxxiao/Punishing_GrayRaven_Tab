XHeadPortraitManagerCreator = function()
    local XHeadPortraitManager ={}
    
    local TABLE_HEAD_HOWTOGET = "Client/HeadPortrait/HeadHowToGetText.tab"
    
    local HowToGetTexts = {}
    
    function XHeadPortraitManager.Init()
        HowToGetTexts = XTableManager.ReadByIntKey(TABLE_HEAD_HOWTOGET, XTable.XTableHeadHowToGetText, "Id")
    end
    
    function XHeadPortraitManager.GetHowToGetTexts()
        return HowToGetTexts
    end
    
    function XHeadPortraitManager.GetHowToGetTextById(Id)
        return HowToGetTexts[Id]
    end
    
    function XHeadPortraitManager.CheakIsNewHeadPortrait()
        local IsHaveNew = false
        local HeadPortraitIds = XPlayer.GetUnlockedHeadPortraitIds()
        for k,v in pairs(HeadPortraitIds) do
            if XSaveTool.GetData(XPlayer.Id.."NewHeadPortrait"..v.Id) then
                IsHaveNew = true
            end
        end
        return IsHaveNew 
    end
    
    function XHeadPortraitManager.CheakIsNewHeadPortraitById(Id)
        local IsHaveNew = false
        if XSaveTool.GetData(XPlayer.Id.."NewHeadPortrait"..Id) then
            IsHaveNew = true
        end
        return IsHaveNew 
    end
    
    function XHeadPortraitManager.SetHeadPortraitForOld(Id)
        if XSaveTool.GetData(XPlayer.Id.."NewHeadPortrait"..Id) then
            XSaveTool.RemoveData(XPlayer.Id.."NewHeadPortrait"..Id)
        end
    end
    
    function XHeadPortraitManager.AddNewHeadPortrait(Id)
        if not XSaveTool.GetData(XPlayer.Id.."NewHeadPortrait"..Id) then
            XSaveTool.SaveData(XPlayer.Id.."NewHeadPortrait"..Id,Id)
        end
    end
    
    XHeadPortraitManager.Init()
    return XHeadPortraitManager
end
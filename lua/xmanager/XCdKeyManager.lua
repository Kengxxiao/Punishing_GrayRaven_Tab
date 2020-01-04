XCdKeyManagerCreator = function()
    local XCdKeyManager = {}

    local XCdKeyRequest = {
        UseCdKeyRequest = "UseCdKeyRequest"
    }

    function XCdKeyManager.UseCdKeyRequest(id)
        if not id or id == "" then
            XUiManager.TipText("CdKeyIsEmpty")
            return
        end

        XNetwork.Call(XCdKeyRequest.UseCdKeyRequest, {Id = id}, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XUiManager.OpenUiObtain(res.RewardGoods)
        end)
    end

    return XCdKeyManager
end

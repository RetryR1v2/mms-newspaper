-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/RetryR1v2/mms-newspaper/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

      
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('Current Version: %s'):format(currentVersion))
            versionCheckPrint('success', ('Latest Version: %s'):format(text))
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end
local VORPcore = exports.vorp_core:GetCore()



RegisterServerEvent('mms-newspaper:client:registerinserat',function (inputTitle,inputLink,inputPn)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    local firstname = Character.firstname
    local lastname = Character.lastname
    local Money = Character.money
    MySQL.query('SELECT * FROM `mms_newspaper` WHERE identifier = ?', {identifier}, function(result)
        if result[1] ~= nil then
            VORPcore.NotifyTip(src, _U('AlreadyGotInserat'), 5000)
        else
            if Money >= Config.NewsPreis then
                VORPcore.NotifyTip(src, _U('SucessfullInserat'), 5000)
                Character.removeCurrency(0,Config.NewsPreis)
                MySQL.insert('INSERT INTO `mms_newspaper` (identifier,title,picture,firstname,lastname,pn) VALUES (?, ?, ?, ?, ?, ?)',
                {identifier,inputTitle,inputLink,firstname,lastname,inputPn}, function()end)
            else
                VORPcore.NotifyTip(src, _U('NotEnoghMoney'), 5000)
            end
        end
    end) 
end)


RegisterServerEvent('mms-newspaper:server:readnewspaper',function ()
    local src = source
    local count = MySQL.query.await('SELECT COUNT(*) FROM mms_newspaper;')[1]
    for _,v in pairs(count) do
        newscount = v
    end
    MySQL.query('SELECT `id`,`identifier`, `title`, `picture`,`firstname`, `lastname`, `pn` FROM `mms_newspaper`', {}, function(result)
        
        if result and #result ~= nil and newscount > 0 then
            local newsentrys = {}
            for _, news in ipairs(result) do
                table.insert(newsentrys, news)
            end
                TriggerClientEvent('mms-newspaper:client:opennewspaper', src, newsentrys)
        elseif newscount == 0 then
            VORPcore.NotifyTip(src, _U('NoNews'), 5000)
        end
    end)
end)

RegisterServerEvent('mms-newspaper:server:deleteinserat',function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local identifier = Character.identifier
    MySQL.query('SELECT * FROM `mms_newspaper` WHERE identifier = ?', {identifier}, function(result)
        if result[1] ~= nil then
            MySQL.execute('DELETE FROM mms_newspaper WHERE identifier = ?', { identifier }, function() end)
            VORPcore.NotifyTip(src, _U('DeletedInserat'), 5000)
        else
            VORPcore.NotifyTip(src, _U('NoInseratToDelte'), 5000)
        end
    end)
end)
--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
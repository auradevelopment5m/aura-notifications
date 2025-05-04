local resourceName = GetCurrentResourceName()

local function ShowNotification(source, data)
    if not source or not data or type(data) ~= 'table' then return end
    
    if not data.message then return end
    
    data.type = data.type or 'info'
    data.duration = data.duration or 5000
    
    TriggerClientEvent(resourceName .. ':showNotification', source, data)
end

local function ClearAllNotifications(source)
    TriggerClientEvent(resourceName .. ':clearAllNotifications', source)
end

RegisterCommand('testservernotif', function(source, args)
    local notifType = args[1] or 'info'
    local title = args[2] or 'Server Notification'
    local message = args[3] or 'This is a test notification from the server'
    local duration = tonumber(args[4]) or 5000
    
    ShowNotification(source, {
        type = notifType,
        title = title,
        message = message,
        duration = duration
    })
end, false)

RegisterCommand('testallservernotifs', function(source)
    local types = {
        'info', 'success', 'error', 'warning', 'bank', 'wallet',
        'police', 'ambulance', 'mechanic', 'phone', 'message', 'email',
        'job', 'admin', 'system'
    }
    
    local delay = 0
    for _, notifType in ipairs(types) do
        Citizen.SetTimeout(delay, function()
            ShowNotification(source, {
                type = notifType,
                title = 'Server Test: ' .. notifType,
                message = 'This is a server test notification of type: ' .. notifType,
                duration = 5000
            })
        end)
        delay = delay + 1000
    end
end, false)

RegisterNetEvent(resourceName .. ':showNotificationFromServer')
AddEventHandler(resourceName .. ':showNotificationFromServer', function(target, data)
    if not IsPlayerAceAllowed(source, 'command') then return end
    ShowNotification(target, data)
end)

RegisterNetEvent(resourceName .. ':clearAllNotificationsFromServer')
AddEventHandler(resourceName .. ':clearAllNotificationsFromServer', function(target)
    if not IsPlayerAceAllowed(source, 'command') then return end
    ClearAllNotifications(target)
end)

exports('ShowNotification', ShowNotification)
exports('ClearAllNotifications', ClearAllNotifications)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/testservernotif', 'Show a server notification', {
        { name = 'type', help = 'Notification type (info, success, error, etc.)' },
        { name = 'title', help = 'Notification title' },
        { name = 'message', help = 'Notification message' },
        { name = 'duration', help = 'Duration in ms (default: 5000)' }
    })
    
    TriggerEvent('chat:addSuggestion', '/testallservernotifs', 'Show test notifications of all types from server')
end)
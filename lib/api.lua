local _M = {}

local app = require('lib.app')

_M.hostname = 'http://penguin-daycare-simulator.appspot.com'
--_M.hostname = 'http://localhost:8080'

function _M:getPenguins(callback)
    local url = '/penguins#' .. math.random(1000, 9999)
    network.request(self.hostname .. url , 'GET', function (event)
        if not event.isError then
            local response = json.decode(event.response)
            if response then
                self.penguins = response
                callback()
            end
        end
    end)
end

function _M:sendVisit(id)
    local url = '/stat/visit'
    local request = {body = 'id=' .. id}
    network.request(self.hostname .. url , 'POST', function (event)
        if event.isError then
            app.alert('Network error')
        end
    end, request)
end

function _M:sendFish(id)
    local url = '/stat/fish'
    local request = {body = 'id=' .. id}
    network.request(self.hostname .. url , 'POST', function (event)
        if event.isError then
            app.alert('Network error')
        end
    end, request)
end

function _M:sendBellyrub(id)
    local url = '/stat/bellyrub'
    local request = {body = 'id=' .. id}
    network.request(self.hostname .. url , 'POST', function (event)
        if event.isError then
            app.alert('Network error')
        end
    end, request)
end

function _M:getPenguinInfo(id)
    for i = 1, #self.penguins do
        if self.penguins[i].id == id then
            return table.deepcopy(self.penguins[i])
        end
    end
end

return _M
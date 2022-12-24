local placeId = game.PlaceId
local allIds = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local fileExists, errorMessage = pcall(function()
  allIds = game:GetService("HttpService"):JSONDecode(readfile("NotSameServers.json"))
end)
if not fileExists then
  table.insert(allIds, actualHour)
  writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(allIds))
end

local function tpReturner()
  local site
  if foundAnything == "" then
    site = game:GetService("HttpService"):JSONDecode(game:HttpGet(string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", placeId)))
  else
    site = game:GetService("HttpService"):JSONDecode(game:HttpGet(string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s", placeId, foundAnything)))
  end
  local id = ""
  if site.nextPageCursor and site.nextPageCursor ~= "null" and site.nextPageCursor ~= nil then
    foundAnything = site.nextPageCursor
  end
  local num = 0
  for i, v in pairs(site.data) do
    local possible = true
    id = tostring(v.id)
    if tonumber(v.maxPlayers) > tonumber(v.playing) then
for _, existing in pairs(allIds) do
if num ~= 0 then
if id == tostring(existing) then
possible = false
end
else
if tonumber(actualHour) ~= tonumber(existing) then
pcall(function()
delfile("NotSameServers.json")
allIds = {}
table.insert(allIds, actualHour)
end)
end
end
num = num + 1
end
if possible then
table.insert(allIds, id)
pcall(function()
writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(allIds))
game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, id, game.Players.LocalPlayer)
end)
wait(4)
end
end
end
end

local function teleport()
while wait() do
pcall(tpReturner)
if foundAnything ~= "" then
pcall(tpReturner)
end
end
end

return teleport

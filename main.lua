local RelativeScriptPath = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
package.path = package.path .. ";" ..  RelativeScriptPath .. "?.lua";
local Common = require("common");

local DateCommand = "date +%s%N | cut -b1-13"
local TotalStartTime = Common.execute_command(DateCommand);

local function round_to_2dp(Number)
    return tonumber(string.format("%.2f", Number))
end

--> Decipher argument path
local FileName = "packages";
if arg[1] ~= nil then
    FileName = arg[1]:match("([^/]+)$"):gsub("%.lua$", "")
    local Directory = arg[1]:match("^(.*)/").. "/"
    package.path = package.path .. ";" .. Directory .. "/?.lua"
else
    --package = package.path.. ";" 
end

local Configuration = require(FileName);
local Colours = require("colours")

if Configuration.Settings.SuperuserCommand ~= "" then Configuration.Settings.SuperuserCommand = Configuration.Settings.SuperuserCommand.. " "; end

print(Colours.Blue.. "[ENTER] Beginning".. Colours.Reset);
for Index, Value in pairs(Configuration["Settings"]["Cores"]) do
    local StartTime = Common.execute_command(DateCommand);
    Value = string.lower(Value);
    local Core = require("cores/"..Value.."/"..Value);
    Value = Value:gsub("^%l", string.upper)
    print(Colours.Magenta.. Colours.Bold.. "[LOG] Executing: ".. Value.. " Core".. Colours.Reset)
    Core.execute(Configuration);
    local EndTime = Common.execute_command(DateCommand);
    print(Colours.Magenta.. Colours.Bold.. "[LOG] Completed: ".. Value.. " Core in ".. round_to_2dp((EndTime - StartTime) / 1000).. "s" .. Colours.Reset)
end
local TotalEndTime = Common.execute_command(DateCommand);
print(Colours.Blue.. "[EXIT] Finished: " ..round_to_2dp((TotalEndTime - TotalStartTime) / 1000).."s".. Colours.Reset);

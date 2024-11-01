if arg[1] ~= nil then
    print("Arg1 not nil", arg[1])
    package.path = package.path .. ";" .. arg[1] .. "/?.lua"
end
local Configuration = require("config");

if Configuration.Settings.SuperuserCommand ~= "" then Configuration.Settings.SuperuserCommand = Configuration.Settings.SuperuserCommand.. " "; end

for Index, Value in pairs(Configuration["Settings"]["Cores"]) do
    local Core = require("cores/"..Value.."/"..Value);
    Core.execute(Configuration);
end
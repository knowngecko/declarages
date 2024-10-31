local Colours = require("colours")
local Commands = {}

function Commands.shallow_copy(Table)
    local NewTable = {}
    for Index, Value in ipairs(Table) do
        NewTable[Index] = Value;
    end
    return NewTable;
end

function Commands.execute_command(Command, Prefix)
    if Prefix then Command = Prefix..Command; end
    local Handle = io.popen(Command);
    local Result = Handle:read("a");
    Handle:close();
    return Result;
end

function Commands.merge_arrays(Table1, Table2)
    local NewTable = Commands.shallow_copy(Table1);
    for Index, Value in ipairs(Table2) do
        table.insert(NewTable, Value);
    end

    return NewTable;
end

function Commands.subtract_arrays(TableToBeSubtracted, SubtractingTable)
    local NewTable = Commands.shallow_copy(TableToBeSubtracted)
    
    for Index = #NewTable, 1, -1 do
        local Value = NewTable[Index];
        for Index2, Value2 in ipairs(SubtractingTable) do
            if Value == Value2 then
                table.remove(NewTable, Index);
                break;
            end
        end
    end
    
    return NewTable
end

function Commands.ensure_confirmation()
    local Input = string.lower(io.read());
    if Input == "y" or Input == "yes" or Input == "" then
        return true;
    elseif Input == "n" or Input == "no" then
        return false;
    else
        print(Colours.Red.. "Unknown Input: ".. Input .." Assuming confirmation not granted!".. Colours.Reset);
    end
end

return Commands;
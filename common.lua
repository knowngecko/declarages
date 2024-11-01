local Colours = require("colours")
local Commands = {}

function Commands.get_script_dir()
    return debug.getinfo(1, "S").source:sub(2):match("(.*/)")
end

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

function Commands.fake_error(Message, ExitStatus)
    print(Colours.Red.. "[EXIT] " .. Message ..Colours.Reset);
    os.exit(ExitStatus);
end

function Commands.remove_path(Location, Prefix, Check)
    if os.execute(Prefix .."test -e " ..Location) then
        local Confirmation = true;
        if Check == true then
            io.write(Colours.Yellow.. Colours.Bold.."[INPUT REQUIRED] Are you sure you would like to REMOVE the path: ".. Location.. " (Y/n) ".. Colours.Reset);
            Confirmation = Commands.ensure_confirmation();
        end
        if Confirmation then
            print(Colours.Red.. Colours.Bold.."[LOG] Removing path: ".. Location.. Colours.Reset);
            if os.execute(Prefix.. "rm -r ".. Location) then
                return;
            end
        end
        Commands.fake_error("Unable to remove path: ".. Location, -2);
    end
end

function Commands.create_path(Location, Prefix, Check)
    if not os.execute(Prefix .."test -e " ..Location) then
        local Confirmation = true;
        if Check == true then
            io.write(Colours.Yellow.. Colours.Bold.. "[INPUT REQUIRED] Are you sure you would like to CREATE the path: ".. Location.. " (Y/n) ".. Colours.Reset);
            Confirmation = Commands.ensure_confirmation();
        end
        if Confirmation then
            print(Colours.Green.. Colours.Bold.."[LOG] Creating path: ".. Location.. Colours.Reset);
            if os.execute(Prefix.. "mkdir -p ".. Location) then 
                return;
            end
        end
        Commands.fake_error("Unable to create path at: ".. Location, -2);
    end
end

function Commands.raw_list_to_table(List)
    local Table = {}

    for Line in List:gmatch("([^\n]+)") do
        if Line ~= "" then
            table.insert(Table, Line);
        end
    end
    return Table;
end

return Commands;
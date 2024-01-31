-- functions.lua
local M = {}

local emojis = {
    "🎉", "🎈", "🎁", "💡", "🔥", "🌟", "🍀", "🍁", "🍄", "🌈",
    "🌊", "🌞", "🌜", "🍕", "🍔", "🍟", "🚀", "🛸", "⚽", "🎸"
}

local file_emoji_map = {}

function M.get_unique_emoji_for_file(file_name)
    file_name = file_name or vim.fn.expand('%:t')  -- Get current file name if not provided

    if not file_emoji_map[file_name] then
        local used_emojis = {}
        for _, emoji in pairs(file_emoji_map) do
            used_emojis[emoji] = true
        end

        local available_emojis = {}
        for _, emoji in ipairs(emojis) do
            if not used_emojis[emoji] then
                table.insert(available_emojis, emoji)
            end
        end

        if #available_emojis == 0 then
            print("No more available emojis")
            return
        end

        local index = math.random(1, #available_emojis)
        local emoji = available_emojis[index]
        file_emoji_map[file_name] = emoji
    end

    return file_emoji_map[file_name]
end

return M


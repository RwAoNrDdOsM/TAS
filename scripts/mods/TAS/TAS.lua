local mod = get_mod("TAS")

-- Globals
mod.playback = false
mod.recording = false
mod.recording_check = false
mod.buffered_inputs = {}
mod.current_playback = {}
mod.current_playback_index = 1
mod.current_recording = {}

-- Functions
mod.update = function (t)
    if mod.playback then -- If in playback state, play the inputs
        mod.play_inputs(t)
    end
    if mod.recording then
        mod.recording_check = true
    elseif not mod.recording and mod.recording_check then
        mod.save_playback(mod.current_recording)
        mod.recording_check = false
    end
end

mod.populate_playback = function(path) -- Get selected playback, will add proper pathing at a later date
    local path = path or ""
    local playback = mod:get("playback")
    if playback then
        mod.current_playback = playback
        mod:echo("Got Playback")
    else
        mod:echo("Failed to get Playback")
    end
end

mod.save_playback = function(playback)-- save selected playback, will add proper saving at a later date
    mod:set("playback", playback)
    if mod:get("playback") then
        mod:echo("Saved")
    else 
        mod:echo("Error Saving")
    end
end

mod.play_inputs = function(t)
    local next_buffered_input = next_buffered_input -- Local for the value
    if #mod.current_playback == 0 then -- If there is no playback, populate the table
        mod.populate_playback()
    end

    local index = mod.current_playback_index -- mod.current_playback_index can now be considered index

    if #mod.current_playback <= index then -- Checks if there is the current index in the current_playback
        if mod.current_playback[index].t >= t then -- Checks if the time of the current index in the current playback with the current time, to see if the current time is equal or greater
            local value = mod.current_playback[index].value -- Gets the value 
            local input_key = mod.current_playback[index].input_key --gets the input key
            if type(value) == "table" then
                value = Vector3Box.unbox(value)
            end
            next_buffered_input = { -- Makes the next buffered input a useable table
                value = value,
                input_key = input_key,
            }
        end
    end
    if next_buffered_input then
        table.insert(mod.buffered_inputs, next_buffered_input) -- If there is a table, add it to the buffered inputs
    end
end

mod.record_input = function (input_key, value, t)
    if not mod.recording then return -- do nothing if not in recording state
    elseif mod.recording then
        if value then
            mod:echo(tostring(input_key) .. " " .. tostring(value) .. " " .. tostring(t))
            if type(value) == "table" then
                local value_2 = Vector3Box(0,0,0)
                Vector3Box.store(value_2, value)
                value = value_2
            end

            local template = { -- Use template for recording inputs
                input_key = input_key,
                value = value,
                t = t,
            }
            table.insert(mod.current_recording, #mod.current_recording + 1, template) --Add input to current recording
        end
    end
end

-- Keybind Functions
mod.record_key = function()
    mod.recording = not mod.recording
    if mod.recording then 
        mod:echo("Recording Enabled")
    else
        mod:echo("Recording Disabled")
    end
end

mod.play_key = function()
    mod.playback = not mod.playback
    if mod.playback then 
        mod:echo("Playback Enabled")
    else
        mod:echo("Playback Disabled")
    end
end

-- Hooks
mod:hook(PlayerInputExtension, "get", function (func, self, input_key, consume)
    if not mod.playback and mod.recording then -- Checks if in recording state and records inputs if so
        local value = self.input_service:get(input_key, consume)
        local t = self._t

        if not self.enabled or not PlayerInputExtension.get_window_is_in_focus() then
            local value_type = type(value)

            if value_type == "userdata" then
                mod.record_input(input_key, Vector3.zero(), t)
                return func(self, input_key, consume)
            end

            mod.record_input(input_key, nil, t) -- Will Probaby remove.
            return func(self, input_key, consume)
        end

        local input_key_scale_data = self.input_key_scale[input_key]

        if value and input_key_scale_data then
            local scale = nil

            if input_key_scale_data.lerp_end_t == nil or input_key_scale_data.lerp_end_t <= t then
                scale = input_key_scale_data.end_scale
            else
                local p = (t - input_key_scale_data.lerp_start_t) / (input_key_scale_data.lerp_end_t - input_key_scale_data.lerp_start_t)
                scale = math.lerp(input_key_scale_data.start_scale, input_key_scale_data.end_scale, p)
            end

            mod.record_input(input_key, value * scale, t)
            return func(self, input_key, consume)
        end

        mod.record_input(input_key, value, t)
        return func(self, input_key, consume)
    elseif mod.playback then
        for i=1, #mod.buffered_inputs do -- For all tables in buffered inputs
            if mod.buffered_inputs[i].input_key == input_key then -- Check if current input key matches the current buffered input
                local value = mod.buffered_inputs[i].value -- Get the value of the buffered input
                table.remove(mod.buffered_inputs, i) -- If so, remove that input
                return value -- And return the appropriate value
            end
        end
    else --uses normal function if not above
        return func(self, input_key, consume)
    end
end)
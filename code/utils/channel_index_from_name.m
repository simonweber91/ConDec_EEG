function channel_index = channel_index_from_name(EEG, channel_names)

if isempty(channel_names{1})
    channel_index = [];
    return
else
    channels = split(channel_names{1}, ', ');

    channel_index = zeros(1,numel(channels));
    for i = 1:numel(channels)
        channel_index(i) = find(strcmpi(channels{i}, {EEG.chanlocs.labels}));
    end
end

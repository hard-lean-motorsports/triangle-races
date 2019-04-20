function arr_out = nan_end_extract(arr_in)
%nan_end_extract extracts a numerical array from a char array with NaNs
% Utility function
    arr_out = [];
    for i=2:length(arr_in)
        val = arr_in(i);
        if(~isnumeric(val))
            val = str2double(val);
        end
        if(~isnan(val))
            arr_out = [arr_out; val];
        end
    end
end


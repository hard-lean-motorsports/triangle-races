function [prev, next] = ring_index(i, length_arr)
    % ring_index This provides the previous and next indices of the ring buffer
    % USAGE: [prev, next] = ring_index(index, array_length)
    prev = i-1;
    if(prev == 0)
        prev = length_arr;
    end
    next = i+1;
    if(next > length_arr)
        next = 1;
    end
end


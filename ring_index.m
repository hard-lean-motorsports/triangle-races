function [prev, next] = ring_index(i, length_arr)
    prev = i-1;
    if(prev == 0)
        prev = length_arr;
    end
    next = i+1;
    if(next > length_arr)
        next = 1;
    end
end


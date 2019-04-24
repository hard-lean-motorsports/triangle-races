function [F, R, S] = load_transfer(lat_in, long_in, max_accel_arr, max_brake_arr, max_left_arr, max_right_arr)
    % load_transfer Function to calculate the relative load on each wheel based on the weights at maximal positions (max right Gs, max braking Gs, etc...
    % format of arrays is [accel in g, front % load, rear % load, side % load].
    
    if long_in > max_accel_arr(1) || long_in < max_brake_arr(1)
        error("Long_in above vehicle capability");
    end
    
    if lat_in > max_left_arr(1) || long_in < max_right_arr(1)
        error("Lat_in above vehicle capability");
    end
    
    max_brake = neg_val(max_brake_arr(1));
    max_accel = max_accel_arr(1);
    max_left = max_left_arr(1);
    max_right = neg_val(max_right_arr(1));
    
    long_rel_mult = 0;
    if(long_in < 0)
        long_rel_mult = long_in / max_brake;
    elseif(long_in > 0)
        long_rel_mult = long_in / max_accel;
    end
    
    lat_rel_mult = 0;
    if(lat_in < 0)
        lat_rel_mult = lat_in / max_right;
    elseif(lat_in > 0)
        lat_rel_mult = lat_in / max_left;
    end
    
    if(long_rel_mult == 0 && lat_rel_mult == 0)
        long_rel_mult = .5;
        lat_rel_mult = .5;
    end
    
    long_mult = long_rel_mult / (long_rel_mult + lat_rel_mult);
    lat_mult = lat_rel_mult / (long_rel_mult + lat_rel_mult);
    
    brake_mult = (long_in - max_accel) / (max_brake-max_accel);
    accel_mult = 1 - brake_mult;
    
    right_mult = (lat_in - max_left) / (max_right-max_left);
    left_mult = 1 - right_mult;
    
    brake_mult = brake_mult * long_mult;
    accel_mult = accel_mult * long_mult;
    right_mult = right_mult * lat_mult;
    left_mult = left_mult * lat_mult;
    
    F = brake_mult * max_brake_arr(2) + accel_mult * max_accel_arr(2) + left_mult * max_left_arr(2) + right_mult * max_right_arr(2);
    R = brake_mult * max_brake_arr(3) + accel_mult * max_accel_arr(3) + left_mult * max_left_arr(3) + right_mult * max_right_arr(3);
    S = brake_mult * max_brake_arr(4) + accel_mult * max_accel_arr(4) + left_mult * max_left_arr(4) + right_mult * max_right_arr(4);
end


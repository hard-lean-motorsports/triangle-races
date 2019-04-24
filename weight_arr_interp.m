function interp_arr = weight_arr_interp(vel, vel_arr, weight_arr, interp_flag)
    % interp_arr Utility function for getting interpolated weight arrays
    if(interp_flag == 0)
        interp_arr = weight_arr;
    else
        G = lin_interp(vel_arr, weight_arr(:, 1), vel);
        F = lin_interp(vel_arr, weight_arr(:, 2), vel);
        R = lin_interp(vel_arr, weight_arr(:, 3), vel);
        S = lin_interp(vel_arr, weight_arr(:, 4), vel);
        interp_arr = [G, F, R, S];
    end
end


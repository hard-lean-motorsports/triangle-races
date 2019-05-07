function [accel, throttle, weight_arr] = avail_accel(speed, rad, gg, weight_trans)
    % avail_accel This is just a utility function to return the maximum longditudinal acceration available at the current lateral acceleration
    % USAGE: accel = avail_accel(speed, radius, gg, max_speed)
    cir_accel = (speed^2) / rad;
    [~, accel, ~, throttle, weight_arr] = gg_accel(speed, cir_accel, [], gg, weight_trans);
end


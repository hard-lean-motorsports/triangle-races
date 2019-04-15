function [accel, throttle] = avail_accel(speed, rad, gg, max_speed)
    % avail_accel This is just a utility function to return the maximum longditudinal acceration available at the current lateral acceleration
    % USAGE: accel = avail_accel(speed, radius, gg, max_speed)
    cir_accel = (speed^2) / rad;
    [~, accel, ~, throttle] = gg_accel(speed, cir_accel, [], gg, max_speed);
end


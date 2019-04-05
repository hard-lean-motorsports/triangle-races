function time = phase_time(accel, init_speed, dist)
    % phase_time This is a utiliy function to return the number of seconds elapsed over a certain distance (in this simulation, 1 metre) with constant acceleration.
    % USAGE: time = phase_time(acceleration, initial_speed, distance)
    time = (-init_speed + sqrt((init_speed^2) - 4*(accel/2)*-dist))/(2*(accel/2));
end


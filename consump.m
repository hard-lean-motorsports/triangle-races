function fuel_consumed = consump(gg, vel, time, throttlepos)
    speed_step = gg{1};
    torque = gg{2};
    low_vel = floor(vel/speed_step) * speed_step;
    high_vel = ceil(vel/speed_step) * speed_step;

    
    
    high_vel_mult = .5;
    
    if(low_vel ~= high_vel)
        high_vel_mult = (vel - low_vel) / (high_vel - low_vel);
    end
    
    if(high_vel > gg{4})
        high_vel = low_vel;
        high_vel_mult = .5;
    end
    
    low_vel_mult = 1 - high_vel_mult;
    
    low_vel_index = round(low_vel / speed_step);
    gg_low = gg{low_vel_index};
    high_vel_index = round(high_vel / speed_step);
    gg_high = gg{high_vel_index};
    
    rpm = gg_high(1, 4) * high_vel_mult + gg_low(1, 4) * low_vel_mult;
    bilin_matrix = torque(:,3:end);
    x_arr = torque(:,1);
    y_arr = [1:-.05:.05]';
    if(throttlepos > 0.5)
        bsfc = bilin_interp(x_arr,y_arr,rpm,throttlepos,bilin_matrix);
    else
        bsfc = max(max(bilin_matrix));
    end
    torque = lin_interp(x_arr,torque(:,2),rpm) * throttlepos;
    rads = conv_unit(rpm, "rpm", "rad/s");
    power = (torque * rads) / 1000;
    fcps = (bsfc * power) / 3600;
    fuel_consumed = fcps * time;
end


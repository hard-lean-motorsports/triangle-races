function rpm = get_rpm(gg, vel)
    %get_rpm Returns RPM at speed
    
    speed_step = gg{1};
    low_vel = floor(vel/speed_step) * speed_step;
    high_vel = ceil(vel/speed_step) * speed_step;
   
    high_vel_mult = .5;
    
    if(low_vel ~= high_vel)
        high_vel_mult = (vel - low_vel) / (high_vel - low_vel);
    end
    
    low_vel_mult = 1 - high_vel_mult;
    
    low_vel_index = round(low_vel / speed_step);
    gg_low = gg{low_vel_index};
    high_vel_index = round(high_vel / speed_step);
    gg_high = gg{high_vel_index};
    
    rpm = gg_high(1, 4) * high_vel_mult + gg_low(1, 4) * low_vel_mult;
end


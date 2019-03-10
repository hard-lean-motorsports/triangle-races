function [lat, long, hybrid_p, gg_out, max_speed_out] = gg_accel(vel, lat_in, long_in, gg, max_speed)
    % gg_accel Returns speed dependant GG-diagram IMPORTANT: accelerations are in m/s^2
    % USAGE: [lat, long, hybrid_p, gg] = gg_accel(speed, lat_in, long_in)
    % Any argument may be "max" or "-max" and a maximum of that argument is returned
    % Convention is +left, -right, +forward, -rearward
    % If long_in is used, lat_in must be be empty parameter ([]) and
    % likewise if lat_in is used the long_in must be the empty parameter
    % (or skipped).

    hybrid_p = 0;
    
    if(~exist("gg", "var") || ~exist("max_speed", "var"))
        [gg, max_speed] = gg_gen();
    end
    max_speed_out = max_speed;

    gg_out = gg;
    
    if(vel > max_speed)
        lat = 0;
        long = 0;
        gg_out = gg;
        return
    end
    
    req = 0; %lat
    
    if(nargin > 2)
        if(isempty(lat_in))
            req = 1; %long
        elseif(isempty(long_in))
            req = 0;
        else
            error("gg_accel: Error: long_in and lat_in cannot both be used");
        end
    end
    
    low_vel = floor(vel);
    high_vel = ceil(vel);
   
    high_vel_mult = .5;
    
    if(low_vel ~= high_vel)
        high_vel_mult = (vel - low_vel) / (high_vel - low_vel);
    end
    
    low_vel_mult = 1 - high_vel_mult;
    
    gg_low = gg{low_vel};
    gg_high = gg{high_vel};
    
    [Y_low_max, I_low_max] = max(gg_low);
    [Y_high_max, I_high_max] = max(gg_high);
    [Y_low_min, I_low_min] = min(gg_low);
    [Y_high_min, I_high_min] = min(gg_high);
    
    if(num2str(lat_in) == "max")
        lat = gg_low(I_low_max(1),1) * low_vel_mult + gg_high(I_high_max(1),1) * high_vel_mult;
        long = 0;
    elseif(num2str(lat_in) == "-max")
        lat = gg_low(I_low_min(1),1) * low_vel_mult + gg_high(I_high_min(1),1) * high_vel_mult;
        long = 0;
    elseif(lat_in == 0)
        long_f = gg_low(I_low_max(2),2) * low_vel_mult + gg_high(I_high_max(2),2) * high_vel_mult;
        long_r = gg_low(I_low_min(3),3) * low_vel_mult + gg_high(I_high_min(3),3) * high_vel_mult;
        long = [long_f, long_r];
        lat = 0;
    elseif(num2str(long_in) == "max")
        long = gg_low(I_low_max(2),2) * low_vel_mult + gg_high(I_high_max(2),2) * high_vel_mult;
        lat = 0;
    elseif(num2str(long_in) == "-max")
        long = gg_low(I_low_min(3),3) * low_vel_mult + gg_high(I_high_min(3),3) * high_vel_mult;
        lat = 0;
    elseif(long_in == 0)
        lat_l = gg_low(I_low_max(1),1) * low_vel_mult + gg_high(I_high_max(1),1) * high_vel_mult;
        lat_r = gg_low(I_low_min(1),1) * low_vel_mult + gg_high(I_high_min(1),1) * high_vel_mult;
        long = 0;
        lat = [lat_l, lat_r];
    else
        
    end
end


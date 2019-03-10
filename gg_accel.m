function [lat, long, hybrid_p] = gg_accel(vel, lat_in, long_in)
    % gg_accel Returns speed dependant GG-diagram IMPORTANT: accelerations are in m/s^2
    % USAGE: [lat_g, long_g, hybrid_p] = gg_accel(speed, lat_in, long_in)
    % Any argument may be "max" or "-max" and a maximum of that argument is returned
    % Convention is +left, -right, +forward, -rearward
    % If long_in is used and lat_in is not max, -max or 0; lat_in will be 
    % ignored. This is a weird behaviour but makes sense in specific
    % use cases. Use lat_in unless you have a specific reason to use
    % long_in

    hybrid_p = 0;
    
    if(~exist(gg))
        gg = gg_gen()
    end

    if(vel > size(gg))
        lat = 0;
        long = 0;
        return;
    end
    
    low_vel = floor(vel);
    high_vel = ceil(vel);
    
    high_vel_mult = (vel - low_vel) / (high_vel - low_vel);
    low_vel_mult = 1 - high_vel_mult;
    
    gg_low = gg{low_vel};
    gg_high = gg{high_vel};
    
    if(lat_in == "max")
        [~, I_low] = max(gg_low);
        [~, I_high] = max(gg_high);
        lat = gg_low(I_low(1),1) * low_vel_mult + gg_high(I_high(1),1) * high_vel_mult;
        long = 0;
    elseif(lat_in == "-max")
        [~, I_low] = min(gg_low);
        [~, I_high] = min(gg_high);
        lat = gg_low(I_low(1),1) * low_vel_mult + gg_high(I_high(1),1) * high_vel_mult;
        long = 0;
    elseif(lat_in == 0)
        [~, I_low_f] = max(gg_low);
        [~, I_high_f] = max(gg_high);
        [~, I_low_r] = min(gg_low);
        [~, I_high_r] = min(gg_high);
        long_f = gg_low(I_low_f(2),2) * low_vel_mult + gg_high(I_high_f(2),2) * high_vel_mult;
        long_r = gg_low(I_low_r(2),2) * low_vel_mult + gg_high(I_high_r(2),2) * high_vel_mult;
        long = [long_f, long_r];
        lat = 0;
    else
        if(nargin <= 2)
            % TODO real bilinear interpolation (or like good 2d
            % interpolation)
        else
            
        end
    end
end


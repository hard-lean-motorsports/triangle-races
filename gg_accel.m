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
        lat = Y_low_max(1) * low_vel_mult + Y_high_max(1) * high_vel_mult;
        long = 0;
    elseif(num2str(lat_in) == "-max")
        lat = Y_low_min(1) * low_vel_mult + Y_high_min(1) * high_vel_mult;
        long = 0;
    elseif(num2str(long_in) == "max")
        long = Y_low_max(2) * low_vel_mult + Y_high_max(2) * high_vel_mult;
        lat = 0;
    elseif(num2str(long_in) == "-max")
        long = Y_low_min(3) * low_vel_mult + Y_high_min(3) * high_vel_mult;
        lat = 0;
    else
        if(req == 0)
            high_lat = lat_in;
            low_lat = lat_in;
            if(high_lat > Y_high_max(1))
                high_lat = Y_high_max(1);
                low_lat = (lat_in / low_vel_mult) - ((high_lat * high_vel_mult) / low_vel_mult);
                if(low_lat > Y_low_max(1))
                    error("gg_accel: Error: lat_in above vehicle capability");
                end
            elseif(high_lat < Y_high_min(1))
                high_lat = Y_high_max(1);
                low_lat = (lat_in / low_vel_mult) - ((high_lat * high_vel_mult) / low_vel_mult);
                if(low_lat < Y_low_min(1))
                    error("gg_accel: Error: lat_in above vehicle capability");
                end
            elseif(low_lat > Y_low_max(1))
                low_lat = Y_low_max(1);
                high_lat = (lat_in / high_vel_mult) - ((low_lat * low_vel_mult) / high_vel_mult);
                if(high_lat > Y_high_max(1))
                    error("gg_accel: Error: lat_in above vehicle capability");
                end
            elseif(low_lat < Y_low_min(1))
                low_lat = Y_low_min(1);
                high_lat = (lat_in / high_vel_mult) - ((low_lat * low_vel_mult) / high_vel_mult);
                if(high_lat < Y_high_min(1))
                    error("gg_accel: Error: lat_in above vehicle capability");
                end
            end
            long_low_f = lin_interp(gg_low(:,1), gg_low(:,2), low_lat, 0);
            long_high_f = lin_interp(gg_high(:,1), gg_high(:,2), high_lat, 0);
            long_low_r = lin_interp(gg_low(:,1), gg_low(:,3), low_lat, 0);
            long_high_r = lin_interp(gg_high(:,1), gg_high(:,3), high_lat, 0);
            lat = lat_in;
            long = [long_high_f * high_vel_mult + long_low_f * low_vel_mult, long_high_r * high_vel_mult + long_low_r * low_vel_mult];
        else
            high_long = long_in;
            low_long = long_in;
            if(high_long > Y_high_max(2))
                high_long = Y_high_max(2);
                low_long = (long_in / low_vel_mult) - ((high_long * high_vel_mult) / low_vel_mult);
                if(low_long > Y_low_max(2))
                    error("gg_accel: Error: long_in above vehicle capability");
                end
            elseif(high_long < Y_high_min(3))
                high_long = Y_high_max(3);
                low_long = (long_in / low_vel_mult) - ((high_long * high_vel_mult) / low_vel_mult);
                if(low_long < Y_low_min(3))
                    error("gg_accel: Error: long_in above vehicle capability");
                end
            elseif(low_long > Y_low_max(2))
                low_long = Y_low_max(2);
                high_long = (long_in / high_vel_mult) - ((long_lat * low_vel_mult) / high_vel_mult);
                if(high_long > Y_high_max(2))
                    error("gg_accel: Error: long_in above vehicle capability");
                end
            elseif(low_long < Y_low_min(1))
                low_long = Y_low_min(3);
                high_long = (long_in / high_vel_mult) - ((low_long * low_vel_mult) / high_vel_mult);
                if(high_long < Y_high_min(3))
                    error("gg_accel: Error: long_in above vehicle capability");
                end
            end
            x_arr_low = gg_low(:,2);
            x_arr_high = gg_high(:,2);
            if(low_long < 0)
                x_arr_low = gg_low(:,3);
            end
            if(high_long < 0)
                x_arr_high = gg_high(:,3);
            end
            y_arr_low_l = gg_low(gg_low(:,1) >= 0,1);
            y_arr_high_l = gg_high(gg_high(:,1) >= 0,1);
            y_arr_low_r = gg_low(gg_low(:,1) <= 0,1);
            y_arr_high_r = gg_high(gg_high(:,1) <= 0,1);
            size_low_l = length(y_arr_low_l);
            size_high_l = length(y_arr_high_l);
            size_low_r = length(y_arr_low_r);
            size_high_r = length(y_arr_high_r);
            x_arr_low_l = x_arr_low(size_low_l:end);
            x_arr_high_l = x_arr_high(size_high_l:end);
            x_arr_low_r = x_arr_low(1:size_low_r);
            x_arr_high_r = x_arr_high(1:size_high_r);
            
            lat_low_l = lin_interp(x_arr_low_l, y_arr_low_l, low_long, 0);
            lat_high_l = lin_interp(x_arr_high_l, y_arr_high_l, high_long, 0);
            lat_low_r = lin_interp(x_arr_low_r, y_arr_low_r, low_long, 0);
            lat_high_r = lin_interp(x_arr_high_r, y_arr_high_r, high_long, 0);
            long = long_in;
            lat = [lat_high_l * high_vel_mult + lat_low_l * low_vel_mult, lat_high_r * high_vel_mult + lat_low_r * low_vel_mult];
        end
    end
end


function [lat, long, energy, throttlebrake, gg_out, weight_arr] = gg_accel(vel, lat_in, long_in, gg, weight_trans)
    % gg_accel Returns speed dependant GG-diagram IMPORTANT: accelerations are in m/s^2
    % USAGE: [lat, long, energy, throttle, gg, max_speed_out] = gg_accel(speed, lat_in, long_in, gg, max_speed)
    % Any argument may be "max" or "-max" and a maximum of that argument is returned
    % Convention is +left, -right, +forward, -rearward
    % If long_in is used, lat_in must be be empty parameter ([]) and
    % likewise if lat_in is used the long_in must be the empty parameter
    % (or skipped).

    energy = 0;
    
    G = gg{7}{1};
    
    if(~exist("gg", "var"))
        [gg] = gg_gen();
    end
    speed_step = gg{1};
    gg_out = gg;
    
    if(vel > gg{4})
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
    
    low_vel = floor(vel/speed_step) * speed_step;
    high_vel = ceil(vel/speed_step) * speed_step;
   
    high_vel_mult = .5;
    
    if(low_vel ~= high_vel)
        high_vel_mult = (vel - low_vel) / (high_vel - low_vel);
    end
    
    if(high_vel >= gg{4} && low_vel <= gg{4})
        high_vel = low_vel;
        high_vel_mult = .5;
    elseif(low_vel <= gg{3} && high_vel >= gg{3})
        low_vel = high_vel;
        high_vel_mult = .5;
    elseif(vel < gg{3})
        error("Velocity " + vel + " too low");
    elseif(vel > gg{4})
        error("Velocity " + vel + " too high");
    end
    
    if(high_vel <= 0 || low_vel <= 0)
        error(high_vel + " or " + low_vel + " is or is below 0");
    end
    
    low_vel_mult = 1 - high_vel_mult;
    
    low_vel_index = round(low_vel / speed_step);
    gg_low = gg{low_vel_index};
    high_vel_index = round(high_vel / speed_step);
    gg_high = gg{high_vel_index};
    
    [Y_low_max, I_low_max] = max(gg_low);
    [Y_high_max, I_high_max] = max(gg_high);
    [Y_low_min, I_low_min] = min(gg_low);
    [Y_high_min, I_high_min] = min(gg_high);
    
    max_throttle = Y_low_max(2) * low_vel_mult + Y_high_max(2) * high_vel_mult;
    max_brake = Y_low_min(3) * low_vel_mult + Y_high_min(3) * high_vel_mult;
    
    if(num2str(lat_in) == "max")
        lat = Y_low_max(1) * low_vel_mult + Y_high_max(1) * high_vel_mult;
        long = 0;
        throttlebrake = [0, 0];
    elseif(num2str(lat_in) == "-max")
        lat = Y_low_min(1) * low_vel_mult + Y_high_min(1) * high_vel_mult;
        long = 0;
        throttlebrake = [0, 0];
    elseif(num2str(long_in) == "max")
        long = Y_low_max(2) * low_vel_mult + Y_high_max(2) * high_vel_mult;
        lat = 0;
        throttlebrake = [1, 0];
    elseif(num2str(long_in) == "-max")
        long = Y_low_min(3) * low_vel_mult + Y_high_min(3) * high_vel_mult;
        throttlebrake = [0, 1];
        lat = 0;
    elseif(lat_in == 0)
        long = [Y_low_max(2) * low_vel_mult + Y_high_max(2) * high_vel_mult, Y_low_min(3) * low_vel_mult + Y_high_min(3) * high_vel_mult];
        lat = 0;
        throttlebrake = [1, 1];
    elseif(long_in == 0)
        lat = [Y_low_max(1) * low_vel_mult + Y_high_max(1) * high_vel_mult, Y_low_min(1) * low_vel_mult + Y_high_min(1) * high_vel_mult];
        long = 0;
        throttlebrake = [0, 0];
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
                high_lat = Y_high_min(1);
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
            throttlebrake = [long(1)/max_throttle, long(2)/max_brake];
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
                high_long = Y_high_min(3);
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
            throttlebrake = [long/max_throttle, 0];
        end
    end
     weight_arr = [];
%     if(exist('weight_trans', 'var'))
%     
%         weight_low = weight_trans(low_vel_index, :);
%         weight_high = weight_trans(high_vel_index, :);
% 
%         max_accel_arr = weight_low{1} * low_vel_mult + weight_high{1} * high_vel_mult;
%         max_brake_arr = weight_low{2} * low_vel_mult + weight_high{2} * high_vel_mult;
%         max_left_arr = weight_low{3} * low_vel_mult + weight_high{3} * high_vel_mult;
%         max_right_arr = weight_low{4} * low_vel_mult + weight_high{4} * high_vel_mult;
% 
%         weight_lat = floor(lat*1000/G)/1000;
%         weight_long = floor(long*1000/G)/1000;
% 
%         [F, R, S] = load_transfer(weight_lat, weight_long, max_accel_arr, max_brake_arr, max_left_arr, max_right_arr);
%         weight_arr = [F, R, S];
%     end
end
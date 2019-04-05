function [v, gg, max_speed, min_speed] = speed_radius(rad, gg_in, max_speed_in, min_speed_in)
    % speed_radius Given a radius, return the maximum speed.
    % USAGE: [v, gg, max_speed] = speed_radius(rad, gg_in, max_speed_in);
    % gg and max_speed are optional and will be generated if not known.
    
    if(~exist("gg_in", "var") || ~exist("max_speed_in", "var"))
        [gg_in, max_speed_in] = gg_gen();
    end
    gg = gg_in;
    max_speed = max_speed_in;
    step = .01;
    
    max_dir = "max";
    
    if(rad < 0) % asymmetric vehicles are wild
       max_dir = "-max";
       rad = -rad;
    end
    
    if(~exist("min_speed_in", "var"))
        for i=1:max_speed
            if(~isempty(gg{i}))
                min_speed_in = i;
                break
            end 
        end
    end
    
    min_speed = min_speed_in;
    
    v = 0;
    
    for i=min_speed:step:max_speed
        lat_accel = gg_accel(i, max_dir, [], gg, max_speed);
        if(max_dir == "-max")
            lat_accel = -lat_accel;
        end
        if(sqrt(lat_accel*rad) >= i)
            v = i;
        end
    end
    
end


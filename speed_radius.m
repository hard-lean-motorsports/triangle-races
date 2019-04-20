function [v, gg] = speed_radius(rad, gg_in)
    % speed_radius Given a radius, return the maximum speed.
    % USAGE: [v, gg] = speed_radius(rad, gg_in);
    % gg is optional and will be generated if not known.
    
    if(~exist("gg_in", "var"))
        gg_in = gg_gen();
    end
    gg = gg_in;
    speed_step = gg{1};
    max_speed = gg{4};
    step = .001;
    
    max_dir = "max";
    
    if(rad < 0) % asymmetric vehicles are wild
       max_dir = "-max";
       rad = -rad;
    end
    
    min_speed = gg{3} + speed_step;
    
    v = 0;
    
    for i=max_speed:-step:min_speed
        lat_accel = gg_accel(i, max_dir, [], gg);
        if(max_dir == "-max")
            lat_accel = -lat_accel;
        end
        if(sqrt(lat_accel*rad) >= i)
            v = i;
            break
        end
    end
    
    if(v == 0)
        error("Maximum speed at the cornering radius is lower than the minimum speed of the vehicle.");
    end
    
end


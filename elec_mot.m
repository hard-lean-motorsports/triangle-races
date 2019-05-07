function [elec_accel, elec_consump] = elec_mot(accel, gg, vel, time, throttlebrake, weight_arr)
    elec_array = gg{6};
    vehicle_props = gg{7};
    
    f_mot_array = elec_array{8};
    r_mot_array = elec_array{9};
    s_mot_array = elec_array{10};
    f_mot_gear = 0;
    r_mot_gear = 0;
    s_mot_gear = 0;
    
    gg_index = floor(vel / gg{1});
    
    engine_gear = gg{gg_index}(:,5);
    
    gears = vehicle_props{6};
    
    if(~isempty(f_mot_array))
        if(strcmpi(elec_array{5},'gb'))
            f_mot_gear = gears(engine_gear);
        else
            f_mot_gear = elec_array{5};
        end
    end
    
    if(~isempty(r_mot_array))
        if(strcmpi(elec_array{6},'gb'))
            r_mot_gear = gears(engine_gear);
        else
            r_mot_gear = elec_array{6};
        end
    end
    
    if(~isempty(s_mot_array))
        if(strcmpi(elec_array{7},'gb'))
            s_mot_gear = gears(engine_gear);
        else
            s_mot_gear = elec_array{7};
        end
    end
    
    f_mot_rpm = 0;
    r_mot_rpm = 0;
    s_mot_rpm = 0;
    
    f_mot_eff = 0;
    r_mot_eff = 0;
    s_mot_eff = 0;
    
    if(f_mot_gear > 0)
        f_mot_rpm = (vehicle_props{3} * pi * f_mot_gear)/60;
    end
    
    if(r_mot_gear > 0)
        r_mot_rpm = (vehicle_props{4} * pi * r_mot_gear)/60;
    end
    
    if(s_mot_gear > 0)
        s_mot_rpm = (vehicle_props{5} * pi * s_mot_gear)/60;
    end
    
    elec_accel = 0;
    elec_consump = 0;
    
    if(throttlebrake < 0)
        brake_accel = accel;
        brake_accel_arr = brake_accel * weight_arr;
        disp(brake_accel_arr);
    end
    
    %mot_eff = bilin_interp(mot_array{1},mot_array{2},torque,rpm,mot_array{3});
end


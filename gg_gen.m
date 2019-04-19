function [gg, max_speed, min_speed] = gg_gen(bike_file)
    % gg_gen Generates speed dependant GG-diagram

    vd_table = readtable(bike_file, "Sheet", "vehicledyn");
    eng_table = readtable(bike_file, "Sheet", "engine");
    gear_table = readtable(bike_file, "Sheet", "gear");
    
    %% God factors
    epsilon = 1e-5;
    G = str2double(vd_table{1, 2}{1});
    
    
    %% VD factors
    W = str2double(vd_table{3, 2}{1});
    mu = 1;

    %% Aero factors
    rho = str2double(vd_table{2, 2}{1});
    cd = str2double(vd_table{5, 2}{1});
    cl = str2double(vd_table{6, 2}{1});
    A = str2double(vd_table{4, 2}{1});

    %% Powertrain factors
    torque = eng_table{:,:};
    final_drive_reductions = gear_table{:,2};
    final_drive = 1;
    for i=1:length(final_drive_reductions)
        if(~isnan(final_drive_reductions(i)))
            final_drive = final_drive * final_drive_reductions(i);
        end
    end
    gears = gear_table{:,4};
    cvt = 0;
    trans_eff = gear_table{1,1};
    

    %% Generation factors
    speed_step = .001;
    min_speed = speed_step; % m/s
    g_steps = 20;
    
    %% Start of generation
    % Everything in here should be meters, kg and newtons.
    speed = min_speed;
    f_tyre_dia_str = vd_table{7,2}{1};
    r_tyre_dia_str = vd_table{8,2}{1};
    s_tyre_dia_str = vd_table{9,2}{1};
    r_tyre_dia = tyre_dia_read(r_tyre_dia_str);
    f_tyre_dia = tyre_dia_read(f_tyre_dia_str);
    s_tyre_dia = tyre_dia_read(s_tyre_dia_str);
    w_rad_total = r_tyre_dia;
    w_cir = w_rad_total * 2 * pi;
    
    start = 0;
    
    while 1
        w_rps = (speed / w_cir);
        [w_torque, rpm, gear, fcps] = output_torque(torque, gears * final_drive, w_rps, cvt);
        drag = .5 * cd * A * rho * (speed^2);
        max_eng_accel = (((w_torque * trans_eff) / w_rad_total) - drag)/ W;
        if(max_eng_accel <= 0)
            if(start == 0)
                speed = speed + speed_step;
                continue
            end
            break
        else
           if(start == 0)
               start = speed;
           end
        end
        max_long_accel = (W * mu * G) / W; % Obvious but will be changed
        if(max_eng_accel > max_long_accel)
            max_eng_accel = max_long_accel;
        end
        max_brake_accel = ((W * mu * G) + drag)/ W; % Obvious but will be changed
        %max_lat_accel_right = (W * mu * lat_g_mult * G) / W; % Obvious but will be changed
        %max_lat_accel_left = (W * mu * lat_g_mult * G) / W; % Obvious but will be changed
        
        %-75
        %max_lat_accel_left = (3e-08*(speed^4) - 6e-06*(speed^3) + 0.0005*(speed^2) - 0.0174*speed + 1.7398) * G;
        %max_lat_accel_right = (-4e-10*(speed^5) + 1e-07*(speed^4) - 9e-06*(speed^3) + 0.0004*(speed^2) - 0.0075*speed - 1.3612) * G;
        
        %0
        max_lat_accel_left = (6e-08*(speed^4) - 1e-05*(speed^3) + 0.0008*(speed^2) - 0.0255*speed + 1.7681) * G;
        max_lat_accel_right = (-2e-10*(speed^5) + 6e-08*(speed^4) - 5e-06*(speed^3) + 0.0002*(speed^2) - 0.0038*speed - 1.4311) * G;
        
        %75
        %max_lat_accel_left = (9e-10*(speed^5) - 2e-07*(speed^4) + 2e-05*(speed^3) - 0.0008*(speed^2) + 0.0173*speed + 1.2628) * G;
        %max_lat_accel_right = (-4e-11*(speed^5) + 7e-09*(speed^4) - 4e-07*(speed^3) + 3e-06*(speed^2) + 0.0004*speed - 1.5062) * G;
        
        max_lat_accel_right = -max_lat_accel_right;
        
        g_steps_step = (max_lat_accel_left + max_lat_accel_right) / g_steps;
        
        this_gg = [];

        for i=-max_lat_accel_right:g_steps_step:max_lat_accel_left
            eng_accel = 0;
            brake_accel = 0;
            if(i < 0)
                t = real(acos(i/-max_lat_accel_right));
                eng_accel = real(max_long_accel * sin(t));
                if(eng_accel >= max_eng_accel)
                    eng_accel = max_eng_accel;
                end
                brake_accel = real(-max_brake_accel * sin(t));
            elseif(i == 0)
                eng_accel = max_eng_accel;
                brake_accel = -max_brake_accel;
            else
                t = real(acos(i/max_lat_accel_left));
                eng_accel = real(max_long_accel * sin(t));
                if(eng_accel >= max_eng_accel)
                    eng_accel = max_eng_accel;
                end
                brake_accel = -max_brake_accel * sin(t);
            end

            if(eng_accel < epsilon)
                eng_accel = 0;
            end
            if(abs(brake_accel) < epsilon)
                brake_accel = 0;
            end
            if(abs(i) < epsilon)
                i = 0;
            end
            
            this_gg = [this_gg;[i, eng_accel, brake_accel, rpm, gear, fcps]];
        end
        index = round(speed / speed_step);
        gg{index} = this_gg;

        speed = speed + speed_step;
    end
    min_speed = start;
    max_speed = speed-speed_step;
    gg{1} = speed_step;
end




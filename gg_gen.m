function [gg, max_speed, min_speed] = gg_gen(bike_file)
    % gg_gen Generates speed dependant GG-diagram

    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    vd_table = readtable(bike_file, "Sheet", "vehicledyn");
    eng_table = readtable(bike_file, "Sheet", "engine");
    gear_table = readtable(bike_file, "Sheet", "gear");
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
    
    %% God factors
    epsilon = 1e-5;
    G = str2double(vd_table{1, 2}{1});
    heating_value = str2double(vd_table{10, 2}{1}) * 1e6 * 1e-3;
    
    %% VD factors
    W = str2double(vd_table{3, 2}{1});
    mu = 1;
    accel_interp = 0;
    accel_interp_arr = [];
    accel_val = 0;
    brake_interp = 0;
    brake_interp_arr = [];
    brake_val = 0;
    left_interp = 0;
    left_interp_arr = [];
    left_val = 0;
    right_interp = 0;
    right_interp_arr = [];
    right_val = 0;
    
    if(isnan(vd_table{1, 4}))
        brake_interp = 1;
        brake_interp_arr = nan_end_extract(vd_table{2:end, 4});   
    else
        brake_val = vd_table{1, 4};
        if(~isnumeric(brake_val))
            brake_val = str2double(brake_val);
        end
    end
    if(isnan(vd_table{1, 8}))
        accel_interp = 1;
        accel_interp_arr = nan_end_extract(vd_table{2:end, 8});
    else
        accel_val = vd_table{1, 8};
        if(~isnumeric(accel_val))
            accel_val = str2double(accel_val);
        end
    end    
    if(isnan(vd_table{1, 12}))
        left_interp = 1;
        left_interp_arr = nan_end_extract(vd_table{2:end, 12});
    else
        left_val = vd_table{1, 12};
        if(~isnumeric(left_val))
            left_val = str2double(left_val);
        end
    end 
    if(isnan(vd_table{1, 16}))
        right_interp = 1;
        right_interp_arr = nan_end_extract(vd_table{2:end, 16});
    else
        right_val = vd_table{1, 16};
        if(~isnumeric(right_val))
            right_val = str2double(right_val);
        end
    end 
    
    interp_arr = nan_end_extract(vd_table{2:end, 3});

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
        [w_torque, rpm, gear] = output_torque(torque, gears * final_drive, w_rps, cvt);
        drag = .5 * cd * A * rho * (speed^2);
        lift = .5 * cl * A * rho * (speed^2);
        lift_mult = 1;
        if(lift < 0)
            lift_mult = (W*G-lift) / (W*G);
        elseif(lift > 0)
            lift_mult = (W*G) / (W*G+lift);
        end
        
        max_eng_accel = (((w_torque * trans_eff) / w_rad_total) - drag)/ W;
        if(max_eng_accel <=0)
            break
        end
        max_long_accel = 0;
        if(accel_interp)
            max_long_accel = lin_interp(interp_arr,accel_interp_arr,speed) * G;
        else
            max_long_accel = accel_val * lift_mult * G;
        end
        if(max_eng_accel > max_long_accel)
            max_eng_accel = max_long_accel;
        end
        
        max_brake_accel = 0;
        if(brake_interp)
            brake_accel_val = lin_interp(interp_arr,brake_interp_arr,speed);
            if(brake_accel_val < 0)
                brake_accel_val = -brake_accel_val;
            end
            max_brake_accel = brake_accel_val * G;
        else
            if(brake_val < 0)
                brake_val = -brake_val;
            end
            max_brake_accel = brake_val * lift_mult * G + (drag / W);
        end
        
        max_lat_accel_left = 0;
        if(left_interp)
            max_lat_accel_left = lin_interp(interp_arr,left_interp_arr,speed) * G;
        else
            max_lat_accel_left = left_val * lift_mult * G;
        end
        
        max_lat_accel_right = 0;
        if(right_interp)
            right_accel_val = lin_interp(interp_arr,right_interp_arr,speed);
            if(right_accel_val < 0)
                right_accel_val = -right_accel_val;
            end
            max_lat_accel_right = right_accel_val * G;
        else
            if(right_val < 0)
                right_val = -right_val;
            end
            max_lat_accel_right = right_val * lift_mult * G;
        end
        
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
            
            this_gg = [this_gg;[i, eng_accel, brake_accel, rpm, gear]];
        end
        index = round(speed / speed_step);
        gg{index} = this_gg;

        speed = speed + speed_step;
    end
    
    min_speed = 6*speed_step;
    max_speed = speed-speed_step;
    gg{1} = speed_step;
    gg{2} = torque;
    gg{3} = min_speed;
    gg{4} = max_speed;
    gg{5} = heating_value;
end
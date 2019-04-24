function [gg, max_speed, min_speed] = gg_gen(bike_file)
    % gg_gen Generates speed dependant GG-diagram

    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    vd_table = readtable(bike_file, "Sheet", "vehicledyn");
    eng_table = readtable(bike_file, "Sheet", "engine");
    gear_table = readtable(bike_file, "Sheet", "gear");
    electric_table = readtable(bike_file, "Sheet", "electric");
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
    
    %% God factors
    epsilon = 1e-5;
    G = str2double(vd_table{1, 2}{1});
    heating_value = str2double(vd_table{10, 2}{1}) * 1e6 * 1e-3;
    
    %% VD factors
    W = str2double(vd_table{3, 2}{1});
    accel_interp = 0;
    accel_interp_arr = [];
    accel_weight_arr = [];
    accel_val = 0;
    brake_interp = 0;
    brake_interp_arr = [];
    brake_weight_arr = [];
    brake_val = 0;
    left_interp = 0;
    left_interp_arr = [];
    left_weight_arr = [];
    left_val = 0;
    right_interp = 0;
    right_interp_arr = [];
    right_weight_arr = [];
    right_val = 0;
    
    [brake_interp, brake_interp_arr, brake_val, brake_weight_arr] = extract_vd_info(vd_table, 4);
    [accel_interp, accel_interp_arr, accel_val, accel_weight_arr] = extract_vd_info(vd_table, 8);
    [left_interp, left_interp_arr, left_val, left_weight_arr] = extract_vd_info(vd_table, 12);
    [right_interp, right_interp_arr, right_val, right_weight_arr] = extract_vd_info(vd_table, 16);
    
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

    
    %% Electric factors
    f_motor_extant = check_numeric(electric_table{1,2});
    r_motor_extant = check_numeric(electric_table{2,2});
    s_motor_extant = check_numeric(electric_table{3,2});
    f_motor_gear = 0;
    r_motor_gear = 0;
    s_motor_gear = 0;
    if(f_motor_extant)
        f_motor_gear = check_cell(electric_table{1,3});
        if(~strcmpi(f_motor_gear, 'gb'))
            f_motor_gear = check_numeric(f_motor_gear);
        end         
    end
    if(r_motor_extant)
        r_motor_gear = check_cell(electric_table{2,3});
        if(~strcmpi(r_motor_gear, 'gb'))
            r_motor_gear = check_numeric(r_motor_gear);
        end 
    end
    if(s_motor_extant)
        s_motor_gear = check_cell(electric_table{3,3});
        if(~strcmpi(s_motor_gear, 'gb'))
            s_motor_gear = check_numeric(s_motor_gear);
        end 
    end
    control_eff = check_numeric(electric_table{1,4});
    battery_eff = check_numeric(electric_table{1,5});
    supercap_eff = check_numeric(electric_table{1,6});
    voltage = check_numeric(electric_table{1,7});
    
    f_motor = {};
    r_motor = {};
    s_motor = {};
    
    
    if(f_motor_extant)
        f_motor = extract_motor(bike_file, "f");
    end
    
    if(s_motor_extant)
        s_motor = extract_motor(bike_file, "s");
    end
    
    if(r_motor_extant)
        r_motor = extract_motor(bike_file, "r");
    end
    
    electric_array = {voltage, control_eff, battery_eff, supercap_eff, f_motor_gear, r_motor_gear, s_motor_gear, f_motor, r_motor, s_motor};
    
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
    w_rad_total = r_tyre_dia / 2;
    w_cir = w_rad_total * 2 * pi;
    
    start = 0;
    
    while 1
        w_rps = (speed / w_cir);
        w_rps_r = w_rps;
        w_rps_f = (speed / (f_tyre_dia * pi));
        w_rps_s = (speed / (s_tyre_dia * pi));
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
        max_pure_brake_accel = 0;
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
            max_pure_brake_accel = brake_val * lift_mult;
            max_brake_accel = max_pure_brake_accel * G + (drag / W);
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
            avail_eng_accel = 0;
            if(i < 0)
                t = real(acos(i/-max_lat_accel_right));
                eng_accel = real(max_long_accel * sin(t));
                avail_eng_accel = eng_accel;
                if(eng_accel >= max_eng_accel)
                    eng_accel = max_eng_accel;
                end
                brake_accel = real(-max_brake_accel * sin(t));
                brake_accel_pure = real(-max_pure_brake_accel * sin(t));
            elseif(i == 0)
                eng_accel = max_eng_accel;
                avail_eng_accel = max_long_accel;
                brake_accel = -max_brake_accel;
                brake_accel_pure = -max_pure_brake_accel;
            else
                t = real(acos(i/max_lat_accel_left));
                eng_accel = real(max_long_accel * sin(t));
                avail_eng_accel = eng_accel;
                if(eng_accel >= max_eng_accel)
                    eng_accel = max_eng_accel;
                end
                brake_accel = -max_brake_accel * sin(t);
                brake_accel_pure = -max_pure_brake_accel * sin(t);
            end

            if(eng_accel < epsilon)
                eng_accel = 0;
            end
            if(abs(brake_accel) < epsilon)
                brake_accel = 0;
            end
            if(avail_eng_accel < epsilon)
                avail_eng_accel = 0;
            end
            if(abs(brake_accel_pure) < epsilon)
                brake_accel_pure = 0;
            end
            if(abs(i) < epsilon)
                i = 0;
            end
            
            f_motor_gear = 0;
            r_motor_gear = 0;
            s_motor_gear = 0;
            if(electric_array{5} ~= 0)
                if(strcmpi(electric_array{5}, 'gb'))
                    f_motor_gear = gears(gear) * final_drive;
                else
                    f_motor_gear = electric_array{5};
                end
            end
            
            if(electric_array{6} ~= 0)
                if(strcmpi(electric_array{6}, 'gb'))
                    r_motor_gear = gears(gear) * final_drive;
                else
                    r_motor_gear = electric_array{6};
                end
            end
            
            if(electric_array{7} ~= 0)
                if(strcmpi(electric_array{7}, 'gb'))
                    s_motor_gear = gears(gear) * final_drive;
                else
                    s_motor_gear = electric_array{7};
                end
            end
            
            max_accel_arr = weight_arr_interp(speed, interp_arr, accel_weight_arr, accel_interp);
            max_brake_arr = weight_arr_interp(speed, interp_arr, brake_weight_arr, brake_interp);
            max_left_arr = weight_arr_interp(speed, interp_arr, left_weight_arr, left_interp);
            max_right_arr = weight_arr_interp(speed, interp_arr, right_weight_arr, right_interp);
            lat_load_trans = floor((i/G) * 1000)/1000;
            eng_load_trans = floor((eng_accel/G) * 1000)/1000;
            brake_load_trans = floor((brake_accel_pure/G) * 1000)/1000;
            [f_weight_eng, r_weight_eng, s_weight_eng] = load_transfer(lat_load_trans, eng_load_trans, max_accel_arr, max_brake_arr, max_left_arr, max_right_arr);
            [f_weight_brake, r_weight_brake, s_weight_brake] = load_transfer(lat_load_trans, brake_load_trans, max_accel_arr, max_brake_arr, max_left_arr, max_right_arr);
            this_gg = [this_gg;[i, eng_accel, brake_accel, rpm, gear, avail_eng_accel, ...
                {w_rps_f, w_rps_r, w_rps_f}, {f_weight_eng, r_weight_eng, ...
                s_weight_eng}, {f_weight_brake, r_weight_brake, s_weight_brake}, ...
                {f_motor_gear, r_motor_gear, s_motor_gear} ...
                ]];
        end
        index = round(speed / speed_step);
        gg{index} = this_gg;

        speed = speed + speed_step;
    end
    
    min_speed = 7*speed_step;
    max_speed = speed-speed_step;
    gg{1} = speed_step;
    gg{2} = torque;
    gg{3} = min_speed;
    gg{4} = max_speed;
    gg{5} = heating_value;
    gg{6} = electric_array;
end
function [gg, max_speed, min_speed] = gg_gen(engine_file)
    % gg_gen Generates speed dependant GG-diagram
    % USAGE: [gg, max_speed, min_speed] = gg_gen() (no arguments yet)


    %% Fundimental structure of the gg datastructure:
    % gg: cell vector of gg circles, index by speed (in m/s)
    % gg(#): list of row vectors (matrix) containing lateral g, longditudal g,
    % and hybrid power consumption/output in that order [lat_g, long_g,
    % hybrid_p]

    % gg_gen takes the definitions in this file and generates the gg structure,
    % no arguments are needed.

    %% God factors
    G = 9.80665; % damn son that's some __accurate__ G
    epsilon = 1e-5;
    
    %% VD factors
    lat_g_mult = 1.0
    long_g_mult = 1.0
    mu = 1.2; % simp for now 
    W = 180;
    w_dia = 13; % this is inches. sorry
    w_aspect = 55;
    w_section = 185; % (totally not the standard size for a Caterham)
    w_compress = 1; % this is related to the estimated REAL diameter of the tyre, 1 * unloaded diameter to get the real diameter


    %% Aero factors
    aero_decrease_mult = 1.0
    rho = 1.2; 
    cd = .3 / aero_decrease_mult;
    A = 1.2;

    %% Powertrain factors
    torque = engine_gen(engine_file);
    final_drive = 2.219 * 2.929; % almost all bikes have two reductions
    gears = [2.929, 2.056, 1.619, 1.333, 1.154, 1.037]; % stole from Ninja 400
    cvt = 0; % in an spooky voice: _latterrrr_
    trans_eff = .9;
    torque_test_mult = 1.0
    

    %% Hybrid factors
    hybrid = 0; %fak off

    %% Generation factors
    speed_step = .001;
    min_speed = speed_step; % m/s
    g_steps = 20;
    
    %% Start of generation
    % Everything in here should be meters, kg and newtons.
    speed = min_speed;
    w_rad_total = ((w_aspect / 100)*conv_unit(w_section, "mm", "m") + conv_unit(w_dia, "in", "m")) / 2;
    w_rad_total = w_rad_total * w_compress;
    w_cir = w_rad_total * 2 * pi;
    
    start = 0;
    
    while 1
        w_rps = (speed / w_cir);
        [w_torque, rpm, gear] = output_torque(torque, gears * final_drive, w_rps, cvt);
        drag = .5 * cd * A * rho * (speed^2);
        max_eng_accel = (((w_torque * torque_test_mult * trans_eff) / w_rad_total) - drag)/ W;
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
        max_long_accel = (W * mu * long_g_mult * G) / W; % Obvious but will be changed
        if(max_eng_accel > max_long_accel)
            max_eng_accel = max_long_accel;
        end
        max_brake_accel = ((W * mu * long_g_mult * G) + drag)/ W; % Obvious but will be changed
        max_lat_accel_right = (W * mu * lat_g_mult * G) / W; % Obvious but will be changed
        max_lat_accel_left = (W * mu * lat_g_mult * G) / W; % Obvious but will be changed
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
    min_speed = start;
    max_speed = speed-speed_step;
    gg{1} = speed_step;
end




function [gg, max_speed, min_speed] = gg_gen()
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

    %% VD factors
    mu = .9; % simp for now 
    W = 180;
    w_dia = 13; % this is inches. sorry
    w_aspect = 55;
    w_section = 185; % (totally not the standard size for a Caterham)
    w_compress = 1; % this is related to the estimated REAL diameter of the tyre, 1 * unloaded diameter to get the real diameter


    %% Aero factors
    rho = 1.2; 
    cd = .3;
    A = 1.2;

    %% Powertrain factors
    torque = engine_gen();
    final_drive = 2.219 * 2.929; % almost all bikes have two reductions
    gears = [2.929, 2.056, 1.619, 1.333, 1.154, 1.037]; % stole from Ninja 400
    cvt = 0; % in an spooky voice: _latterrrr_
    trans_eff = .9;

    %% Hybrid factors
    hybrid = 0; %fak off

    %% Generation factors
    min_speed = 1; % m/s
    speed_step = 1;
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
        max_lat_accel_right = (W * mu * G) / W; % Obvious but will be changed
        max_lat_accel_left = (W * mu * G) / W; % Obvious but will be changed
        g_steps_step = (max_lat_accel_left + max_lat_accel_right) / g_steps;
        
        this_gg = [];

        for i=-max_lat_accel_right:g_steps_step:max_lat_accel_left
            eng_accel = 0;
            brake_accel = 0;
            if(i < 0)
                t = acos(i/-max_lat_accel_right);
                eng_accel = max_long_accel * sin(t);
                if(eng_accel >= max_eng_accel)
                    eng_accel = max_eng_accel;
                end
                brake_accel = -max_brake_accel * sin(t);
            elseif(i == 0)
                eng_accel = max_eng_accel;
                brake_accel = -max_brake_accel;
            else
                t = acos(i/max_lat_accel_left);
                eng_accel = max_long_accel * sin(t);
                if(eng_accel >= max_eng_accel)
                    eng_accel = max_eng_accel;
                end
                brake_accel = -max_brake_accel * sin(t);
            end

            this_gg = [this_gg;[i, eng_accel, brake_accel, rpm, gear]];
        end

        gg{speed} = this_gg;

        speed = speed + speed_step;
    end
    min_speed = start;
    max_speed = speed-1;
end


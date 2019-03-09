function [gg, max_speed] = gg_gen()
    % gg_gen Generates speed dependant GG-diagram
    % USAGE: gg = gg_gen() (no arguments yet)


    %% Fundimental structure of the gg datastructure:
    % gg: cell vector of gg circles, index by speed (in m/s)
    % gg(#): list of row vectors (matrix) containing lateral g, longditudal g,
    % and hybrid power consumption/output in that order [lat_g, long_g,
    % hybrid_p]

    % gg_gen takes the definitions in this file and generates the gg structure,
    % no arguments are needed.

    %% VD factors
    mu = 1.8; % simp for now 
    W = 180;
    w_dia = 13; % this is inches. sorry
    w_aspect = 55;
    w_section = 185; % (totally not the standard size for a Caterham)


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
    g_step = .1;

    
    %% Start of generation
    speed = min_speed;
    gear = 1;
end


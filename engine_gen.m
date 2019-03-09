function torque = engine_gen()
    % engine_gen Builds the engine rpm/torque vector from an external CSV file
    % CSV MUST be rpm, torque (Nm)
    torque = [];
    torque_file = uigetfile('*.csv');
    torque = csvread(torque_file);
end

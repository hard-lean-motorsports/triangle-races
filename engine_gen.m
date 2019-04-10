function torque = engine_gen(torque_file)
    % engine_gen Builds the engine rpm/torque vector from an external CSV file
    % CSV MUST be rpm, torque (Nm)
    torque = [];
    torque = csvread(torque_file);
end


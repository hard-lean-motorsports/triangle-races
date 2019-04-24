function motor_table = extract_motor(bike_file, motor_string)
    % extract_motor Utility function to extract motor efficiency tables
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    motor_in_table = readtable(bike_file, "Sheet", "motor_" + motor_string);
    motor_torque_array = nan_end_extract(motor_in_table{1:end,2});
    motor_rpm_array = nan_end_extract(motor_in_table{1,2:end});
    motor_eff_table = [];
    for i=1:length(motor_rpm_array)
        torque_arr = nan_end_extract(motor_in_table{1:end,i+2});
        motor_eff_table = [motor_eff_table, torque_arr];
    end
    motor_table = {motor_torque_array, motor_rpm_array, motor_eff_table};
    warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end


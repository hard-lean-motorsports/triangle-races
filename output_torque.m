function [torque_wheel, rpm, gear] = output_torque(torque_arr, gears, wheel_speed, cvt, cvt_steps)
    % output_torque This function handles gear selection and outputs the torque at the wheel assuming 100 eff
    % It also returns the RPM of the motor and the gear selected for
    % accouting purposes.
    % torque_arr must be a matrix of RPM, Nm torque listings
    % gears must be gears in order, multiplied by the final drive.
    % wheel_speed should be the rotational speed of the wheel in rotations
    % per second.
    % USEAGE: [eng_torque, rpm, gear] = output_torque(torque_arr, gears, wheel_speed, cvt, cvt_steps)
    % In normal operation (cvt omitted or 0) the function compares the
    % torque output in all gears in the gear array and returns the most
    % favourable.
    % In CVT mode, the operation is very different. The gears array now
    % should be the maximum and minimum CVT ratios (in that order) and the
    % function will search within that range with a number of steps
    % (default 100) and return the most favourable position of the CVT. The 
    % gear return value is now not the selected gear but the fraction 
    % through the range, with 0 being the maximum reduction and 1 being the minimum.
     
    if(nargin < 4)
        cvt = 0;
    end
    
    if(nargin < 5)
        cvt_steps = 100;
    end
    
    max_rpm = max(torque_arr(:,1));
    
    if(cvt == 0)
        torques = zeros(length(gears), 3);
        max_torque = -1;
        max_torque_ele = 0;
        for i=1:length(gears)
            torque = 0;
            rpm = conv_unit(wheel_speed * gears(i), "rps", "rpm");
            if(rpm < max_rpm)
                torque = lin_interp(torque_arr(:,1), torque_arr(:,2), rpm);
                torque = torque * gears(i);
                
                if(torque < 0)
                    torque = 0;
                end
            end
            if(torque > max_torque)
                max_torque = torque;
                max_torque_ele = i;
            end
            torques(i,:) = [torque, rpm, i];
            
        end
        torque_wheel = torques(max_torque_ele,1);
        rpm = torques(max_torque_ele,2);
        gear = torques(max_torque_ele,3);
    else
        gear_step = (gears(2) - gears(1)) / cvt_steps;
        torques = zeros(cvt_step);
        max_torque = 0;
        max_torque_ele = 0;
        for i=0:cvt_steps
            torque = 0;
            gear_ratio = (gears(1) - gear_step * i);
            range_gear = 0/cvt_steps;
            rpm = conv_unit(wheel_speed * gear_ratio, "rps", "rpm");
            if(rpm < max_rpm)
                torque = lin_interp(torque_arr(:,1), torque_arr(:,2), rpm) * gear_ratio;
            end
            if(torque >= max_torque)
                max_torque = torque;
                max_torque_ele = i;
            end
            torques(i) = [torque, rpm, range_gear];
        end
        [torque_wheel, rpm, gear] = torques(max_torque_ele);
    end
end

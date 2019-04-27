function accel = max_wheel_accel(dir, powered_wheels_arg, max_accel_arr, max_brake_arr, max_left_arr, max_right_arr)
    % max_wheel_accel returns the maximum longditunal acceleration considering weight transfer
    % powered_wheels_arg is in the form [x, x, x], with a 1 for each wheel
    % being considered to be part of the acceleration process, in the order
    % front, rear, side.
    % dir is anything for acceleration (best practice 1), -1 for braking.

    if(dir == -1)
        accel = sum((max_brake_arr(2:end) .* powered_wheels_arg) .* neg_val(max_brake_arr(1)));
    else
        accel = sum((max_accel_arr(2:end) .* powered_wheels_arg) .* max_accel_arr(1));
    end
    
%     dir=1;
%     powered_wheels_arg = [0, 1, 0];
%     max_accel_arr = [1, .3, .3, .3];
%     max_brake_arr = [-1, .7, 0, .3];
%     max_left_arr = [1.3, .5, .5, 0];
%     max_right_arr = [-1.5, .4, 0, .6];
%     
%     step = .0001;
%     max = max_accel_arr(1);
%     if(dir == -1)
%         step = -step;
%         max = max_brake_arr(1);
%     end
%     
%     if(~isrow(powered_wheels_arg))
%         powered_wheels_arg = powered_wheels_arg';
%     end
%     
%     if(isequal(powered_wheels_arg,[1, 1, 1]))
%         accel = max;
%         return;
%     end
%     
%     for i=0:step:max
%         [F, R, S] = load_transfer(0, i, max_accel_arr, max_brake_arr, max_left_arr, max_right_arr);
%         load_vec = [F, R, S];
%         load_vec = load_vec .* powered_wheels_arg;
%         if(dir == -1)
%             max_accel = load_vec .* neg_val(max_brake_arr(1));
%             total_accel = load_vec .* i;
%         else
%             max_accel = load_vec .* max_accel_arr(1);
%             total_accel = load_vec .* i;
%         end
%         if(abs(total_accel(1)) > abs(max_accel(1)) || abs(total_accel(2)) > abs(max_accel(2)) || abs(total_accel(3)) > abs(max_accel(3)))
%             accel = i-step;
%             return
%         end
%     end
end


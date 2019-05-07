function [total_time, total_phases, energy, lapajoules, cores, phases] = lap_sim(sector_list, gg, weight_trans)
    %lap_sim This is the actual laptime simulation code
    % This takes in a sector list array and a gg object, and returns
    % the total lap time, lap phases, energy used, lapajoule rating, and
    % the number of cores used.

    heating_value = gg{5};

    min_rad = Inf;
    for i=1:length(sector_list(:,1))
        if(abs(sector_list(i,1)) < abs(min_rad))
            min_rad = sector_list(i,1);
        end
    end
    slowest_index = find(sector_list(:,1)==min_rad);
    sectors_length = length(sector_list);
    max_corner_speeds = zeros(sectors_length, 1);
    entry_corner_speeds = zeros(sectors_length, 1);
    exit_corner_speeds = zeros(sectors_length, 1);
    epsilon = .0001;
    min_throttle = .01;
    phase_dist = 1;
    phases = cell(sectors_length, 1);
    second_try = 0;
    retries = 2;

    cores = 1;
    for i=1:length(sector_list)
        max_corner_speeds(i) = speed_radius(sector_list(i, 1), gg, []);
        phases{i} = zeros(floor(sector_list(i, 2)), 6);
    end

    for i=1:length(slowest_index)
        [prev, next] = ring_index(slowest_index(i), sectors_length);
        exit_corner_speeds(prev) = max_corner_speeds(slowest_index(i));
        entry_corner_speeds(slowest_index(i)) = max_corner_speeds(slowest_index(i));
        exit_corner_speeds(slowest_index(i)) = max_corner_speeds(slowest_index(i));
        entry_corner_speeds(next) = max_corner_speeds(slowest_index(i));

        phases{slowest_index(i)} = ones(floor(sector_list(slowest_index(i), 2)), 3) * max_corner_speeds(slowest_index(i));
        phases{slowest_index(i)} = [phases{slowest_index(i)}, zeros(floor(sector_list(slowest_index(i), 2)), 3)];
    end

    complete_corners = slowest_index;
    curr_corners = [];
    for i=1:length(complete_corners)
        [prev, next] = ring_index(complete_corners(i), sectors_length);
        selected_corners = [];
        if(~ismember(prev, complete_corners) && prev ~= next)
            selected_corners = [selected_corners; prev];
        end
        if(~ismember(next, complete_corners))
            selected_corners = [selected_corners; next];
        end
        curr_corners = [curr_corners; selected_corners];
    end

    while ~isempty(curr_corners)
        for i=1:length(curr_corners)
            curr_corner = curr_corners(i);
            curr_corner_rad = sector_list(curr_corner, 1);
            [prev, next] = ring_index(curr_corner, sectors_length);
            max_corner_speed = max_corner_speeds(curr_corner);
            max_exit_speed = max_corner_speed;
            max_entry_speed = max_corner_speed;
            entry_speed_set = 0;
            exit_speed_set = 0;

            if(entry_corner_speeds(curr_corner) > 0)
                max_entry_speed = entry_corner_speeds(curr_corner)-epsilon;
                phases{curr_corner}(1, 2) = entry_corner_speeds(curr_corner);
            end

            if(exit_corner_speeds(curr_corner) > 0)
                max_exit_speed = exit_corner_speeds(curr_corner)-epsilon;
                phases{curr_corner}(end, 3) = exit_corner_speeds(curr_corner);
            end
            
            if(phases{prev}(end,3) > 0)
                max_entry_speed = phases{prev}(end,3);
                entry_corner_speeds(curr_corner) = max_entry_speed;
            end

            if(phases{next}(1,2) > 0)
                max_exit_speed = phases{next}(1,2);
                exit_corner_speeds(curr_corner) = max_exit_speed;
            end

            if(max_corner_speeds(next) < max_exit_speed)
                max_exit_speed = max_corner_speeds(next);
            end
            if(max_corner_speeds(prev) < max_entry_speed)
                max_entry_speed = max_corner_speeds(prev);
            end
            
            if(max_exit_speed > entry_corner_speeds(next) && entry_corner_speeds(next) > 0)
                max_exit_speed = entry_corner_speeds(next);
            end
            if(exit_corner_speeds(curr_corner) > 0 && exit_corner_speeds(curr_corner) < max_exit_speed)
                max_exit_speed = exit_corner_speeds(curr_corner);
            end
            
            if(max_entry_speed > exit_corner_speeds(prev) && exit_corner_speeds(prev) > 0)
                max_entry_speed = exit_corner_speeds(prev);
            end
            if(entry_corner_speeds(curr_corner) > 0 && entry_corner_speeds(curr_corner) < max_exit_speed)
                max_entry_speed = entry_corner_speeds(curr_corner);
            end
            
            if(phases{curr_corner}(1, 2) > max_entry_speed || phases{curr_corner}(1, 2) == 0)
                phases{curr_corner}(1, 2) = max_entry_speed;
            end
            
            if(phases{curr_corner}(end, 3) > max_exit_speed || phases{curr_corner}(end, 3) == 0)
                phases{curr_corner}(end, 3) = max_exit_speed;
            end

            exit_phases = 0;
            max_phases_speed = max_corner_speed;
            if(phases{curr_corner}(end, 3) == 0 || phases{curr_corner}(end, 3) > max_exit_speed)
                phases{curr_corner}(end, 3) = max_exit_speed;
            end
            if(phases{curr_corner}(1, 2) == 0 || phases{curr_corner}(1, 2) > max_entry_speed)
                phases{curr_corner}(1, 2) = max_entry_speed;
            end

            if(max_exit_speed < max_corner_speed)
                exit_phases = 1;
                for z=length(phases{curr_corner}):-1:1
                    phase_exit_speed = phases{curr_corner}(z, 3);
                    [long, throttlebrake] = avail_accel(phase_exit_speed, sector_list(curr_corner, 1), gg, weight_trans);
                    brake_accel = long(2);
                    time = phase_time(brake_accel, phase_exit_speed, phase_dist);
                    phase_entry_speed = -brake_accel * time + phase_exit_speed;
                    if(max_corner_speed - phase_entry_speed < epsilon)
                        break
                    end
                    max_phases_speed = phase_entry_speed;
                    toofast = 0;
                    temp_accel = zeros(z, 6);
                    if(max_phases_speed > max_entry_speed && phases{curr_corner}(1, 2) > 0)
                       temp_accel(1, :) = phases{curr_corner}(1, :);
                        for x=1:z
                           phase_entry_speed = temp_accel(x, 2);
                           [long, throttlebrake] = avail_accel(phase_entry_speed, sector_list(curr_corner, 1), gg, weight_trans);
                           engine_accel = long(1);
                           time = phase_time(engine_accel, phase_entry_speed, phase_dist);
                           phase_exit_speed = engine_accel * time + phase_entry_speed;
                           if(max_corner_speed - phase_exit_speed < epsilon)
                               phase_exit_speed = max_corner_speed;
                           end
                           temp_accel(x, 3) = phase_exit_speed;
                           temp_accel(x+1, 2) = phase_exit_speed;
                        end
                       if(temp_accel(end, 3) < phases{curr_corner}(z, 3))
                           toofast = 1;
                       end
                    end
                    if(toofast == 1)
                        break
                    end
                    %[elec_accel, elec_consump] = elec_mot(long, gg, phase_entry_speed, time, -throttlebrake(2), weight_arr);
                    phases{curr_corner}(z, 2) = phase_entry_speed;
                    phases{curr_corner}(z, 4) = -throttlebrake(2);
                    phases{curr_corner}(z, 5) = 0;
                    phases{curr_corner}(z, 6) = 0;
                    if(z > 1)
                        phases{curr_corner}(z-1, 3) = phase_entry_speed;
                        phases{curr_corner}(z-1, 4) = -throttlebrake(2);
                        phases{curr_corner}(z-1, 5) = 0;
                        phases{curr_corner}(z-1, 6) = 0;
                    end
                    exit_phases = exit_phases + 1;
                end
            end
            for z=1:(length(phases{curr_corner})-exit_phases)
                phase_entry_speed = phases{curr_corner}(z, 2);
                [long, throttlebrake] = avail_accel(phase_entry_speed, sector_list(curr_corner, 1), gg, weight_trans);
                engine_accel = long(1);
                time = phase_time(engine_accel, phase_entry_speed, phase_dist);
                phase_exit_speed = engine_accel * time + phase_entry_speed;
                if(max_phases_speed - phase_exit_speed < epsilon)
                    phase_exit_speed = max_phases_speed;
                end
                phases{curr_corner}(z, 3) = phase_exit_speed;
                if(throttlebrake(1) > min_throttle)
                    phases{curr_corner}(z, 4) = throttlebrake(1);
                    phases{curr_corner}(z, 5) = consump(gg, phase_entry_speed, time, throttlebrake(1));
                    phases{curr_corner}(z, 6) = 0;
                else
                    phases{curr_corner}(z, 4) = 0;
                    phases{curr_corner}(z, 5) = 0;
                    phases{curr_corner}(z, 6) = 0;
                end
                if(z < length(phases{curr_corner}))
                    phases{curr_corner}(z+1, 2) = phase_exit_speed;
                    if(throttlebrake(1) > min_throttle)
                        phases{curr_corner}(z+1, 4) = throttlebrake(1);
                        phases{curr_corner}(z+1, 5) = consump(gg, phase_entry_speed, time, throttlebrake(1));
                        phases{curr_corner}(z+1, 6) = 0;
                    else
                        phases{curr_corner}(z+1, 4) = 0;
                        phases{curr_corner}(z+1, 5) = 0;
                        phases{curr_corner}(z+1, 6) = 0;
                    end
                end
            end
            
            if(phases{curr_corner}(end, 4) > 0)
                phase_entry_speed = phases{curr_corner}(end, 2);
                [long, throttlebrake] = avail_accel(phase_entry_speed, sector_list(curr_corner, 1), gg, weight_trans);
                engine_accel = long(1);
                time = phase_time(engine_accel, phase_entry_speed, phase_dist);
                phase_exit_speed = engine_accel * time + phase_entry_speed;
                if(phase_exit_speed < phases{curr_corner}(end, 3))
                    phases{curr_corner}(end, 3) = phase_exit_speed;
                    exit_corner_speeds(curr_corner) = phases{i}(end, 3);
                    entry_corner_speeds(next) = exit_corner_speeds(i);
                end
            end
            
            entry_corner_speeds(curr_corner) = phases{curr_corner}(1, 2);
            exit_corner_speeds(prev) = entry_corner_speeds(curr_corner);
            exit_corner_speeds(curr_corner) = phases{curr_corner}(end, 3);
            entry_corner_speeds(next) = exit_corner_speeds(curr_corner);

            for z=1:length(phases{curr_corner})
                phases{curr_corner}(z,1) = (phases{curr_corner}(z, 2) + phases{curr_corner}(z, 3)) / 2;
            end
        end

        for i=1:length(curr_corners)
            if(~ismember(curr_corners(i), complete_corners))
                complete_corners = [complete_corners; curr_corners(i)];
            end
        end
        complete_corners = [complete_corners; curr_corners];
        curr_corners = [];
        for i=1:length(complete_corners)
            [prev, next] = ring_index(complete_corners(i), sectors_length);
            if(~ismember(prev, complete_corners) && ~ismember(prev, curr_corners))
                curr_corners = [curr_corners; prev];
            end
            if(~ismember(next, complete_corners) && ~ismember(next, curr_corners))
                curr_corners = [curr_corners; next];
            end
        end
        if(isempty(curr_corners) && second_try < retries)
            for i=1:sectors_length
                [prev, next] = ring_index(i, sectors_length);
                curr_corners = [curr_corners; i];
                if(phases{i}(end, 4) > 0)
                    phase_entry_speed = phases{i}(end, 2);
                    [long, throttlebrake] = avail_accel(phase_entry_speed, sector_list(i, 1), gg, weight_trans);
                    engine_accel = long(1);
                    time = phase_time(engine_accel, phase_entry_speed, phase_dist);
                    phase_exit_speed = engine_accel * time + phase_entry_speed;
                    if(phase_exit_speed < phases{i}(end, 3))
                        phases{i}(end, 3) = phase_exit_speed;
                        exit_corner_speeds(i) = phases{i}(end, 3);
                        entry_corner_speeds(next) = exit_corner_speeds(i);
                    end
                end
                if(exit_corner_speeds(i) > phases{i}(end, 3))
                    exit_corner_speeds(i) = phases{i}(end, 3);                    
                    entry_corner_speeds(next) = exit_corner_speeds(i);
                end
                if(entry_corner_speeds(i) > phases{i}(1, 2))
                    entry_corner_speeds(i) = phases{i}(1, 2);
                    exit_corner_speeds(prev) = entry_corner_speeds(i);
                end
                if(phases{i}(end, 3) < exit_corner_speeds(i))
                    phases{i}(end, 3) = exit_corner_speeds(i);
                    entry_corner_speeds(next) = exit_corner_speeds(i);
                end
                if(phases{i}(1, 2) < entry_corner_speeds(i))
                    phases{i}(1, 2) = entry_corner_speeds(i);
                    exit_corner_speeds(prev) = entry_corner_speeds(i);
                end
            end
            second_try = second_try + 1;
        end
    end

    times = zeros(length(phases), 1);

    for i=1:length(times)
        extra_length = sector_list(i, 2) - size(phases{i},1);
        times(i) = extra_length/(2*entry_corner_speeds(i)) + extra_length/(2*exit_corner_speeds(i));
        for j=1:size(phases{i}, 1)
            times(i) = times(i) + 1/phases{i}(j, 1);
        end
    end

    
    total_phases = phases{1};
    for i=2:length(phases)
        total_phases = [total_phases; phases{i}];
    end

    total_time = sum(times);
    energy = sum(total_phases(:,5))*heating_value;
    lapajoule_energy = energy / 5200000;
    lapajoule_lap = total_time / 95;
    lapajoules = ((1/lapajoule_lap)/lapajoule_energy);
end


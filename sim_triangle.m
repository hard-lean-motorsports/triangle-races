%% Main program. Run this.

clear variables
sector_list = track_gen();
[gg, max_speed, min_speed] = gg_gen();
for i=1:length(gg)
    if(~isempty(gg{i}))
        min_speed = i;
        break
    end
end

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
eplison = .0001;
phase_dist = 1;
phases = cell(sectors_length, 1);

for i=1:length(sector_list)
    max_corner_speeds(i) = speed_radius(sector_list(i, 1), gg, max_speed, min_speed);
    phases{i} = zeros(floor(sector_list(i, 2)), 3);
end

for i=1:length(slowest_index)
    [prev, next] = ring_index(slowest_index(i), sectors_length);
    exit_corner_speeds(prev) = max_corner_speeds(slowest_index(i));
    entry_corner_speeds(slowest_index(i)) = max_corner_speeds(slowest_index(i));
    exit_corner_speeds(slowest_index(i)) = max_corner_speeds(slowest_index(i));
    entry_corner_speeds(next) = max_corner_speeds(slowest_index(i));
    
    phases{slowest_index(i)} = ones(floor(sector_list(slowest_index(i), 2)), 3) * max_corner_speeds(slowest_index(i));
    
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
            max_entry_speed = entry_corner_speeds(curr_corner);
            phases{curr_corner}(1, 2) = entry_corner_speeds(curr_corner);
            entry_speed_set = 1;
        end
        
        if(exit_corner_speeds(curr_corner) > 0)
            max_exit_speed = exit_corner_speeds(curr_corner);
            phases{curr_corner}(end, 3) = exit_corner_speeds(curr_corner);
            exit_speed_set = 1;
        end
        
        if(max_corner_speeds(next) < max_exit_speed)
            max_exit_speed = max_corner_speeds(next);
        end
        if(max_corner_speeds(prev) < max_entry_speed)
            max_entry_speed = max_corner_speeds(prev);
        end
       
        exit_phases = 0;
        max_phases_speed = max_corner_speed;
        if(phases{curr_corner}(end, 3) == 0)
            phases{curr_corner}(end, 3) = max_exit_speed;
        end
        if(phases{curr_corner}(1, 2) == 0)
            phases{curr_corner}(1, 2) = max_entry_speed;
        end
        
        if(max_exit_speed < max_corner_speed)
            for z=length(phases{curr_corner}):-1:1
               phase_exit_speed = phases{curr_corner}(z, 3);
               long = avail_accel(phase_exit_speed, sector_list(curr_corner, 1), gg, max_speed);
               brake_accel = long(2);
               time = phase_time(brake_accel, phase_exit_speed, phase_dist);
               phase_entry_speed = -brake_accel * time + phase_exit_speed;
               if(max_corner_speed - phase_entry_speed < eplison)
                   break
               end
               max_phases_speed = phase_entry_speed;
               phases{curr_corner}(z, 2) = phase_entry_speed;
               if(z > 1)
                   phases{curr_corner}(z-1, 3) = phase_entry_speed;
               end
               exit_phases = exit_phases + 1;
            end
        end
        for z=1:(length(phases{curr_corner})-exit_phases)
            phase_entry_speed = phases{curr_corner}(z, 2);
            long = avail_accel(phase_entry_speed, sector_list(curr_corner, 1), gg, max_speed);
            engine_accel = long(1);
            time = phase_time(engine_accel, phase_entry_speed, phase_dist);
            phase_exit_speed = engine_accel * time + phase_entry_speed;
            if(max_phases_speed - phase_exit_speed < eplison)
                phase_exit_speed = max_phases_speed;
            end
            phases{curr_corner}(z, 3) = phase_exit_speed;
            if(z < length(phases{curr_corner}))
                phases{curr_corner}(z+1, 2) = phase_exit_speed;
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
end

times = zeros(length(phases), 1);

for i=1:length(times)
    extra_length = sector_list(i, 2) - size(phases{i},1);
    times(i) = extra_length/(2*entry_corner_speeds(i)) + extra_length/(2*exit_corner_speeds(i));
    for j=1:size(phases{i}, 1)
        times(i) = times(i) + 1/phases{i}(j, 1);
    end
end

total_time = sum(times);
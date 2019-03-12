clear
sector_list = track_gen();
max_corner_speeds = [];
corner_speeds = zeros(length(sector_list), 1);
[gg, max_speed, min_speed] = gg_gen();
times = [];
for i=1:length(sector_list)
    max_corner_speeds = [max_corner_speeds; speed_radius(sector_list(i, 1), gg, max_speed, min_speed)];
end

slowest_corners = [];
slowest_speed = min(max_corner_speeds);
entry_speeds = zeros(length(sector_list), 1);
exit_speeds = zeros(length(sector_list), 1);
for i=1:length(max_corner_speeds)
    [prev, next] = ring_index(i, length(max_corner_speeds));
    if(abs(max_corner_speeds(i)) == abs(slowest_speed))
        slowest_corners = [slowest_corners; i];
        corner_speeds(i) = max_corner_speeds(i);
        entry_speeds(next) = max_corner_speeds(i);
        entry_speeds(i) = max_corner_speeds(i);
        exit_speeds(prev) = max_corner_speeds(i);
        exit_speeds(i) = max_corner_speeds(i);
    end
end

complete_corners = slowest_corners;

while length(complete_corners) < length(max_corner_speeds)
    current_corners = [];
    for i=1:length(complete_corners)
        [prev, next] = ring_index(complete_corners(i), length(max_corner_speeds));
        if(isempty(find(complete_corners == prev)) && isempty(find(current_corners == prev)))
            current_corners = [current_corners; prev];
        end
        if(isempty(find(complete_corners == next)) && isempty(find(current_corners == next)))
            current_corners = [current_corners; next];
        end
    end
    for i=1:length(current_corners)
        [prev, next] = ring_index(current_corners(i), length(max_corner_speeds));
        if(exit_speeds(current_corners(i)) > 0)
            exit_speed = exit_speeds(current_corners(i));
            corner_speeds(current_corners(i)) = exit_speed;
            max_speed = max_corner_speeds(current_corners(i));
            max_entry_speed = max_corner_speeds(prev);
            radius = sector_list(current_corners(i), 1);
            [~, max_long] = gg_accel(exit_speeds(current_corners(i)), (exit_speed^2)/radius, [], gg, max_speed);
            end_accel = 0;
            if(exit_speed > max_entry_speed)
                end_accel = max(max_long);
            elseif(exit_speed < max_entry_speed)
                end_accel = min(max_long);
            end
            entry_speeds(current_corners(i)) = exit_speed;
        elseif(entry_speeds(current_corners(i)) > 0)
            entry_speed = entry_speeds(current_corners(i));
            corner_speeds(current_corners(i)) = entry_speed;
            exit_speeds(current_corners(i)) = entry_speed;
        else
            corner_speeds(current_corners(i)) = max_corner_speeds(current_corners(i));
        end
    end
    complete_corners = [complete_corners; current_corners];
end

times = sector_list(:,2) ./ corner_speeds;
total_time = sum(times);
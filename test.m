clear
load testsectors
load testgg

max_speed = length(gg);
for i=1:length(gg)
    if(~isempty(gg{i}))
        min_speed = i;
        break
    end
end

min_rad = min(sector_list(:,1));
slowest_index = find(sector_list(:,1)==min_rad);
sectors_length = length(sector_list);
max_corner_speeds = zeros(sectors_length, 1);
entry_corner_speeds = zeros(sectors_length, 1);
exit_corner_speeds = zeros(sectors_length, 1);
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
        
        
        if(entry_speed_set)
            for z=1:length(phases{curr_corner})
                phase_entry_speed = phases{curr_corner}(z, 2);
                cir_accel = (phase_entry_speed^2) / curr_corner_rad;
                [lat, long] = gg_accel(phase_entry_speed, cir_accel, [], gg, max_speed);
                phase_exit_speed = sqrt(2*long(1) + phase_entry_speed^2) + phase_entry_speed;
                if(phase_exit_speed > min(max_corner_speed, max_exit_speed))
                    phase_exit_speed = min(max_corner_speed, max_exit_speed);
                end
                phases{curr_corner}(z, 3) = phase_exit_speed;
                if(z < length(phases{curr_corner}))
                    phases{curr_corner}(z+1, 2) = phase_exit_speed;
                end
            end
        elseif(exit_speed_set)
           for z=length(phases{curr_corner}):-1:1
                phase_exit_speed = phases{curr_corner}(z, 3);
                cir_accel = (phase_exit_speed^2) / curr_corner_rad;
                [lat, long] = gg_accel(phase_exit_speed, cir_accel, [], gg, max_speed);
                phase_entry_speed = phase_exit_speed + sqrt(2*long(2) + phase_exit_speed^2);
                if(phase_entry_speed > min(max_corner_speed, max_entry_speed))
                    phase_entry_speed = min(max_corner_speed, max_entry_speed);
                end
                phases{curr_corner}(z, 2) = phase_entry_speed;
                if(z > 1)
                    phases{curr_corner}(z-1, 3) = phase_entry_speed;
                end
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
    

%         j = 1;
%         k = length(phases{curr_corner});
%         
%         entry_array = phases{curr_corner}(j, :);
%         exit_array = phases{curr_corner}(k, :);
%         
%         while 1
%             if(entry_speed_set == 1 && exit_speed_set == 0)
%                new_entry_array = zeros(j,2);
%                new_exit_array = zeros(k-1,2);
%                
%                for z=1:j
%                    new_entry_array(z, 1) = entry_array(z, 1);
%                    new_entry_array(z, 2) = entry_array(z, 2);
%                end
%                
%                cir_accel = new_entry_array(j, 1)^2 / curr_corner_rad;
%                [~, long] = gg_accel(new_entry_array(j, 1), cir_accel, [], gg, max_speed);
%                accel = 0;
%                if(new_entry_array(j, 1) < max_corner_speed)
%                    accel = long(1);
%                else
%                    accel = 0;
%                end
%                new_entry_array(j, 2) = (sqrt(2*accel+new_entry_array(j, 1)^2) - new_entry_array(j, 1)) + new_entry_array(j, 1);
%                new_exit_array(1, 1) = new_entry_array(j, 2);
%                
%                for z=1:size(new_exit_array,1)
%                    cir_accel = new_entry_array(z, 1)^2 / curr_corner_rad;
%                    [~, long] = gg_accel(new_entry_array(z, 1), cir_accel, [], gg, max_speed);
%                    if(new_exit_array(z, 1) < max_exit_speed && new_exit_array(z, 1) < max_corner_speed)
%                         accel = long(1);
%                    elseif(new_exit_array(z, 1) > max_exit_speed)
%                         accel = long(2);
%                    else
%                        accel = 0;
%                    end
%                    new_exit_array(z, 2) = (sqrt(2*accel+new_exit_array(z, 1)^2) - new_exit_array(z, 1)) + new_exit_array(z, 1);
%                end
%                
%                if(new_exit_array(end, 2) > max_exit_speed)
%                    break
%                else
%                    entry_array = zeros(size(new_entry_array,1),2);
%                    for z=1:size(new_entry_array,1)
%                        entry_array(z, 1) = new_entry_array(z, 1);
%                        entry_array(z, 2) = new_entry_array(z, 2);
%                    end  
%                    exit_array = zeros(size(new_exit_array,1),2);
%                    for z=1:size(new_exit_array,1)
%                        exit_array(z, 1) = new_exit_array(z, 1);
%                        exit_array(z, 2) = new_exit_array(z, 2);
%                    end
%                end
%             elseif(entry_speed_set == 0 && exit_speed_set == 1)
%                new_entry_array = zeros(k-1,2);
%                new_exit_array = zeros(j,2);
%                
%                for z=1:j
%                    new_exit_array(z, 1) = exit_array(z, 1);
%                    new_exit_array(z, 2) = exit_array(z, 2);
%                end
%                
%                cir_accel = new_exit_array(1, 2)^2 / curr_corner_rad;
%                [~, long] = gg_accel(new_exit_array(1, 2), cir_accel, [], gg, max_speed);
%                accel = 0;
%                if(new_exit_array(j, 2) < max_corner_speed)
%                    accel = long(2);
%                else
%                    accel = 0;
%                end
%                new_exit_array(j, 1) = new_entry_array(j, 2) - (sqrt(2*accel+new_exit_array(j, 2)^2) - new_exit_array(j, 2));
%                new_entry_array(end, 2) = new_exit_array(j, 1);
%                
%                for z=size(new_entry_array,1):1
%                    cir_accel = new_entry_array(j, 2)^2 / curr_corner_rad;
%                    [~, long] = gg_accel(new_entry_array(z, 1), cir_accel, [], gg, max_speed);
%                    if(new_entry_array(z, 1) < max_exit_speed && new_entry_array(z, 1) < max_corner_speed)
%                         accel = long(2);
%                    elseif(new_entry_array(z, 2) > max_exit_speed)
%                         accel = long(1);
%                    else
%                        accel = 0;
%                    end
%                    new_entry_array(z, 1) = new_entry_array(z, 2) - (sqrt(2*accel+new_entry_array(z, 2)^2) - new_entry_array(z, 2));
%                end
%                
%                if(new_entry_array(1, 1) > max_entry_speed)
%                    break
%                else
%                    entry_array = zeros(size(new_entry_array,1),2);
%                    for z=1:size(new_entry_array,1)
%                        entry_array(z, 1) = new_entry_array(z, 1);
%                        entry_array(z, 2) = new_entry_array(z, 2);
%                    end  
%                    exit_array = zeros(size(new_exit_array,1),2);
%                    for z=1:size(new_exit_array,1)
%                        exit_array(z, 1) = new_exit_array(z, 1);
%                        exit_array(z, 2) = new_exit_array(z, 2);
%                    end
%                end
%                
%             elseif(entry_speed_set == 1 && exit_speed_set == 1)
%                new_entry_array = zeros(j,2);
%                new_exit_array = zeros(j,2);
%                
%                for z=1:j
%                    new_entry_array(z, 1) = entry_array(z, 1);
%                    new_entry_array(z, 2) = entry_array(z, 2);
%                end
%                
%                for z=1:j
%                    new_exit_array(z, 1) = exit_array(z, 1);
%                    new_exit_array(z, 2) = exit_array(z, 2);
%                end
%                
%                cir_accel_entry = new_entry_array(j, 1)^2 / curr_corner_rad;
%                cir_accel_exit = new_entry_array(1, 2)^2 / curr_corner_rad;
%                [~, long_entry] = gg_accel(new_entry_array(j, 1), cir_accel_entry, [], gg, max_speed);
%                [~, long_exit] = gg_accel(new_exit_array(1, 2), cir_accel_entry, [], gg, max_speed);
%                
%                if(new_entry_array(j, 1) < max_corner_speed)
%                    accel = long(1);
%                else
%                    accel = 0;
%                end
%                new_entry_array(j, 2) = (sqrt(2*accel_entry+new_entry_array(j, 1)^2) - new_entry_array(j, 1)) + new_entry_array(j, 1);
%                new_exit_array(1, 1) = new_entry_array(j, 2);
%                 
%                if(new_exit_array(j, 2) < max_corner_speed)
%                    accel = long(2);
%                else
%                    accel = 0;
%                end
%                new_exit_array(j, 1) = new_entry_array(j, 2) - (sqrt(2*accel_exit+new_exit_array(j, 2)^2) - new_exit_array(j, 2));
%                new_entry_array(end, 2) = new_exit_array(j, 1);
%                
%                entry_array = zeros(size(new_entry_array,1),2);
%                for z=1:size(new_entry_array,1)
%                    entry_array(z, 1) = new_entry_array(z, 1);
%                    entry_array(z, 2) = new_entry_array(z, 2);
%                end  
%                exit_array = zeros(size(new_exit_array,1),2);
%                for z=1:size(new_exit_array,1)
%                    exit_array(z, 1) = new_exit_array(z, 1);
%                    exit_array(z, 2) = new_exit_array(z, 2);
%                end
%                
%             else
%                 break
%             end
%             
%             j = j + 1;
%             k = k - 1;
%             if(j > k)
%                 break
%             end
%         end
%         
%         for j=1:size(entry_array,1)
%            phases{curr_corner}(j, 2) = entry_array(j, 1);
%            phases{curr_corner}(j, 3) = entry_array(j, 3);
%         end
%         
%         entry_corner_speeds =  phases{curr_corner}(1, 2);
%         
%         for k=1:size(exit_array,1)
%            phases{curr_corner}(j+k, 2) = exit_array(k, 1);
%            phases{curr_corner}(j+k, 3) = exit_array(k, 3);
%         end
%         
%         exit_corner_speeds =  phases{curr_corner}(end, 3);
    
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
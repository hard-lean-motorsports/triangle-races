%% Main program. Run this.

clear variables
clc
h = msgbox("Choose a track coordinant csv file");
uiwait(h);
track_file = uigetfile({'*.csv', "Track Description .csv file"});
if(track_file == 0)
    return
end
h = msgbox("Choose a bike description file(s)");
uiwait(h);
bike_file = uigetfile({'*.xlsx', "Bike Description .xlsx files"} ,'MultiSelect','on');
if(~iscell(bike_file))
    if(bike_file == 0)
        return
    end
end
sector_list = track_gen(track_file);

bikes_array = {};
if(ischar(bike_file))
    bikes_array{1} = bike_file;
else
    bikes_array = bike_file;
end

results = cell(length(bikes_array), 7);

for i=1:length(bikes_array)
    tic;
    gg = gg_gen(bikes_array{i});
    try
        [total_time, total_phases, energy, lapajoules, cores, phases] = lap_sim(sector_list, gg);
        elapsed = toc;
        results(i,:) = {strcat(bikes_array{i}), total_time, total_phases, energy, lapajoules, cores, elapsed};
    catch ME
        disp("Error with " + bikes_array{i});
        disp(getReport(ME,'extended','hyperlinks','on'));
        elapsed = toc;
        results(i,:) = {strcat(bikes_array{i}), 0, {}, 0, 0, 0, elapsed};
    end
    
end


if(length(bikes_array) > 1)
    sorted_results = cell(length(bikes_array), 7);
    lapajoule_listing = sort(cell2mat(results(:, 5)), 'descend');
    for i=1:length(lapajoule_listing)
        I = find(cell2mat(results(:, 5))==lapajoule_listing(i));
        sorted_results(i, :) = results(I, :);
    end
    results = sorted_results;
end
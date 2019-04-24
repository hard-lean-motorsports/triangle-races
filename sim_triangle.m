%% Main program. Run this.

clear variables
clc
disp("Waiting for user track selection");
h = msgbox("Choose a track coordinant csv file");
uiwait(h);
track_file = uigetfile({'*.csv', "Track Description .csv file"});
if(track_file == 0)
    return
end
disp("Waiting for user bike selection");
h = msgbox("Choose a bike description file(s)");
uiwait(h);
bike_file = uigetfile({'*.xlsx', "Bike Description .xlsx files"} ,'MultiSelect','on');
tic;
async_ids = [];
if(~iscell(bike_file))
    if(bike_file == 0)
        return
    end
end
disp("User selection complete");
disp(newline);
disp("Generating track information");
sector_list = track_gen(track_file);
disp("Track generation complete");
bikes_array = {};
if(ischar(bike_file))
    bikes_array{1} = bike_file;
else
    bikes_array = bike_file;
end
disp("Generating bike gg-graphs");
p = gcp();
total_cores = p.NumWorkers;
if(length(bikes_array) < total_cores)
    total_cores = length(bikes_array);
end
results = cell(length(bikes_array), 7);
for i=1:length(bikes_array)
    async_result(i) = parfeval(p, @gg_gen, 1, bikes_array{i});
end

for i=1:length(bikes_array)
    [id, gg] = fetchNext(async_result);
    async_ids(id) = i;
    gg_list{id} = gg;
end
for i=1:length(bikes_array)
    id = async_ids(i);
    finished_time{i} = datevec(async_result(id).FinishDateTime);
    start_time{i} = datevec(async_result(id).StartDateTime);
    elapsed{i} = etime(finished_time{i},start_time{i});
    results{i,7} = elapsed{i};
end
disp("gg-graph generation complete");
disp(newline);
disp("Generating laptimes");
for i=1:length(bikes_array)
    async_result(i) = parfeval(p, @lap_sim, 6, sector_list, gg_list{i});
end

for i=1:length(bikes_array)
    [id, total_time, total_phases, energy, lapajoules, cores, phases] = fetchNext(async_result);
    async_ids(id) = i;
    results(id,:) = {strcat(bikes_array{i}), total_time, total_phases, energy, lapajoules, cores, -1};
end
disp("Laptime generation complete");
disp(newline);
disp("Sorting results and timing");
for i=1:length(bikes_array)
    id = async_ids(i);
    finished_time{i} = datevec(async_result(id).FinishDateTime);
    start_time{i} = datevec(async_result(id).StartDateTime);
    elapsed{i} = etime(finished_time{i},start_time{i});
    results{i,7} = elapsed{i} + results{i,7};
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

total_elapsed = toc;
total_threads_elapsed = 0;
for i=1:length(bikes_array)
    total_threads_elapsed = total_threads_elapsed + results{i,7};
end
threading_eff = (total_threads_elapsed)/(total_elapsed*total_cores);
disp("Sorting and timing complete")
disp("All computation complete, results to follow");
disp(newline);
disp("Results for track " + track_file);
disp(length(bikes_array) + " bikes on " + total_cores + " core(s) took " + total_elapsed + "s");
disp("Total threading efficiency is: " + threading_eff * 100 + "%");
for i=1:length(bikes_array)
   disp("File " + results{i,1} + " laptime: " + results{i,2} + " energy used: " + results{i,4} + "j lapajoule rating: " + results{i,5})
   disp("File " + results{i,1} + " took " + results{i,7} + "s on " + results{i,6} + " core(s)");
end
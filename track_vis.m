function [] = track_vis()
    clf
    [sector_list, xy_list] = track_gen();
    plot([xy_list(:,1); xy_list(1,1)], [xy_list(:,2); xy_list(1,2)], "x-");
    axis equal
    hold on
    for i=1:length(sector_list)
        if(sector_list(i, 1) == Inf)
            continue
        end
        rectangle('Position',[xy_list(i,1) - sector_list(i,1), xy_list(i,2) - sector_list(i,1), sector_list(i,1)*2, sector_list(i,1)*2],'Curvature',[1 1])
    end
end


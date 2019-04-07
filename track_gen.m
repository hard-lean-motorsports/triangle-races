function [sector_list, xy_list] = track_gen()
    % track_gen Generates list of sectors in the form [radius, arc_length]
    % No arguments are yet needed, select the CSV when prompted.
    % No width yet.
    h = msgbox("Choose a track coordinant csv file");
    uiwait(h);
    track_file = uigetfile('*.csv');
    xy_list = csvread(track_file);
    list_length = size(xy_list);
    list_length = list_length(1);
    sector_list = [];
    if(xy_list(1,3) == 2)
        for i=2:list_length
            sector_list = [sector_list; [xy_list(i,1), xy_list(i,2)]];
        end
    else
        start = 1;
        if(xy_list(1,3) == 1)
            start = 2;
        end
        for i=start:list_length
            s0 = i - 1;
            if(s0 < 1)
                s0 = list_length - (i - 1);
            end
            s1 = i;
            s2 = i + 1;
            if(s2 > list_length)
                s2 = s2 - list_length;
            end

            x0 = xy_list(s0, 1);
            y0 = xy_list(s0, 2);
            x1 = xy_list(s1, 1);
            y1 = xy_list(s1, 2);
            x2 = xy_list(s2, 1);
            y2 = xy_list(s2, 2);

            v1 = [y1 - y0; x1 - x0; 0];
            v2 = [y2 - y1; x2 - x1; 0];

            rot = cross(v1, v2);
            rot = -sign(rot(3));

            s0_s1 = sqrt((x1-x0)^2 + (y1-y0)^2);
            s0_s2 = sqrt((x2-x0)^2 + (y2-y0)^2);
            s1_s2 = sqrt((x2-x1)^2 + (y2-y1)^2);

            min_s = min([s0_s1, s0_s2, s1_s2]);
            max_s = max([s0_s1, s0_s2, s1_s2]);
            if(2*min_s == max_s)
                sector_list = [sector_list; [Inf, s0_s1 + s0_s1 + s1_s2]];
                continue
            end

            rad = (s0_s1*s0_s2*s1_s2) / sqrt((s0_s1+s0_s2+s1_s2)*(-s0_s1+s0_s2+s1_s2)*(s0_s1-s0_s2+s1_s2)*(s0_s1+s0_s2-s1_s2)); % Heron's formula
            beta = asin(s0_s2 / (2 * rad));
            sector_len = 2 * beta * rad;
            rad = rot * rad;
            sector_list = [sector_list; [rad, sector_len]];
        end
    end
end

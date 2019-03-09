function [lat_g, long_g, hybrid_p] = gg_force(lat, long, vel)
    % gg_force Returns speed dependant GG-diagram
    % USAGE: [lat_g, long_g, hybrid_p] = gg_force(lat_g, long_g, speed)
    % Any argument may be "max" and a maximum of that argument is returned
    % A vector may be returned in the other values if multiple solutions
    % exist

    if(~exist(gg))
        gg = gg_gen()
    end
end


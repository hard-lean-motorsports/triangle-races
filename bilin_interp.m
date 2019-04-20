function out = bilin_interp(x_arr, y_arr, x, y, bilin_matrix)
    % bilin_interp Homespun bilinear interpolation

    lower_i = 0;
    higher_i = 0;
    lower_mult = .5;
    higher_mult = .5;
    for i=1:length(y_arr)
        if(y_arr(i) == y)
            lower = y;
            lower_i = i;
            higher = y;
            higher_i = i;
            break
        elseif((y_arr(i)-y)*(y_arr(i+1)-y) < 0)
            lower = y_arr(i);
            lower_i = i;
            higher = y_arr(i+1);
            higher_i = i+1;
            higher_mult = (y - lower) / (higher - lower);
            lower_mult = 1 - higher_mult;
            break
        end
    end

    higher_arr = bilin_matrix(:,higher_i);
    lower_arr = bilin_matrix(:,lower_i);
    higher_out = lin_interp(x_arr, higher_arr, x);
    lower_out = lin_interp(x_arr, lower_arr, x);
    out = higher_out * higher_mult + lower_out * lower_mult;
end
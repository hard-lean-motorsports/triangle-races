function y = lin_interp(x_arr, y_arr, x, extrap)
% lin_interp Linearly interpolates array at x. 
% Used as MATLAB functions can be too general and complex.
% By default, will extrapolate. If this is unwanted, set extrap to 0.
% USAGE: y = lin_interp(x_vector, y_vector, x)
% USAGE: y = lin_interp(x_vector, y_vector, x, extrap)
% The x_vector should be monotonically increasing or decreasing.

    if(~isequal(size(x_arr),size(y_arr)))
        error("lin_interp: Error: Vectors must be equal in size.");
    end

    extrap_set = 1;
    direction = 0; % Increasing
    if(nargin >= 4)
        extrap_set = extrap;
    end
    
    low = min(x_arr);
    high = max(x_arr);
    if(low == x_arr(end))
        direction = 1; % Decreasing
    end
    
    x1 = 0;
    x2 = 0;
    y1 = 0;
    y2 = 0;
    
    if(x < low)
        if(extrap_set == 0)
            y = NaN;
            return
        else
            x1 = low;
            if(direction == 0)
                y1 = y_arr(1);
                x2 = x_arr(2);
                y2 = y_arr(2);
            else
                y1 = y_arr(end);
                x2 = x_arr(end-1);
                y2 = y_arr(end-1);
            end
        end
    elseif(x > high)
        if(extrap_set == 0)
            y = NaN;
            return
        else
            x1 = high;
            if(direction == 0)
                y1 = y_arr(end);
                x2 = x_arr(end-1);
                y2 = y_arr(end-1);
            else
                y1 = y_arr(1);
                x2 = x_arr(2);
                y2 = y_arr(2);
            end
        end
    else
        if(direction == 0)
            for i=1:length(y_arr)
                if(x_arr(i) > x)
                    x1 = x_arr(i-1);
                    y1 = y_arr(i-1);
                    x2 = x_arr(i);
                    y2 = y_arr(i);
                elseif(x_arr(i) == x)
                    y = y_arr(i);
                    return
                end
            end
        else
            for i=length(y_arr):1
                if(x_arr(i) > x)
                    x1 = x_arr(i+1);
                    y1 = y_arr(i+1);
                    x2 = x_arr(i);
                    y2 = y_arr(i);
                elseif(x_arr(i) == x)
                    y = y_arr(i);
                    return
                end
            end
        end
    end
    
    y = y1 + (x - x1) * ((y2 - y1)/(x2 - x1));
end


%length:section length
%radius:0:straight;positive:right turn;negative:left turn
%grip:grip factor,usually is 1
function [length,radius,grip]=testcircuit(section)
if section==1
    length=100;
    radius=0;
    grip=1;
else
    if section==2
        length=78.54;
        radius=25;
        grip=1;
    else
        if section==3
            length=100;
            radius=0;
            grip=1;
        else
            if section==4
                length=78.54;
                radius=25;
                grip=1;
            else
                disp("end")
                length=-1;
            end
        end
    end
end

end
%velocity [m/s]
%direction  positive:right turn negative:left turn
%x y [m/s^2]
%g 9.8m/s^2
%the acc show here is the max acc can achieve
function [pos_ax,neg_ax,ay]=GG(velocity,radius)
g=9.8;
pos_ax=(1.1-0.02*velocity)*g;
neg_ax=-1.5*g;
if radius>0
    ay=1.8*g;
else
    if radius<0
        ay=1.5*g;
    else
        if radius==0
            ay=1.5*g;
        end
    end
end
end
        
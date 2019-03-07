%section is used for circute
section=1;         %initialize section
step=0.1;          %initialize time step [s]
dist=0;            %initialize distance  [m]
vx=0;              %initialize velocity  [m/s]
pos_ax=0;          %initialize pos_ax    [m/s^2]
neg_ax=0;          %initialize neg_ay    [m/s^2]
ay=0;              %initialize ay        [m/s^2]
t=0;               %initialize lap time  [s]
weight=280;         %initialize weight    [kg]
[length,radius,grip]=testcircuit(section);
while section<5
        if radius==0
        [pos_ax,neg_ax,ay]=GG(vx,radius);
        if (section+1)<4
        [length,radius2,grip]=testcircuit(section+1);
        else
        [length,radius2,grip]=testcircuit(1);
        end
            if radius2~=0
            [pos_ax,neg_ax,ay]=GG(vx,radius2);
            vx_max=sqrt(ay*abs(radius2));
            else
            vx_max=100;
            end
            distacc=0;
            i=0;
            while dist<length
                [pos_ax,neg_ax,ay]=GG(vx,radius);
                vx=pos_ax*step;
                distacc=distacc+vx*step;
                if vx>vx_max
                distdacc=(vx^2-vx_max^2)/(2*neg_ax);
                else
                    distdacc=0;
                end
                dist=distacc+distdacc;
                i=i+1;
                tdacc=(vx_max-vx)/neg_ax;
            end
            t=t+i*step+tdacc;
        else 
                [pos_ax,neg_ax,ay]=GG(vx,radius);
                vx_max=sqrt(ay*abs(radius));
                t=t+length/vx_max;
        end   
    section=section+1 ;
end
disp(t);

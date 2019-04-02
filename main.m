%This is the main file
%Please inintialize/check the parameters before running simulation
%sidecar is on the right side of motorcycle
%Rigth turn--> ACC positive->Steer Positive
%Accelerate--> Ax>0 Brake--> Ax<0
Track=1.105;                       %[m]  Track length
frontwheel_shift=0;                %[m]  Front wheel shift-positive inner shift
TrackL=0.7*Track;                  %[m]  CoG to side wheel centre
TrackRr=Track-TrackL;              %[m]  CoG to rear wheel axis
TrackRf=TrackRr-frontwheel_shift;  %[m]  CoG to front axis
WB=1.200;                          %[m]  Wheel base
lf=0.500*WB;                          %[m]  CoG to front axle
lr=WB-lf;                          %[m]  CoG to rear axle
lshift=0.000;                      %[m]  Sidewheel shift from real axle 
ls=lr-lshift;                      %[m]  CoG to sidewheel axle
m=180;                             %[kg] Vehicle weight
Iz=80;                             %[]   
HGC=0.165;                         %[m]  CoG height
CPf=12500;
CPr=12530;
Ck=1250;
mu=0.9;
Rr=0.155;
g=9.8;
toe=0;

v0=20;                        %[m/s] Speed
%%LEFT TURN
simcglongitu=zeros(1,12);
i=1;
for lf=0.3:0.05:0.8
    
sim('F2sidecarv4.slx');
simcglongitu(i)=max(simout(:,1));
i=i+1;
end
lf=0.7;
simWB=zeros(1,12);
i=1;
for WB=1.1:0.05:1.6
    
sim('F2sidecarv4.slx');
simWB(i)=max(simout(:,1));
i=i+1;
end

WB=1.2;
simSDW=zeros(1,15);
i=1;
for lshift=1:0.005:1.105
    
sim('F2sidecarv4.slx');
simSDW(i)=max(simout(:,1));
i=i+1;
end

lshift=0.2;
simTrack=zeros(1,25);
i=1;
for Track=0:0.05:0.6
    
sim('F2sidecarv4.slx');
simTrack(i)=max(simout(:,1));
i=i+1;
end

Track=1.105;
simFWS=zeros(1,30);
i=1;
for frontwheel_shift=-0.075:0.005:0.075
    
sim('F2sidecarv4.slx');
simFWS(i)=max(simout(:,1));
i=i+1;
end
%%Right turn
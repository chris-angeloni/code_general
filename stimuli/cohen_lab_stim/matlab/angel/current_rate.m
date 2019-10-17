%fuction current_rate
%    Fuction    analysis of relationship between current and spike rate
%
%    see also  Hodgkin.mdl, Hodgkin1, action_potential, refratory, current_sine, ananoise


function current_rate
for i=1:1000,
     Iin=(i*1e-7)*ones(10000,1);
     Noise=zeros(10000,1);
     mode=0;
     [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin); 
     crate(i,1)=i*1e-3;
     crate(i,2)=rate;
end
    bar(crate(:,1),crate(:,2),0.0005);
    xlabel('Current  (mA)');
    ylabel('Spike Rate (1/msec)');
    save d:\matlab\data\current_rate.mat crate;    
    clear;
    

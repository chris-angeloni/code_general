%fuction crate
%    Fuction    analysis of relationship between current and spike rate
%
%    see also  Hodgkin.mdl, Hodgkin1, action_potential, refratory, current_sine, ananoise


function crate
for i=1:1000,
   Iin=(i*1e-7)*ones(10000,1);
   [t,Vout,rate,Spike]=HHmodel1(Iin);
   crate(i,1)=i*1e-7;
   crate(i,2)=rate;
end
    bar(crate(:,1),crate(:,2),0.0005);
    xlabel('Current  (mA)');
    ylabel('Spike Rate (1/msec)');
    save d:\matlab\crate.mat crate;    
    
function [RASspet2,N2]=rasterbrk(RASspet1,FMAxis,C,MaxTrl,Tinit)
%   DESCRIPTION     : Break down orginal raster (RASspet1) to RASspet2

% INPUT:
% C         : wanted cycles per trial in RASspet2 
%Tinit      : initial time in RASspet1 to be discarded, usually it's 1 or 0.5 sec.
%MaxTrl     : wanted max # of broken trials for one trial of RASspet1

% RETURN:
% N2        : # of broken trials for one trial of a given stimulus trial in RASspet1
% RASspet2  : broken raster in compressed spet RASTER format
%           .spet
%           .T
%           .Fs

Fs = RASspet1(1).Fs;
N1 = length(RASspet1)/length(FMAxis);  % # of trials per condition in RASspet1 (=10)
N2 = []; % # of trials per condition in RASspet2

i=1; % trial # in RASspet2
for FMi=1:length(FMAxis)
    
for n1=1:N1
    % T1 = RASspet1((FMi-1)*N1+n1).T;
    T1 =4;
    N2(FMi) = floor(T1*FMAxis(FMi)/C);  % # of breakdown trials for a given condition FMAxis(FMi) in one RASspet1 trial
    
   if N2(FMi)==0  % Do not have C cycles in one org raster
       RASspet2(i).Fs = Fs;
       RASspet2(i).T = RASspet1((FMi-1)*N1+n1).T;
       RASspet2(i).spet =  RASspet1((FMi-1)*N1+n1).spet - Tinit*Fs;
       N2(FMi)=1;
       i=i+1;
       
   elseif N2(FMi)<=MaxTrl %Do not have MaxTrl in one org trial
       C2=[0:1:N2(FMi)];
    for n2=1:N2(FMi)     
Tstart = C2(n2)*C/FMAxis(FMi)+Tinit;
Tend = C2(n2+1)*C/FMAxis(FMi)+Tinit;
RASspet2(i).Fs = Fs;
RASspet2(i).T = C/FMAxis(FMi);
index = find(RASspet1((FMi-1)*N1+n1).spet>Tstart*Fs & RASspet1((FMi-1)*N1+n1).spet<=Tend*Fs);
RASspet2(i).spet=RASspet1((FMi-1)*N1+n1).spet(index) - Tstart*Fs;
    i=i+1;
    end % end of n2
    
   else N2(FMi)>MaxTrl
       C2=[0:1:MaxTrl];
       for n2=1:MaxTrl
Tstart = C2(n2)*C/FMAxis(FMi)+Tinit;
Tend = C2(n2+1)*C/FMAxis(FMi)+Tinit;
RASspet2(i).Fs = Fs;
RASspet2(i).T = C/FMAxis(FMi);
index = find(RASspet1((FMi-1)*N1+n1).spet>Tstart*Fs & RASspet1((FMi-1)*N1+n1).spet<=Tend*Fs);
RASspet2(i).spet=RASspet1((FMi-1)*N1+n1).spet(index) - Tstart*Fs;
    N2(FMi)=MaxTrl;
i=i+1;
    end % end of n2
       
   end  % end of if
       
end % end of n1
end % end of FMi

RAStt1.time = [];
RAStt1.trial = [];
for k=1:length(RASspet1)
    RAStt1.time = [RAStt1.time RASspet1(k).spet/RASspet1(k).Fs];
    RAStt1.trial = [RAStt1.trial k*ones(size(RASspet1(k).spet))];  
end
figure
plot(RAStt1.time,RAStt1.trial,'k.');
title(['Orginal RASTER']);

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet2)
    RAStt.time = [RAStt.time RASspet2(k).spet/RASspet2(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet2(k).spet))];  
end
figure
plot(RAStt.time,RAStt.trial,'k.');
title(['Broken RASTER']);
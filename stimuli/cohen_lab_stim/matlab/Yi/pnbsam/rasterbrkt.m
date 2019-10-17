function [RASspet2,N2]=rasterbrkt(RASspet1,FMAxis,T,Tinit)
%   DESCRIPTION     : Break down orginal raster (RASspet1) to RASspet2 with
%   same duration

% INPUT:
% T         : wanted Times per trial in RASspet2 
%Tinit      : initial time in RASspet1 to be discarded, usually it's 0.5 sec.
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
    T1 =RASspet1(1).T;
    N2(FMi) = floor(T1/T);  % # of breakdown trials for a given condition FMAxis(FMi) in one RASspet1 trial
    for j=1:N2(FMi)
        n=N1*(FMi-1)+n1;
        index=find(RASspet1(n).spet/Fs>Tinit+(j-1)*T & RASspet1(n).spet/Fs<=Tinit+j*T);
        RASspet2(i).Fs = Fs;
        RASspet2(i).T =T;
        RASspet2(i).spet = RASspet1(n).spet(index)-Fs*Tinit-Fs*(j-1)*T;
        i=i+1;
    end % end of j
      
end % end of n1
end % end of FMi

RAStt1.time = [];
RAStt1.trial = [];
for k=1:length(RASspet1)
    RAStt1.time = [RAStt1.time RASspet1(k).spet/RASspet1(k).Fs];
    RAStt1.trial = [RAStt1.trial k*ones(size(RASspet1(k).spet))];  
end
% figure
% plot(RAStt1.time,RAStt1.trial,'k.');
% title(['Orginal RASTER']);

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet2)
    RAStt.time = [RAStt.time RASspet2(k).spet/RASspet2(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet2(k).spet))];  
end
figure
plot(RAStt.time,RAStt.trial,'k.');
title(['Broken RASTER']);
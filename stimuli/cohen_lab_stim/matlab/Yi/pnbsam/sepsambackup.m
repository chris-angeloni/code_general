% DESCRIPTION   : Seperate onset and sustained component from SAM
% response 

% Yi Zheng, Jan 2007

function [RASonset,RASsus,Qreli]= sepsam(RASspet,Bound,FMAxis,stimmod,onset,num)

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis)

Qreli = zeros(1,length(FMAxis));
% Bound = 0.05*ones(1,length(FMAxis));
        
for FMindex = 1:length(FMAxis)
   % binW=1/FMAxis(FMindex)/50;
   FM = FMAxis(FMindex);
   binW = 0.0002
 for n = (RAStt.N*FMindex-RAStt.N+1):(RAStt.N*FMindex)
  SpikeTime = RAStt.time(find(RAStt.trial==n));
  cyctime=[];
  if strcmp(stimmod,'cyc')
     for c=onset:(onset+num)
        cyctime1 = SpikeTime(find((SpikeTime>c/FM)&(SpikeTime<(c+1)/FM)) );
        cyctime =[cyctime cyctime1];
     end
  else strcmp(stimmod, 'duration')
     for c=round(onset*FM):round((onset+num)*FM)
        cyctime1 = SpikeTime(find((SpikeTime>c/FM)&(SpikeTime<(c+1)/FM)) );
        cyctime = [cyctime cyctime1];
     end
  end  % end of if
 end
 
  for k=(RAStt.N*(FMindex-1)+1):(RAStt.N*FMindex)
    i_onset=find(mod(RASspet(k).spet/RASspet(k).Fs,1/FM) < Bound(FMindex));
    RASonset(k).spet = RASspet(k).spet(i_onset);
    i_sus=find(mod(RASspet(k).spet/RASspet(k).Fs,1/FM) >= Bound(FMindex));
    RASsus(k).spet = RASspet(k).spet(i_sus);
    
    RASonset(k).Fs = RASspet(k).Fs;
    RASsus(k).Fs = RASspet(k).Fs;
  end
    
end  % end of FMindex


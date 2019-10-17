function [RASsh]=shuffleras(RASspet,FMAxis,stimmod,onset)

%   DESCRIPTION : Generate shuffled raster from RASspet
%  onset   : remove the first seconds or first cycles in time before
%  shuffling, based on the onset removal of RASspet

for i=1:length(RASspet)
    if strcmp(stimmod,'duration')  
    % [RASsh(i).spet]=shufflespet(RASspet(i).spet-1*RASspet(1).Fs);  % if the RASspet removed the initial 1s
    [RASsh(i).spet]=onset*RASspet(i).Fs+shufflerandspet(RASspet(i).spet,RASspet(i).Fs,RASspet(i).T);
    else strcmp(stimmod,'cyc')  
      for FMi=1:length(FMAxis)
       [RASsh(i).spet]=shufflerandspet(RASspet(i).spet-onset/FMAxis(FMi)*RASspet(1).Fs,RASspet(i).Fs,RASspet(i).T);
      end
    end
    RASsh(i).Fs = RASspet(i).Fs;
    RASsh(i).T = RASspet(i).T;
end

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASsh)
    RAStt.time = [RAStt.time RASsh(k).spet/RASsh(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASsh(k).spet))];  
end

figure(1)
plot(RAStt.time,RAStt.trial,'k.');
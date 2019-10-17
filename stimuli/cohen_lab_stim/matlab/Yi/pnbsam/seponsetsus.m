% DESCRIPTION   : Seperate onset and sustained component from ONSET
% response based on the distribution of 1st and 2nd spike. Threshold is set
% at min(2nd spike)

% Yi Zheng, Jan 2007

function [RASonset,RASsus,Qreli,Bound]= seponsetsus(RASspet,FMAxis,Flag,stimmod,onset,num)

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis)

Qreli = zeros(1,length(FMAxis));
Bound = zeros(1,length(FMAxis));

[RAS1tt,RAS1spet,RAS2tt,RAS2spet]=raster1stspet(RAStt,RASspet,FMAxis,Flag,stimmod,onset,num)

for FMindex = 1:length(FMAxis)
   % binW=1/FMAxis(FMindex)/50;
   binW = 0.0002
[Qreli(FMindex),Bound(FMindex)]=onsetsep(RASspet,binW,FMindex,FMAxis);
  
if FMindex>1
  if Bound(FMindex)>Bound(FMindex-1)
      Bound(FMindex)=Bound(FMindex-1)
  end
end

% if Bound(FMindex)> 0.02
%     Bound(FMindex)=0.02
% end

% Bound=0.016*ones(1,length(FMAxis))

  for k=(RAS1tt.N*(FMindex-1)+1):(RAS1tt.N*FMindex)
    if RAS1spet(k).spet/RAS1spet(k).Fs < Bound(FMindex)
       RASonset(k).spet = RAS1spet(k).spet;
       RASsus(k).spet = RAS2spet(k).spet;
    else
       RASonset(k).spet = [];
       RASsus(k).spet = [RAS1spet(k).spet RAS2spet(k).spet]
    end  % end of if
   end  % end of k
end  % end of FMindex


RASonsettt.time =[]
RASonsettt.trial=[]
for k=1:length(RASonset)
    RASonset(k).Fs = RAS1spet(k).Fs;
    RASonsettt.time = [RASonsettt.time RASonset(k).spet/RAS1spet(k).Fs];
    RASonsettt.trial = [RASonsettt.trial k*ones(size(RASonset(k).spet))];  
end

RASsustt.time =[]
RASsustt.trial=[]
for k=1:length(RASsus)
    RASsus(k).Fs = RAS1spet(k).Fs;
    RASsustt.time = [RASsustt.time RASsus(k).spet/RAS1spet(k).Fs];
    RASsustt.trial = [RASsustt.trial k*ones(size(RASsus(k).spet))];  
end
figure(4)
subplot(211)
plot(RASonsettt.time,RASonsettt.trial,'.');
title('Raster ONSET');
subplot(212)
plot(RASsustt.time,RASsustt.trial,'.');
title('Raster SUSTAIN');
  
figure(5)
RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end

Timebound = [];
    for k=1:length(FMAxis)
      Timebound = [Timebound Bound(k)*ones(1,100)];
    end
% plot(RAStt.time,RAStt.trial,'b.',Timebound,1:length(RASspet),'r');
plot(RASonsettt.time, RASonsettt.trial,'g.');
hold on
Timebound = [];
    for k=1:length(FMAxis)
      Timebound = [Timebound 1/FMAxis(k)*ones(1,RAStt.N)];
    end
plot(RASsustt.time, RASsustt.trial,'.b',Timebound,1:length(RASspet),'r');
    
  
  
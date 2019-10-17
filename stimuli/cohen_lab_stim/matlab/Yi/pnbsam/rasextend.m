% DESCRIPTION   :

function [RAStt, RAS]=rasextend(RASspet,FMAxis)

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis);
figure
plot(RAStt.time, RAStt.trial,'g.');
axis([0 0.2 0 length(RASspet)])

for i=1:length(FMAxis)*10
    RAS(i).spet=[]
end

for FMi=1:length(FMAxis)
  for k=(RAStt.N*(FMi-1)+1):(RAStt.N*FMi)
    j = ceil(k/10);
    RAS(j).Fs = RASspet(1).Fs;
    RAS(j).T = 1/FMAxis(FMi)*10;
    if isempty(RASspet(k).spet)
        temp = [];
    else
        temp=RASspet(k).spet/RASspet(k).Fs + 1/FMAxis(FMi)*mod(k,10);
        RAS(j).spet = [RAS(j).spet temp*RAS(j).Fs];
    end
  end % end of k   
end  % end of FMi

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RAS)
    RAStt.time = [RAStt.time RAS(k).spet/RAS(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RAS(k).spet))];  
end

figure
plot(RAStt.time, RAStt.trial,'.');
axis([0 0.2*10 0 length(RAS)])
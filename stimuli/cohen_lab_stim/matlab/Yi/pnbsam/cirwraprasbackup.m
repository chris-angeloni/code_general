function [RASwrap]=cirwrapras(RAS,FMAxis)

%N = length(RAS)/length(FMAxis)
N=100;
for n=1:length(RAS)
    RASspet = [];
    RASspet = RAS(n).spet;
    period = 1/FMAxis(floor((n-1)/N)+1)*RAS(n).Fs;
    RASwrap(n).spet = mod(RASspet,period);
%     if mod(RASspet,period)==0
%         RASwrap(n).spet = period;
%     end
    RASwrap(n).Fs = RAS(n).Fs
    RASwrap(n).T = period/RAS(n).Fs;
end  % end of n

RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASwrap)
    RAStt.time = [RAStt.time RASwrap(k).spet/RASwrap(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASwrap(k).spet))];  
end

plot(RAStt.time,RAStt.trial,'b.');
  
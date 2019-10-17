function [SpetMean,SpetSD,Lbound,Hbound]=meansdgen(RASspet,FMAxis,Flag,CYCH)

%	DESCRIPTION : Generate mean and sd MTF of spike times

% Yi Zheng, Jan 2007

% if Flag == 1
%     [Hbound,Lbound]=modelfit(CYCH,FMAxis)
% end
RAStt.time =[]
RAStt.trial=[]
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis)

for k=1:length(FMAxis)
 SpetTime = [];
 for n=1:RAStt.N
  if (Flag == 0 | Flag ==1)
    SpetTime=[SpetTime mod(RAStt.time(find(RAStt.trial == n+RAStt.N*(k-1))), 1/FMAxis(k))];
  else 
    SpetTime=[SpetTime RAStt.time(find(RAStt.trial == n+RAStt.N*(k-1)))];
  end
  end    % end of n  
  
% if Flag==1
%   SpetTime2 = SpetTime(find(SpetTime>=Lbound(k) & SpetTime<=Hbound(k)));  
% else (Flag==0 | Flag==2)
    SpetTime2 = SpetTime; 
% end
 if isempty(SpetTime2)
     SpetMean(k) = SpetMean(k-1);
     SpetSD(k) = SpetSD(k-1);
 else
     SpetMean(k) = mean(SpetTime2);
     SpetSD(k) = sqrt(var(SpetTime2));
 end  % end of if
end   % end of k

Lbound = SpetMean - SpetSD;
Hbound = SpetMean + SpetSD;

figure(3)
subplot(211)
% hold on
semilogx(FMAxis,SpetMean,'.-');
title('mean');
xlim([1 2000]);
subplot(212)
% hold on
semilogx(FMAxis,SpetSD,'.-');
title('SD');
xlabel('Mod Freq (Hz)');
xlim([1 2000]);
function [SpetMean,SpetSD,Lbound,Hbound]=meansdgen(RASspet,FMAxis,Flag,CYCH,Dtran)

%	DESCRIPTION : Generate mean and sd of spike times

% Dtran     : transmition delay

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
 T = 1/FMAxis(k);
 SpetTime = [];
 for n=1:RAStt.N
  if (Flag == 0 | Flag ==1)
    tinC= mod(RAStt.time(find(RAStt.trial == n+RAStt.N*(k-1))), 1/FMAxis(k));  % time in a cycle
    if tinC<Dtran(k)
    t = tinC+T*floor(Dtran(k)/T);
      if t<Dtran(k)
      t = t+T;
      end
    SpetTime=[SpetTime t];
    else % tinC>Dtran(k)
    SpetTime=[SpetTime tinC];
    end  % end of tinC
  else  % Flag=2
    SpetTime=[SpetTime RAStt.time(find(RAStt.trial == n+RAStt.N*(k-1)))];
  end  % end of Flag
  end    % end of n  
  
% if Flag==1
%   SpetTime2 = SpetTime(find(SpetTime>=Lbound(k) & SpetTime<=Hbound(k)));  
% else (Flag==0 | Flag==2)
    SpetTime2 = SpetTime; 
% end
 if isempty(SpetTime2)
     SpetMean(k) =nan(1);
     SpetSD(k) = nan(1);
 else
     SpetMean(k) = mean(SpetTime2);
     SpetSD(k) = sqrt(var(SpetTime2));
 end  % end of if
end   % end of k

Lbound = SpetMean - SpetSD;
Hbound = SpetMean + SpetSD;

% figure
% subplot(211)
% semilogx(FMAxis,SpetMean,'.-');
% title('mean');
% xlim([1 2000]);
% subplot(212)
% semilogx(FMAxis,SpetSD,'.-');
% title('SD');
% xlabel('Mod Freq (Hz)');
% xlim([1 2000]);
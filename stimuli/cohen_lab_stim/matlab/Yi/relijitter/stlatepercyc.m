% DESCRIPTION   : first spike latency per cycle

function [SPET]=stlatepercyc(RASspet,FMAxis)

N=length(RASspet)/length(FMAxis);
for FMi=1:length(FMAxis)
 stlate=[];   
 for k=(FMi*N-N+1):(FMi*N)
   temp=RASspet(k).spet./RASspet(k).Fs;
   for n=1:floor(max(temp)*FMAxis(FMi))
      index=find(temp>n/FMAxis(FMi) & temp<=(n+1)/FMAxis(FMi));
      if ~isempty(index)
         stlate=[stlate temp(min(index))];  % first-spike latency per cycle
      end  % end of if
   end % end of n
 end % end of k
 SPET(FMi).fst = mod(stlate,1/FMAxis(FMi));
 SPET(FMi).m = mean(SPET(FMi).fst);
 SPET(FMi).std = std(SPET(FMi).fst);
end % end of FMi

figure
semilogx(FMAxis,[SPET.m]);
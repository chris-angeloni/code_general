% DESCRIPTION   : first spike latency per trial

function [SPET]=stlatepertrial(RASspet,FMAxis)

N=length(RASspet)/length(FMAxis);
for FMindex=1:length(FMAxis)
  for k=(FMindex*N-N+1):(FMindex*N)
      temp = RASspet(k).spet(find(RASspet(k).spet/RASspet(k).Fs<0.020)) % spike time < 15ms
     if isempty(temp)
        SPET(FMindex).fst(k-(FMindex-1)*N)=nan(1);
     else
     SPET(FMindex).fst(k-(FMindex-1)*N)=temp(1)/RASspet(k).Fs;
     end
  end  % end of k
  st=SPET(FMindex).fst;
  SPET(FMindex).m=mean(st(find(~isnan(st))));
  SPET(FMindex).std=std(st(find(~isnan(st))));
end  % end of FMindex

figure
semilogx(FMAxis, [SPET.m]);
function [ISI,ISI1st]=distisionset(RASspet,FMAxis)

N = length(RASspet)/length(FMAxis)  % repetition number
for k=1:length(RASspet)
ISI(k).isi = diff(RASspet(k).spet./RASspet(k).Fs)
end

for FMindex=1:length(FMAxis)
  ISI1st(FMindex).isi=[];
  for n=1:N
    j=(FMindex-1)*N+n
  if RASspet(j).spet(1)/RASspet(j).Fs<0.04
      ISI1st(FMindex).isi=[ISI1st(FMindex).isi ISI(j).isi(1)];
  end % end of if
  end  % end of n
  ISI1st(FMindex).hist=histc(ISI1st(FMindex).isi,[0:0.001:0.04]);
end % end of FMindex

 
% DESCRIPTION:  Latency to RASspet
function [RASspet]=lat2ras(FMAxis,LATE)

for FMi=1:18
  for n=1:10
    RASspet((FMi-1)*10+n).Fs=12207;
    RASspet((FMi-1)*10+n).T=0.2;
    temp=[LATE.stevent(FMi).fst].*12207;
    RASspet((FMi-1)*10+n).spet=temp(n);
  end
end
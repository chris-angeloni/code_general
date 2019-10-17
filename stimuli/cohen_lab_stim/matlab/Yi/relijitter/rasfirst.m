% DESCRIPTION    : pick up 1st spike per cycle

function [RASspet1st]=rasfirst(RASspet,FMAxis)

for FMi=1:length(FMAxis) 
for rep=1:10
    i=(FMi-1)*10+rep;
a=RASspet(i).spet/RASspet(i).Fs;
b=zeros(1,length(a));
  for n=1:floor(max(a)*FMAxis(FMi))
    index=find(a>n/FMAxis(FMi) & a<(n+1)/FMAxis(FMi));
    b(min(index))=a(min(index));
  end % end of n
RASspet1st(i).spet=b.*RASspet(i).Fs;
RASspet1st(i).Fs=RASspet(i).Fs;
RASspet1st(i).T=RASspet(i).T;
end % end of rep
end % end of FMi
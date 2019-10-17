function [Qreli,Bound]=onsetsep(RASspet,binW,FMindex,FMAxis)

%       DESCRIPTION : Regarding one stimulus condition, Seperate the onset and 
%       sustained spikes based on the distribution of 1st spikes
%		

Onset = [];
Sus = [];
Timeall = [];

First = [];
Second = [];
All = [];
N = length(RASspet)/length(FMAxis);
for k= (FMindex*N-N+1):(FMindex*N)
  All = [All RASspet(k).spet./RASspet(k).Fs];
  len = length(RASspet(k).spet);
  if isempty(RASspet(k).spet)
      First = [First];
  else
      First = [First RASspet(k).spet(1)/RASspet(k).Fs];
  end
  if length(RASspet(k).spet)<2
      Second = [Second];
  else
      Second = [Second RASspet(k).spet(2)/RASspet(k).Fs];
      % Second = [Second RASspet(k).spet(2:len)./RASspet(k).Fs];
  end
end

if isempty(All)
    Bound = 0; 
    Qreli = 0
elseif isempty(Second)
    Bound = max(First);
    Qreli = length(First)/length(All);
else
    Bound = min(Second);
    Qreli = length(First)/length(All);
end
Qreli = length(First)/length(All);



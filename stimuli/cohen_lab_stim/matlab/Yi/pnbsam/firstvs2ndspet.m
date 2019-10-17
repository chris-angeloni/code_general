% DESCRIPTION   : Distribution of first and second spike timing

function [SPET2] = firstvs2ndspet(RASspet,FMAxis)

binW = 0.0002
time = [0:binW:0.2]

for FMindex = 1:length(FMAxis)
N = length(RASspet)/length(FMAxis);
SPET2(FMindex).st = zeros(1,N);
SPET2(FMindex).nd = zeros(1,N);
for k= (FMindex*N-N+1):(FMindex*N)
  len = length(RASspet(k).spet);
  temp = RASspet(k).spet(find(RASspet(k).spet/RASspet(k).Fs>0.010)) % spike time > 15ms
  % if isempty(RASspet(k).spet)
  if isempty(temp)
      SPET2(FMindex).st(k-(FMindex-1)*N)=0;
  else
      % SPET2(FMindex).st(k-(FMindex-1)*N) = RASspet(k).spet(1)/RASspet(k).Fs;  
      SPET2(FMindex).st(k-(FMindex-1)*N) = temp(1)/RASspet(k).Fs;
  end
  if length(temp)<2
      SPET2(FMindex).nd(k-(FMindex-1)*N)=0;
  else
      SPET2(FMindex).nd(k-(FMindex-1)*N) = temp(2)/RASspet(k).Fs;
  end
end  % end of k

  dist1 = histc(SPET2(FMindex).st,time);
%   figure
%   subplot(211)
%   bar(time,dist1);
%   xlim([binW 0.2])
%   title(['1st spike dist' num2str(FMAxis(FMindex)) ' Hz']);
%   subplot(212)
  dist2 = histc(SPET2(FMindex).nd,time);
%   bar(time,dist2)
%   xlim([binW 0.2])
%   title('2nd spike dist');
  
%   figure
%   bar(time,dist2,'r');
%   hold on 
%   bar(time,dist1);
%  
%  figure
%  plot(SPET2(FMindex).st,SPET2(FMindex).nd,'.');
%  xlabel('1st spike time');
%  ylabel('2nd spike time');
%  title([num2str(FMAxis(FMindex)) ' Hz']);
end % end of FMindex
 
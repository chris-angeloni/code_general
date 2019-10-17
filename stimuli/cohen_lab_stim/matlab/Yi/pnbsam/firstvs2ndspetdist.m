% DESCRIPTION   : Distribution of first and second spike timing

function [First,Second,Dist] = stvs2ndspet(RASspet,FMAxis)

binW = 0.0002
time = [0:binW:0.06]
FMindex =1
First = [];
Second = [];
N = length(RASspet)/length(FMAxis);
for k= (FMindex*N-N+1):(FMindex*N)
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
  dist1 = histc(First,time);
  figure
  subplot(211)
  bar(time,dist1);
  title('1st spike dist')
  subplot(212)
  dist2 = histc(Second,time);
  bar(time,dist2,'r')
  title('2nd spike dist');
  figure
  bar(time,dist2,'r');
  hold on 
  bar(time,dist1);
 
  
  Dist=zeros(length(dist1),length(dist2));
  for x=1:length(dist1)
   index = find(First>binW*(x-1) & First<=binW*x);
   if isempty(index)
       Dist(x,:)=0;
   else
       Dist(x,:)=histc(Second(index),time);
   end  % end of if
  end  % end of x
 
 figure
 pcolor(time,time,Dist)
shading flat,colormap jet,colorbar
 
% DESCRIPTION   : jitter % reliability based on binned spike train

function [MTFJ]=jittersam(RASspetk,Fsd,Fm,t0,N)

deltat=0.005; % bin in sec

for i=1:N  % N: number of cycles
 in=find(RASspetk(i).spet/12207>=t0 & RASspetk(i).spet/12207<t0+deltat);
 if ~isempty(in)
   RASk(i).spet=RASspet2(i).spet(in);
 end
 RASk(i).T=1/Fm;
 RASk(i).Fs=RASspet2(i).Fs;
end   

if ~isempty(RASk)
  [R]=rastercircularxcorrfast(RASk,Fsd,'y',0);
end

 Ncenter = floor(length(R.Raa)/2)+1;
%   tempRab=R.Rshuf(1:N);  tempRaa=Raa(1:N);
%   Rab(1:N)=Rab(N+1:end); Rab(N+1:end)=tempRab;
%   Raa(1:N)=Raa(N+1:end); Raa(N+1:end)=tempRaa;
  R.Raa(Ncenter) = 0;
  Tau = (ceil(-length(R.Raa)/2):ceil(length(R.Raa)/2)-1)/Fsd;
  plot(Tau*1000,R.Raa);
  hold on;
  plot(Tau*1000,R.Rshuf,'r');
  hold off;
  pause(1);
  MTFJ.lambda = R.lambda;
  
  Rshuf=R.Rshuf/4;
  MTFJ.p = sum(Rshuf)/Fsd/R.lambda;
  
  Mean=sum(Tau.*Rshuf/sum(Rshuf));
  MTFJ.sigma=sqrt(sum((Tau-Mean).^2.*Rshuf/sum(Rshuf)));
  
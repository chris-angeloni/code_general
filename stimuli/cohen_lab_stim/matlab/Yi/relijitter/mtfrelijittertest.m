% Rate        : Spike rate
% FMAxis
% resomod     : resolution mode. 'abs': in ms;  'rel' in numbers/cycle
% Yi Zheng, Jan 2008

function [MTFJ]=mtfrelijittergau(RASTER,FMAxis,reso)

Nrep = 10;  % repetition N of each condition

% [RASspet2,Nbrk]=rasterbrk(RASTER,FMAxis,4,1341,1); % break down raster to 4-cyc segment
[RASspet2,Nbrk]=rasterbrkt(RASTER,FMAxis,1,1);
Ntrial=Nbrk*Nrep;
% RASspet2=RASTER;
% Ntrial=Nrep*ones(1,18);

for FMi=1:length(FMAxis)
   if FMi==1
       RASk = RASspet2(1:Ntrial(FMi));
   else
       RASk = RASspet2(sum(Ntrial(1:(FMi-1)))+(1:Ntrial(FMi)));
   end
% RASk=RASTER;
  if strcmp(reso,'abs')
      Fsd = round(1000);  %
  else strcmp(reso,'rel')
      Fsd = min(50*FMAxis(FMi),12207);
  end
% for FMi=1:1
  [R]=rastercircularxcorrfast(RASk,Fsd,'y',0);
  
  Ncenter = floor(length(R.Raa)/2)+1;  % center period
  %Ncenter = floor(length(R.Raa)/2)+1+floor(length(R.Raa)/4);
  R.Raa(Ncenter) = 0;
  MTFJ(FMi).Rab=R.Rshuf;  MTFJ(FMi).Raa=R.Raa;
  Tau = (ceil(-length(R.Raa)/2):ceil(length(R.Raa)/2)-1)/Fsd;
  NP = ceil(Fsd/FMAxis(FMi)/2);  % samples of 1/2 period
  Rshuf2=R.Rshuf(Ncenter-4*NP:Ncenter+4*NP-1);
  Tau2=Tau(Ncenter-4*NP:Ncenter+4*NP-1);
  Tau0=Tau(Ncenter-NP:Ncenter+NP-1);
  plot(Tau*1000,R.Raa);
  hold on;
  if ~isempty(R.Rshuf)
  plot(Tau*1000,R.Rshuf,'r');
  hold off;
  end
  pause(1);
  % lambda = RATE(FMi);
  MTFJ(FMi).lambda = R.lambda;
  
  Rshuf=R.Rshuf;
  
%   maxsigma = 1/FMAxis(FMi)/sqrt(2);  % assume sigma<1/Fm/2
%   NP0=ceil(Fsd*(1/FMAxis(FMi)-maxsigma));
%   Tau0=Tau(Ncenter-NP0:Ncenter+NP0-1);
%   Rab0=Rshuf(Ncenter-NP0:Ncenter+NP0-1);
%   Mean0=sum(Tau0.*Rab0/sum(Rab0));
%   sigma0=sqrt(abs(sum((Tau0-Mean0).^2.*Rab0/sum(Rab0))));
%   y1=1/sqrt(2*pi*sigma0^2)*exp(-Tau2.^2/(2*sigma0^2));
%   y2=1/sqrt(2*sigma0)*exp(-(Tau2-1/FMAxis(FMi)).^2/(2*sigma0^2));
%   y=y1+y2;
%   plot(Tau2*1000,y);
  
  beta0=[min(Rshuf2),max(Rshuf2)-min(Rshuf2),1/FMAxis(FMi)/2];
  T=1/FMAxis(FMi);
  [beta]=lsqcurvefit(@(beta,Tau2) gaussfun(beta,Tau2,T),beta0,Tau2,Rshuf2,[0 0 0],[max(Rshuf2) max(Rshuf2)*1.2 T]);
  MTFJ(FMi).lambdanoise=sqrt(beta(1));
  Rpeak=beta(2);
  MTFJ(FMi).sigmag=abs(beta(3))*1000/sqrt(2);

  plot(Tau2,gaussfun(beta,Tau2,T));
  hold on;
  plot(Tau2,R.Rshuf(Ncenter-4*NP:Ncenter+4*NP-1),'r');
  plot(Tau2,beta(1),'g-');
  plot(Tau2, beta(1)+beta(2)*exp(-Tau2.^2/(2*beta(3)^2)),'k');
  hold off;
  pause(1);
  
  Rshufreli = Rshuf2-beta(1);
  MTFJ(FMi).p = sqrt((sum(Rshufreli))/Fsd / FMAxis(FMi));
  MTFJ(FMi).RI = sqrt(sum(Rshufreli./MTFJ(FMi).lambda^2)/Fsd*FMAxis(FMi));  % for SAM
%   Mean=sum(Tau2.*Rshufreli/sum(Rshufreli));
%   sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rshufreli/sum(Rshufreli))));

  
  MTFJ(FMi).EFF=sum(Rshufreli)/sum(Rshuf2);
%   MTFJ(FMi).p = sum(Rpp2)/Fsd/R.lambda;
%   Mean=sum(Tau2.*Rpp2/sum(Rpp2));
%   sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rpp2/sum(Rpp2))));
   
%   sigma=sigma*1000/sqrt(2);       %Divide by sqrt(2) because correlation is sqrt(2) as wide as jitter    
%   MTFJ(FMi).sigma=sigma;
end %FMi

figure;
subplot(311)
semilogx(FMAxis,[MTFJ.p],'.r-');
subplot(312)
semilogx(FMAxis,abs([MTFJ.sigmag]),'.r-');
subplot(313)
semilogx(FMAxis,[MTFJ.EFF],'.r-');
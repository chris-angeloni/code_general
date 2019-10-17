% Rate        : Spike rate
% FMAxis
% resomod     : resolution mode. 'abs': in ms;  'rel' in numbers/cycle
% Yi Zheng, Jan 2008

function [MTFJ]=mtfrelijittertemp(RASTER,FMAxis,reso)

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
      Fsd = round(5000);  %
  else strcmp(reso,'rel')
      Fsd = min(100*FMAxis(FMi),12207);
  end
% for FMi=1:1
  [R]=rastercircularxcorrfast(RASk,Fsd,'y',0);
  
  Ncenter = floor(length(R.Raa)/2)+1;  % center period
  %Ncenter = floor(length(R.Raa)/2)+1+floor(length(R.Raa)/4);
  R.Raa(Ncenter) = 0;
  MTFJ(FMi).Rab=R.Rshuf/Fsd;  MTFJ(FMi).Raa=R.Raa/Fsd;
  Rpp=R.Rshuf-R.Raa;   
  MTFJ(FMi).Rpp=Rpp/Fsd;
  Tau = (ceil(-length(R.Raa)/2):ceil(length(R.Raa)/2)-1)/Fsd;
  NP = ceil(Fsd/FMAxis(FMi)/2);  % samples of 1/2 period
  Rshuf2=R.Rshuf(Ncenter-NP:Ncenter+NP-1)/Fsd;
  Rpp2=Rpp(Ncenter-NP:Ncenter+NP-1);
  Tau2=Tau(Ncenter-NP:Ncenter+NP-1);
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
  
  if min(Rshuf2)<0
      lambdanoise=0;
  else
  lambdanoise=sqrt(min(Rshuf2));
  end
  MTFJ(FMi).lambdareli=sqrt(R.lambda^2-lambdanoise^2);
  Rshufreli = Rshuf2-min(Rshuf2);
  % MTFJ(FMi).p = sum(Rshufreli)/Fsd/R.lambda;
  % MTFJ(FMi).p = sum(Rshufreli)/Fsd /MTFJ(FMi).lambdareli;
  MTFJ(FMi).p = sqrt((sum(Rshufreli)) / FMAxis(FMi));  
  % MTFJ(FMi).RI = sqrt((sum(Rshufreli))/Fsd / FMAxis(FMi))/(MTFJ(FMi).lambdareli/FMAxis(FMi));
  % MTFJ(FMi).RI = sqrt(sum(Rshufreli./MTFJ(FMi).lambdareli^2));
  MTFJ(FMi).RI = sqrt(sum(Rshufreli./MTFJ(FMi).lambdareli^2)/Fsd*FMAxis(FMi));  % for SAM
  Mean=sum(Tau2.*Rshufreli/sum(Rshufreli));
  sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rshufreli/sum(Rshufreli))));

  
  MTFJ(FMi).EFF=sum(Rshufreli)/sum(Rshuf2);
%   MTFJ(FMi).p = sum(Rpp2)/Fsd/R.lambda;
%   Mean=sum(Tau2.*Rpp2/sum(Rpp2));
%   sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rpp2/sum(Rpp2))));
   
  sigma=sigma*1000/sqrt(2);       %Divide by sqrt(2) because correlation is sqrt(2) as wide as jitter    
  MTFJ(FMi).sigma=sigma;
end %FMi

figure;
subplot(311)
semilogx(FMAxis,[MTFJ.p],'.r-');
subplot(312)
semilogx(FMAxis,abs([MTFJ.sigma]),'.r-');
% Rate        : Spike rate
% FMAxis
% resomod     : resolution mode. 'abs': in ms;  'rel' in numbers/cycle
% Yi Zheng, Jan 2008

function [MTFJ]=mtfrelijittercyc(RASTER,FMAxis,reso)

Nrep = 10;  % repetition N of each condition

% non-temporal noise seperation by CYCH
[CYCH,BINW]= cychgen(RASTER,0,FMAxis,50,'duration',1,4,10,2);
for i=1:18
minspk(i)=min(CYCH(1,i).hist);
end
Lambdanoise=minspk./BINW;

% [RASspet2,Nbrk]=rasterbrk(RASTER,FMAxis,4,1341,1); % break down raster to 4-cyc segment
[RASspet2,Nbrk]=rasterbrkt(RASTER,FMAxis,1,1); % break down raster to 1-sec segment
Ntrial=Nbrk*Nrep;
% RASspet2=RASTER;  %for SRN
% Ntrial=Nrep*ones(1,18);

for FMi=1:length(FMAxis)
   if FMi==1
       RASk = RASspet2(1:Ntrial(FMi));
   else
       RASk = RASspet2(sum(Ntrial(1:(FMi-1)))+(1:Ntrial(FMi)));
   end
% RASk=RASTER;
  if strcmp(reso,'abs')
      Fsd = round(10000);  %
  else strcmp(reso,'rel')
      Fsd = min(50*FMAxis(FMi),12207);
  end
% for FMi=1:1
  [R]=rastercircularxcorrfast(RASk,Fsd,'y',1000);
  
  Nctr = floor(length(R.Raa)/2)+1;  % center period
  %Nctr = floor(length(R.Raa)/2)+1+floor(length(R.Raa)/4);
  R.Raa(Nctr) = 0;
  MTFJ(FMi).Rab=R.Rshuf;  MTFJ(FMi).Raa=R.Raa;
  Tau = (ceil(-length(R.Raa)/2):ceil(length(R.Raa)/2)-1)/Fsd;
  NP = floor(Fsd/FMAxis(FMi)/2);  % samples of 1/2 period
  Rctr1=R.Rshuf(Nctr-NP:Nctr+NP-1);
  
  Tau2=Tau(Nctr-NP:Nctr+NP-1);
  
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

%  MTFJ(FMi).lambdareli=sqrt(abs(R.lambda^2-lambdanoise^2));
  Rshufreli=zeros(1,length(Rctr1));
  Rshufreli=Rctr1-Lambdanoise(FMi)^2;
  Rshufreli(find(Rshufreli<0))=0;
  MTFJ(FMi).Rshufreli=Rshufreli;
  MTFJ(FMi).Rabctr1=Rctr1;
  MTFJ(FMi).p = sqrt((sum(Rshufreli))/Fsd / FMAxis(FMi));  
  MTFJ(FMi).RI = sqrt(sum(Rshufreli./MTFJ(FMi).lambda^2)/Fsd*FMAxis(FMi));  % for SAM
  Mean=sum(Tau2.*Rshufreli/sum(Rshufreli));
  sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rshufreli/sum(Rshufreli))));
  MTFJ(FMi).EFF=sum(Rshufreli)/sum(Rctr1);
%   MTFJ(FMi).p = sum(Rpp2)/Fsd/R.lambda;
%   Mean=sum(Tau2.*Rpp2/sum(Rpp2));
%   sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rpp2/sum(Rpp2))));
   
  sigma=sigma*1000/sqrt(2);       %Divide by sqrt(2) because correlation is sqrt(2) as wide as jitter    
  MTFJ(FMi).sigma=sigma;
  [SEpeak]=stdjackknife(R,FMAxis(FMi),Fsd);
  MTFJ(FMi).Rpeak=max(Rctr1)-min(Rctr1);
  MTFJ(FMi).sepeak=SEpeak;
end %FMi

figure;
subplot(311)
semilogx(FMAxis,[MTFJ.p],'.r-');
subplot(312)
semilogx(FMAxis,abs([MTFJ.sigma]),'.r-');
subplot(313)
semilogx(FMAxis,[MTFJ.EFF],'.r-');



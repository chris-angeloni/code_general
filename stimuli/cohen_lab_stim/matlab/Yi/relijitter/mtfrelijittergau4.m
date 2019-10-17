% DESCRIPTION : compute reliability and jitter based on Rab fit with gaussian model
% FMAxis
% resomod     : 'abs': absolution;  'rel' in numbers/cycle
% Yi Zheng, June 2008

function [MTFJ]=mtfrelijittergau4(RASTER,FMAxis,reso)

Nrep = 10;  % repetition N of each condition

% [RASspet2,Nbrk]=rasterbrk(RASTER,FMAxis,4,1341,1); % break down raster to 4-cyc segment
[RASspet2,Nbrk]=rasterbrkt(RASTER,FMAxis,1,1); % break down raster to 1 sec segment
Ntrial=Nbrk*Nrep;

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
  [R]=rastercircularxcorrfast(RASk,Fsd,'y',1000);
  %R.Raa=R.Raa/Fsd; R.Rshuf=R.Rshuf/Fsd;
  Nctr = floor(length(R.Raa)/2)+1;  % center period
  R.Raa(Nctr) = 0;
  MTFJ(FMi).Rab=R.Rshuf;  MTFJ(FMi).Raa=R.Raa;
  Tau = (ceil(-length(R.Raa)/2):ceil(length(R.Raa)/2)-1)/Fsd;
  NP = ceil(Fsd/FMAxis(FMi)/2);  % samples of 1/2 period
  Rctr4=R.Rshuf(Nctr-4*NP:Nctr+4*NP-1); % 4 cycles Rab
  Tauctr4=Tau(Nctr-4*NP:Nctr+4*NP-1);  % Tau of 4 cycles
  Tauctr1=Tau(Nctr-NP:Nctr+NP-1);
  Rctr1=R.Rshuf(Nctr-NP:Nctr+NP-1);
  
  plot(Tau*1000,R.Raa);
  hold on;
  if ~isempty(R.Rshuf)
  plot(Tau*1000,R.Rshuf,'r');
  hold off;
  end
  pause(1);
  % lambda = RATE(FMi);
  MTFJ(FMi).lambda = R.lambda;
  
  % 4-cycle Gaussian model
  if sum(Rctr4)==0
      MTFJ(FMi).sigmag=0;
      MTFJ(FMi).p=0;
      MTFJ(FMi).EFF=0;
      MTFJ(FMi).gaussfun=[];
  else
  T=1/FMAxis(FMi);
  betaL=[0 0 0 0];  % lower bound of beta
  betaU=[10*max(Rctr4) max(Rctr4) 1 T];  % upper bound of beta
  % beta0=[0,max(Rctr4)-min(Rctr4),T/2]; % starting point of beta
  %[beta]=lsqcurvefit(@(beta,Tauctr4) gaussfun(beta,Tauctr4,T),beta0,Tauctr4,Rctr4,betaL,betaU); %max(Rctr4),abs(min(Rctr4))
  [beta,R0,J0]=lsqcurve4optim(Tauctr4,Rctr4,T,betaL,betaU);
  
  MTFJ(FMi).lambdaideal=beta(1);
  MTFJ(FMi).lambdanoise=beta(2); 
  MTFJ(FMi).p=beta(3);
  MTFJ(FMi).sigmag=abs(beta(4))*1000/sqrt(2);  % sigma
  MTFJ(FMi).gaussfun=gaussfun4(beta,Tauctr4,T); % 4-cycle Gaussian model
  DC=beta(2)^2+2*beta(3)*beta(1)*beta(2);
  peak=beta(3)^2*beta(1);
  MTFJ(FMi).gausssingle=DC+peak*exp(-Tauctr4.^2/(2*beta(4)^2)); % single Gaussian

  plot(Tauctr4,gaussfun4(beta,Tauctr4,T));
  hold on;
  plot(Tauctr4,R.Rshuf(Nctr-4*NP:Nctr+4*NP-1),'r');
  plot(Tauctr4,beta(2)^2,'g-');  % noise level
  plot(Tauctr4,beta(2)^2+2*beta(3)*beta(1)*beta(2),'m-');
  plot(Tauctr4,DC+peak*exp(-Tauctr4.^2/(2*beta(4)^2)),'k');
  plot(Tauctr4, DC+peak*exp(-(Tauctr4-T).^2/(2*beta(4)^2)),'k');
  plot(Tauctr4, DC+peak*exp(-(Tauctr4+T).^2/(2*beta(4)^2)),'k');
  plot(Tauctr4, DC+peak*exp(-(Tauctr4-2*T).^2/(2*beta(4)^2)),'k');
  plot(Tauctr4, DC+peak*exp(-(Tauctr4+2*T).^2/(2*beta(4)^2)),'k');
  %xlim([-T/2 T/2]);
  hold off;
  pause(1);
  
  Rshufreli=zeros(1,length(Rctr1));
  Rshufreli=Rctr1-(beta(2)^2+2*beta(3)*beta(1)*beta(2));
  MTFJ(FMi).EFF=sum(Rshufreli)/sum(Rctr1);

[SEdc,SEpeak,SEp,SEsigma,SEeff]=stdjackknifegauss(R,FMAxis(FMi),Fsd,beta,betaL,betaU);
% MTFJ(FMi).sep=SEp;  % standard error of p
% MTFJ(FMi).sesigma=SEsigma;  % standard error of sigma
% MTFJ(FMi).seeff=SEeff;   % standard error of efficient
MTFJ(FMi).sedc=SEdc;  % standard error of sigma
MTFJ(FMi).sepeak=SEpeak;   % standard error of efficient
  end % end of if 
end %FMi

figure;
subplot(311)
semilogx(FMAxis(1:length([MTFJ.p])),[MTFJ.p],'.r-');
subplot(312)
semilogx(FMAxis(1:length([MTFJ.sigmag])),abs([MTFJ.sigmag]),'.r-');
subplot(313)
semilogx(FMAxis(1:length([MTFJ.EFF])),[MTFJ.EFF],'.r-');

function [MI,EI]= meanstdMIEI(Rshuf,RshufJ,Flag,N,Fm)

% DESCRIPTION : get mean and standard deviation of MI and EI from jackknife
% shuf-corr
% Rshuf     : shuf-corr function
% RshufJt   : jackknife shuf-corr across trials
% N         : total number of samples

% MI.mean   :
%   .se     :
% EI.mean   :
% EI.se     :

% (c) Yi Zheng, Aug 2007

NJ = size(RshufJ,1);
MI.mean = (max(real(sqrt(Rshuf)))-min(real(sqrt(Rshuf))))/max(real(sqrt(Rshuf)));

L=10;
Fsd=Fm*L;
Tau=(-N:(N-1))/Fsd;
N=(length(Rshuf))/2;  
Tau=(-N:(N-1))/Fsd;
Rab_m = real(sqrt(Rshuf(1:40)));
if Flag==0
beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*Fm*Tau)+beta(2),[10 10],Tau,real(sqrt(Rshuf)));
Rmodel=beta(1)*cos(2*pi*Fm*Tau)+beta(2);
else
    % [Rmodel]=modelpnbshuf(Rshuf,Fm,L);
     beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*Fm*Tau)+beta(2),[10 10],Tau,Rab_m);
     PNBmodelSAM = beta(1)*cos(2*pi*Fm*Tau)+beta(2);

     [Rab_m,Rabmodelpnb]=modelpnb(Rab_m,Fm,L,Fsd);
     Rmodel = Rabmodelpnb(1:40)-PNBmodelSAM(1:40);
     Rabres = Rab_m(1:40)-PNBmodelSAM(1:40);
     Rab_m = Rabres;
    
end
r=corrcoef(Rmodel(1:40),Rab_m(1:40));
EI.mean=r(1,2);

% Jackknife MI and EI 
for k=1:NJ
  R = RshufJ(k,1:40);
  R_m = real(sqrt(R));
  MIJ(k,1) = (max(R)-min(R))/max(R);
  if Flag==0
  beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*Fm*Tau)+beta(2),[10 10],Tau,real(sqrt(R)));
  Rmodel=beta(1)*cos(2*pi*Fm*Tau)+beta(2);
  else
      % [Rmodel]=modelpnbshuf(R,Fm,L);
     beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*Fm*Tau)+beta(2),[10 10],Tau,real(sqrt(R)));
     PNBmodelSAM = beta(1)*cos(2*pi*Fm*Tau)+beta(2);

     [R_m,Rabmodelpnb]=modelpnb(R_m,Fm,L,Fsd);
     Rmodel = Rabmodelpnb(1:40)-PNBmodelSAM(1:40);
     Rabres = R_m(1:40)-PNBmodelSAM(1:40);
     R_m = Rabres;
  end
  r=corrcoef(Rmodel,R_m);
  EIJ(k,1)=r(1,2);
end

% Jackknife Residuals of MI and EI
for k=1:NJ
    MIres(k,:) = mean(MIJ,1)-MIJ(k,1);
    EIres(k,:) = mean(EIJ,1)-EIJ(k,1);
end

MIset = sqrt((N-1)*var(MIres));  % standard error across trials
MIsec = MIset/sqrt(N-1); % se across trials 2 se across correlations
% MIsec = sqrt(N*(N-1)*var(MIres));  % from Rshufc directly
MI.se = MIsec;
%MI.std = MIsec*sqrt(Nt);  % standard deviation

EIset = sqrt((NJ-1)*var(EIres));
EIsec = EIset/sqrt(NJ-1);
% EIsec = sqrt(N*(N-1)*var(EIres));
EI.se = EIsec;
%EI.std = EIsec*sqrt(Nt);

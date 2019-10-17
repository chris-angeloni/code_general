function [MI,EI]= meanstdMIEI(Rshuf,RshufJt,Nt,Fm)

% Nt        : total number of trials

NJt = size(RshufJt,1);
MI.mean = (max(real(sqrt(Rshuf)))-min(real(sqrt(Rshuf))))/max(real(sqrt(Rshuf)));

L=10;
Fsd=Fm*L;
N=(length(Rshuf))/2;  
Tau=(-N:(N-1))/Fsd;
beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*Fm*Tau)+beta(2),[10 10],Tau,real(sqrt(Rshuf)) );
Rabmodel=beta(1)*cos(2*pi*Fm*Tau)+beta(2);
r=corrcoef(Rabmodel,real(sqrt(Rshuf)));
EI.mean=r(1,2);

for k=1:NJt
  R = real(sqrt(RshufJt(k,:)));
  MIJ(k,1) = (max(R)-min(R))/max(R);
  
  beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*Fm*Tau)+beta(2),[10 10],Tau,R);
  Rabmodel=beta(1)*cos(2*pi*Fm*Tau)+beta(2);
  r=corrcoef(Rabmodel,R);
  EIJ(k,1)=r(1,2);
end 

for k=1:NJt
    MIres(k,:) = mean(MIJ,1)-MIJ(k,1);
    EIres(k,:) = mean(EIJ,1)-EIJ(k,1);
end

MIset = sqrt((Nt-1)*var(MIres));
MIsec = MIset/sqrt(Nt-1);
MI.std = MIsec*sqrt(Nt);

EIset = sqrt((Nt-1)*var(EIres));
EIsec = EIset/sqrt(Nt-1);
EI.std = EIsec*sqrt(Nt);

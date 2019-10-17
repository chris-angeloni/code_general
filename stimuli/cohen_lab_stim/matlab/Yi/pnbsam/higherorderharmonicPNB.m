function [ESI]=higherorderharmonicPNB(SHUF,FMAxis)

L = 10;
for FMindex=1:length(FMAxis)
   Fm = FMAxis(FMindex);
   Rab_m = real(sqrt(SHUF(1,FMindex).Rab));
   Fsd =FMAxis(FMindex)*L;
   N = (length(Rab_m))/2;
   Tau = (-N:(N-1))/Fsd;
   beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2),[10 10],Tau,Rab_m);
   PNBmodelSAM = beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2);

   [Rab_m,Rabmodelpnb]=modelpnb(Rab_m(1:40),Fm,L,Fsd);
   Rabmodelres = Rabmodelpnb(1:40)-PNBmodelSAM(1:40);
   Rabres = Rab_m(1:40)-PNBmodelSAM(1:40);
   
   r = corrcoef(Rabmodelres,Rabres);
   ESI(FMindex) = r(1,2);
end
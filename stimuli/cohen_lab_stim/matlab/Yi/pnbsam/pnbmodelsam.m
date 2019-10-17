function [CC] = pnbmodelsam(MTFsh,FMAxis)

L=10;
for n=1:size(MTFsh,1)
    for FMindex=1:length(FMAxis)
      if ~isempty(MTFsh(n,FMindex).Rab)
      Rab_m=real(sqrt(MTFsh(n,FMindex).Rab(1,1:40))); 
      end
      Fsd =FMAxis(FMindex)*L;
      N = (length(Rab_m))/2;
      Tau = (-N:(N-1))/Fsd;
      beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2),[10 10],Tau,Rab_m);
      PNBmodelSAM = beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2);
      r = corrcoef(PNBmodelSAM,Rab_m);
	  CC(n,FMindex)= r(1,2);
    end %end of FMindex
end %end of n
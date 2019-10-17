% function [MTF] = mtfhistgen(CYCH,FMAxis,bins)
% DESCRIPTION   : Generate CYCH and fit it with sine wave



function [MTF] = mtfhistgen(CYCH,FMAxis,bins)

for FMi = 1:length(FMAxis);
   L = min(bins,round(12207/FMAxis(FMi)));
   Fsd = FMAxis(FMi)*L;
   Tau = (0:L)/L/FMAxis(FMi);
   beta1 = lsqcurvefit(@(beta1,time) beta1(1)*cos(2*pi*FMAxis(FMi)*Tau+beta1(2)),[10 10],Tau,CYCH(FMi).hist);
   phase = beta1(2);
   beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMi)*Tau+ phase)+beta(2),[10 10],Tau,CYCH(FMi).hist);
   bar(Tau,CYCH(FMi).hist);
   hold on
   plot(Tau,beta(1)*cos(2*pi*FMAxis(FMi)*Tau+phase)+beta(2),'r')
   hold off
   pause(1)
   
   MTF(FMi).Histmodel = beta(1)*cos(2*pi*FMAxis(FMi)*Tau+phase)+beta(2)
   r = corrcoef(MTF(FMi).Histmodel,CYCH(FMi).hist);
   MTF(FMi).r = r(1,2);
   MTF(FMi).phase = mod(phase,2*pi);
   MTF(FMi).DC = beta(2);
   MTF(FMi).CYCH = CYCH(FMi).hist;
   
end % end of FMi

figure
semilogx(FMAxis,[MTF.r]);
figure
semilogx(FMAxis,[MTF.phase]);
   
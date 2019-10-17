function [VS] = vsmtfall (HIST,CYCH_M, FMAxis, Nall)
Phase = 0:2*pi/50:2*pi
for FMi = 1:18
nspet = CYCH_M{FMi}  % the amount of spikes per bin
VS(FMi)=sqrt( (sum(sin(Phase).*nspet)).^2 + (sum(cos(Phase).*nspet)).^2 )/sum(nspet);

CYCH=[];
i=1;
for n=1:Nall
  if ~isempty(HIST(n,FMi).CYCH)
      t_nspet=HIST(n,FMi).CYCH;
      t_VS(i,FMi)=sqrt( (sum(sin(Phase).*t_nspet)).^2 + (sum(cos(Phase).*t_nspet)).^2 )/sum(t_nspet);
      i=i+1;
  end
end % end of n
  VS_M(FMi) = mean(t_VS(:,FMi));
  VS_sem(FMi) = std(t_VS(:,FMi))/sqrt(length(t_VS(:,FMi)));
end % end of FMi
figure
subplot(211)
semilogx(FMAxis, VS, '.-')
subplot(212)
FM2 = log10(FMAxis);
errorbar(FM2,VS_M,VS_sem);
set(gca,'Xtick',FMAxis);



% function [EIm,MIm]=popustat(EIall,MIall,FMAxis)

% OUT1      : Normalized by sum(IN)
% OUT2      : Normalized by max(IN)

% for FMindex = 1:18
%     EI=EIall(:,FMindex);MI=MIall(:,FMindex);
%     EIm.M(FMindex) = mean(EI(find(EI>0)));
%     EIm.sem(FMindex) = std(EI(find(EI>0)))/sqrt(length(find(EI>0))); 
%     MIm.M(FMindex) = mean(MI(find(MI>0)));
%     MIm.sem(FMindex) = std(EI(find(MI>0)))/sqrt(length(find(MI>0))); 
%     if FMindex>14
%:)     EIm.p(FMindex) = length(find(EI>0))/(length(EI)-36);
%     MIm.p(FMindex) = length(find(MI>0))/(length(MI)-36); 
%     else
%     EIm.p(FMindex) = length(find(EI>0))/length(EI);
%     MIm.p(FMindex) = length(find(MI>0))/length(MI);
%     end
% 
% %     VS(find(isnan(VS)))=0;
% %    VSm.M(FMindex) = mean(VS);
% %    VSm.sem(FMindex) = std(VS)/sqrt(length(VS));
%     
% end % end of FMindex


function [RATEm,NORMm,VSm,SynRm]=popustat(MTF,FMAxis,NB,unitindex)

% OUT1      : Normalized by sum(IN)
% OUT2      : Normalized by max(IN)

for j=1:length(unitindex);
  IN.RATE(j,:) = MTF.RATE(unitindex(j),:);
  IN.NORM(j,:) = MTF.NORM(unitindex(j),:);
  IN.VS(j,:) = MTF.VS(unitindex(j),:);
  IN.VSsig(j,:) = MTF.VSsig(unitindex(j),:);
end

for FMindex = 1:18
    VS=[];
    i=1;
    for n=1:length(IN.VSsig)
    if ~isempty(IN.VSsig(n,FMindex))
        if ~isnan(IN.VSsig(n,FMindex))
      VS(i) = IN.VSsig(n,FMindex);
      i = i+1;
        end
    end
    end % end of n
    
%      VSm.M(FMindex) = mean(VS(find(~isnan(VS))));
%      VSm.sem(FMindex) = std(VS(find(~isnan(VS))))/sqrt(length(find(~isnan(VS)))); 

for l=1:NB
    j = randsample(size(VS,2),size(VS,2),'true');
    VSboot(l,:) = median(VS(j));
end
    VSm.M(FMindex) = mean(VSboot,1);
    VSm.sem(FMindex) = std(VSboot,1);
end % end of FMindex

% normalize 
n=1;
for i=1:length(IN.RATE)
    if IN.RATE(i,:)==zeros(1,18)
        n=n;
    else
   OUT.RATE(n,:)=IN.RATE(i,:)/max(IN.RATE(i,:));
   OUT.NORM(n,:)=IN.NORM(i,:)/max(IN.NORM(i,:));
   OUT.SynR(n,:)=IN.RATE(i,:).*IN.VS(i,:)/max(IN.RATE(i,:).*IN.VS(i,:));
  
%   OUT.RATE(i,:)=IN.RATE(i,:)/max(IN.RATE(i,:));
%   OUT.NORM(i,:)=IN.NORM(i,:)/max(IN.NORM(i,:));
%    OUT.RATE(n,:) = IN.RATE(i,:);
%    OUT.NORM(n,:)=IN.NORM(i,:);
%    OUT.SynR(n,:)=IN.RATE(i,:).*IN.VS(i,:);
   n=n+1;
    end
end

for FMindex = 1:18
    RATE=[]; NORM=[];
    j = 1;
    for n=1:length(OUT.RATE)
    if ~isempty(OUT.RATE(n,FMindex))
        RATE(j)=OUT.RATE(n,FMindex);
        NORM(j)=OUT.NORM(n,FMindex);
        SynR(j)=OUT.SynR(n,FMindex);
        j=j+1;
    end
    end % end of n
    
    RATE2=RATE(find(~isnan(RATE)));
    for l=1:NB
    j = randsample(size(RATE2,2),size(RATE2,2),'true');
    RATEboot(l,:) = median(RATE2(j));
    end
    RATEm.M(FMindex) = mean(RATEboot,1);
    RATEm.sem(FMindex) = std(RATEboot,1);
    
    NORM2=NORM(find(~isnan(NORM)));
    for l=1:NB
    j = randsample(size(NORM2,2),size(NORM2,2),'true');
    NORMboot(l,:) = median(NORM2(j));
    end
    NORMm.M(FMindex) = mean(NORMboot,1);
    NORMm.sem(FMindex) = std(NORMboot,1);
    
    SynR2=SynR(find(~isnan(SynR)));
    for l=1:NB
    j = randsample(size(SynR2,2),size(SynR2,2),'true');
    SynRboot(l,:) = median(SynR2(j));
    end
    SynRm.M(FMindex) = mean(SynRboot,1);
    SynRm.sem(FMindex) = std(SynRboot,1);
    
%     RATEm.M(FMindex) = mean(RATE(find(~isnan(RATE))));
%     RATEm.sem(FMindex) = std(RATE(find(~isnan(RATE))))/sqrt(length(find(~isnan(RATE)))); 
%     NORMm.M(FMindex) = mean(NORM(find(~isnan(NORM))));
%     NORMm.sem(FMindex) = std(NORM(find(~isnan(NORM))))/sqrt(length(find(~isnan(NORM)))); 
end % end of FMindex

FM2 = log10(FMAxis);
figure
subplot(411)
errorbar(FM2,RATEm.M,RATEm.sem);
set(gca,'Xtick',FMAxis);
xlim([0 log10(2000)])
ylabel('spikes/s');

subplot(412)
errorbar(FM2,NORMm.M,NORMm.sem);
set(gca,'Xtick',FMAxis);
xlim([0 log10(2000)])
ylabel('spikes/event');

subplot(413)
errorbar(FM2,VSm.M,VSm.sem);
set(gca,'Xtick',FMAxis);
xlim([0 log10(2000)])
ylabel('VS');

subplot(414)
errorbar(FM2,SynRm.M,SynRm.sem);
set(gca,'Xtick',FMAxis);
xlim([0 log10(2000)])
ylabel('SynR');
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [VS_M,VS_sem]=popustat(MTF,FMAxis,Nall)
% for FMindex = 1:18
%     VS=[];
%     i=1;
%     for n=1:Nall
%     if ~isempty(MTF.VS(n,FMindex))
%       VS(i) = MTF.VS(n,FMindex);
%       i = i+1;
%     end
%     end % end of n
%     
%     VS_M(FMindex) = mean(VS(find(VS>0)));
%     VS_sem(FMindex) = std(VS(find(~isnan(VS))))/sqrt(length(find(~isnan(VS)))); 
% end % end of FMindex
% 
% figure
% FM2 = log10(FMAxis);
% errorbar(FM2,VS_M,VS_sem);
% set(gca,'Xtick',FMAxis);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [Rab_M,r_M,r_sem,R,MI, Rabm]=popustat(MTFsh,FMAxis,Flag)
% 
% % Rab_M     : average Rab
% % r_M       : mean CC across all individual units
% % R         : CC for all units
% % MI        : modulation index
% % Rabm      : model to Rab_M
% L=10;  % samples per cycle
% for FMindex = 1:18
%  i=1; j=1;
%  Rab=[]
%  Rab_n=[]
%  r=[]
%  for n=1:size(MTFsh,1)
%    if ~isempty(MTFsh(n,FMindex).Rab)& ~isempty(MTFsh(n,FMindex).DC)
%     Rab(i,:)=real(sqrt(MTFsh(n,FMindex).Rab))
%     if std(Rab(i,:))==0
%         Rab_n(i,:)=Rab(i,:)-MTFsh(n,FMindex).DC
%     else
%         % Rab_n(i,:)=(Rab(i,:)-MTFsh(n,FMindex).DC)/std(Rab(i,:))
%         Rab_n(i,:)=Rab(i,:)/std(Rab(i,:))
%     end 
%     i=i+1;
%    end  % end of if ~isempty
%  end  % end of n
% 
%  Rab_M{FMindex}=mean(Rab,1)
%  Rab_Mn{FMindex}=mean(Rab_n,1)   % normorlized
%  
%  Fsd=min(FMAxis(FMindex)*L,12207);  % RASTER.Fs=12207
%  N=(length(Rab_M{FMindex})-1)/2;
%  Tau = (-N:N)/Fsd;
%  
%  if Flag==1 % PNB
% %  Rabmodel = zeros(1,length(Rab_M{FMindex}));
% %  Rabmodel(1,(length(Rab_M{FMindex})+1)/2)=max(Rab_M{FMindex});
% %  shift=0;
% %    while (length(Rab_M{FMindex})+1)/2 - shift>0
% %         Rabmodel(1,(length(Rab_M{FMindex})+1)/2-shift)=max(Rab_M{FMindex});
% %         Rabmodel(1,(length(Rab_M{FMindex})+1)/2+shift)=max(Rab_M{FMindex});
% %         shift=shift+round(Fsd/FMAxis(FMindex));
% %    end
% Rab_m = Rab_M{FMindex};
% ondiv = 0.00025./((1./FMAxis(FMindex))/L);  % stimulus(2.5ms) on divisions
%     if ondiv<1  % for FMAXis(k)<400 Hz in the case L=10
%     
%     Rabmodel = zeros(1,length(Rab_m));
%     Rabmodel(1,(length(Rab_m)+1)/2) = max(Rab_m);
%     shift=0;
%     while (length(Rab_m)-1)/2 - shift>=0
%         Rabmodel(1,(length(Rab_m)+1)/2-shift)=max(Rab_m);
%         Rabmodel(1,(length(Rab_m)+1)/2+shift)=max(Rab_m);
%         shift=shift+round(Fsd/FMAxis(FMindex));
%     end
%     
%     else  % for FAMsix(k)>400Hz in the case L=10
%     
%     Rabmodel = zeros(1,length(Rab_m));
%     Rabmodel(1,(length(Rab_m)+1)/2) = max(Rab_m);
%     Rabmodel(1,(length(Rab_m)+1)/2+1) = min(max(0,ondiv-1),1)*max(Rab_m);
%     Rabmodel(1,(length(Rab_m)+1)/2+L-1) = min(max(0,ondiv-2),1)*max(Rab_m);
%     Rabmodel(1,(length(Rab_m)+1)/2+2) = min(max(0,ondiv-3),1)*max(Rab_m);
%     Rabmodel(1,(length(Rab_m)+1)/2+L-2) = min(max(0,ondiv-4),1)*max(Rab_m);
%     shift=1:round(Fsd/FMAxis(FMindex));
%     while (length(Rab_m)-1)/2 - max(shift)>=0
%         Rabmodel(1,(length(Rab_m)+1)/2-length(shift)-1+shift)=Rabmodel(1,(length(Rab_m)+1)/2-1+shift);
%         Rabmodel(1,(length(Rab_m)+1)/2+length(shift)-1+shift)=Rabmodel(1,(length(Rab_m)+1)/2-1+shift);
%         shift = shift + round(Fsd/FMAxis(FMindex));
%     end
%     end % end of if ondiv 
% Rabmodel=Rabmodel((length(Rab_m)+1)/2-((length(Rab_m)-1)/2):(length(Rab_m)+1)/2+((length(Rab_m)-1)/2));
% Rabm{FMindex}=Rabmodel;
% 
%  else
%  beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2),[10 10],Tau,Rab_M{FMindex});
%  Rabmodel=beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2);
%  end
%  
%  
%  R_temp=corrcoef(Rabmodel,Rab_M{FMindex});
%  R(FMindex)=R_temp(1,2);
%  
%  % MI(FMindex) = beta(1)/beta(2);
%  MI(FMindex) = (max(Rab_M{FMindex})-min(Rab_M{FMindex}))/max(Rab_M{FMindex});
%  
%  beta_n = lsqcurvefit(@(beta_n,time) beta_n(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta_n(2),[10 10],Tau,Rab_Mn{FMindex});
%  Rabmodel_n = beta_n(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta_n(2);
%  R_tempn=corrcoef(Rabmodel,Rab_Mn{FMindex});
%  R_n(FMindex) = R_tempn(1,2);
%  MI_n(FMindex) = beta_n(1)/beta_n(2);
%  
%  for n=1:size(MTFsh,1)
%      if ~isempty(MTFsh(n,FMindex).r)
%      r(j)=MTFsh(n,FMindex).r;
%      j=j+1;
%      end
%  end
%  
%  r_M(FMindex) = mean(r(find(~isnan(r))));
%  r_sem(FMindex) = std(r(find(~isnan(r))))/sqrt(length(find(~isnan(r))))
%  
%  figure(1)
%  subplot(611)
%  
%  if Flag ==1 % PNB
%  plot(Tau,Rab_M{FMindex});
%  hold on;
%  plot(Tau,Rabm{FMindex},'r');
%  hold off
%  else
%  plot(Tau,Rab_M{FMindex});
%  hold on;
%  plot(Tau,beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2),'r');
%  hold off
%  end
%  
% %  subplot(122)
% %  % plot(Tau,real(sqrt(Rab_M{FMindex})))
% %  plot(Tau,Rab_Mn{FMindex});
% %  hold on;
% %  plot(Tau,beta_n(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta_n(2),'r')
% %  hold off
%  pause(1)
% end  % end of FMindex
%    
% figure(2)
% subplot(121)
% semilogx(FMAxis,R,'.-');
% title('Corr Coeff');
% subplot(122)
% % for normalized Rab
% semilogx(FMAxis, R_n,'.-');
% 
% figure(3)
% subplot(121)
% semilogx(FMAxis,MI,'.-');
% title('Mod Index');
% subplot(122)
% semilogx(FMAxis,MI_n,'.-');
% 
% figure(4)
% errorbar(FMAxis,r_M,r_sem)
% FM2 = log10(FMAxis);
% errorbar(FM2,r_M,r_sem);
% set(gca,'Xtick',FMAxis);

%%%%%%%%%%%%%%%%%%%%% CYCH %%%%%%%%%%%%%%%%
% function [CYCH_M,phase_M,phase_sem]=popustat(HIST,FMAxis,Nall)
% for FMindex = 1:14
%     CYCH=[];
%     i=1;j=1;
%     for n=1:Nall
%     if ~isempty(HIST{n})
%       CYCH(i,:)=HIST{n}(FMindex).hist;
%       % CYCH(i,:)=CYCH(i,:)/sum(CYCH(i,:));
%       i = i+1;
%     end
%     end % end of n
%     
%     CYCH_M{FMindex}=mean(CYCH,1)
%    L=25;
%    Fsd = FMAxis(FMindex)*L;
%    Tau = (0:L)/L/FMAxis(FMindex);
%    beta1 = lsqcurvefit(@(beta1,time) beta1(1)*cos(2*pi*FMAxis(FMindex)*Tau+beta1(2)),[10 10],Tau,CYCH_M{FMindex});
%    phase = beta1(2);
%    beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMindex)*Tau+ phase)+beta(2),[10 10],Tau,CYCH_M{FMindex});
%    bar(Tau,CYCH_M{FMindex});
%    hold on
%    plot(Tau,beta(1)*cos(2*pi*FMAxis(FMindex)*Tau+phase)+beta(2),'r')
%    hold off
%    pause(1)
%    
% %     for n=1:Nall
% %      if ~isempty(HIST(n,FMindex).phase)
% %      Phase(j)=HIST(n,FMindex).phase;
% %      j=j+1;
% %      end
% %     end
%  model = beta(1)*cos(2*pi*FMAxis(FMindex)*Tau+phase)+beta(2);
%  R_temp=corrcoef(model,CYCH_M{FMindex});
%  R(FMindex) = R_temp(1,2);
%  MI(FMindex) = beta(1)/beta(2);
%  
% phase_M(FMindex) = 0;
% phase_sem(FMindex) = 0;
% %  phase_M(FMindex) = mean(Phase(find(~isnan(Phase))));
% %  phase_sem(FMindex) = std(Phase(find(~isnan(Phase))))/sqrt(length(find(~isnan(Phase))))
% 
% end % end of FMindex
% 
% figure
% semilogx(FMAxis(1:FMindex),R,'.-')
% figure
% semilogx(FMAxis(1:FMindex),abs(MI),'.-')

%%%%%%%%%%%%%%%%%%%%% mean latency
% function [Lmean,Lsd]=popustat(RAS, FMAxis)
% i=1;j=1
% while i<=size(RAS,1)
%     ras=[]
%     ras=RAS(i,:)
%     if ~isempty([ras.spet])
%     [CYCH]= cychgen(ras,1,FMAxis,50,'duration',1,4,10);
%     [SpetMean,SpetSD,Lbound,Hbound]=meansdgen(ras,FMAxis,1,CYCH,zeros(1,18));
%     title(num2str(i))
%     Lmean(j,:)=SpetMean;
%     Lsd(j,:)=SpetSD;
%     close all;
%     end
%     i=i+1;j=j+1;
% end

% for i=1:length(FMAxis)
%     a=Lmean(:,i); b=Lsd(:,i);
%     m(i)=mean(a(find(~isnan(a))));
%     std(i)=mean(b(find(~isnan(b))));
% end
% figure
% FM2 = log10(FMAxis);
% errorbar(FM2,m,std);  
% set(gca,'Xtick',FMAxis);






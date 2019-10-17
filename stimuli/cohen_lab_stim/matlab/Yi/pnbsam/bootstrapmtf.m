% function [CC,MI]=bootstrapmtf(MTFsh,FMAxis,NB)

% DESCRIPTION: bootstrap Rab to compute the mean and standard error corr
% coeff and mod index

% MTFsh     : population shuff-corr
% FMAxis
% NB        : number of bootstraps

% CC        : corr coeff
%   .M      : mean of CC
%   .SE     : standard error of CC
% MI        : mod index
%   .M      : mean of MI
%   .SE     : standard error of SE

% Yi Zheng, March 2007

function [CC,MI]=bootstrapmtf(MTFsh,FMAxis,NB)

for FMindex = 1:length(FMAxis)
   
   % Generate population Rab matrix for one mod freq
   i=1; Rab=[];Rab1=[];
   for n=1:length(MTFsh)
    if ~isempty(MTFsh(n,FMindex).Rab)
     Rab(i,:)=real(sqrt(MTFsh(n,FMindex).Rab));
     
     bin = round(min(50,12207/FMAxis(FMindex)))
     center =(length(MTFsh(n,FMindex).Rab)+1)/2;
     Rab1(i,:) = MTFsh(n,FMindex).Rab((center-round(bin/2)):(center+round(bin/2)));
     Rab1(i,:)= real(sqrt(Rab1(i,:)));  % one cycle Rab
     
     i = i+1;
    end % end of if 
   end % end of n
 
   % Bootstrap Rab and compute CC & MI
   for l=1:NB
       j = randsample(size(Rab,1),size(Rab,1),'true');
       Rab_m = mean(Rab(j,:));
       Fsd = min(FMAxis(FMindex)*50,12207);
       N = (length(Rab_m)-1)/2;
       Tau = (-N:N)/Fsd;
       beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2),[10 10],Tau,Rab_m);
       Rabmodel = beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2);
       r = corrcoef(Rabmodel,Rab_m);
       CCboot(l,FMindex) = r(1,2);
       MIboot(l,FMindex) = beta(1)/beta(2);   
       
       Rab1_m = mean(Rab1(j,:));
       MIboot_t(l,FMindex) = (max(Rab1_m)-min(Rab1_m))/2/mean(Rab1_m); % MI from true Rab data
   end % end of NB 
   
   %Direct Estimates CC and MI
    Rab_m = mean(Rab);
	Fsd = min(FMAxis(FMindex)*50,12207);
	N = (length(Rab_m)-1)/2;
	Tau = (-N:N)/Fsd;
	beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2),[10 10],Tau,Rab_m);
	Rabmodel = beta(1)*cos(2*pi*FMAxis(FMindex)*Tau)+beta(2);
	r = corrcoef(Rabmodel,Rab_m);
	CCdirect(FMindex) = r(1,2);
	MIdirect(FMindex) = beta(1)/beta(2);  
    
    Rab1_m = mean(Rab);
    MIdirect_t(FMindex)=(max(Rab1_m)-min(Rab1_m))/2/mean(Rab1_m); % MI ture from Rab data
   
end  % end of FMindex

% Compute standard error of population CC and MI
CC.SE = std(CCboot,1);
MI.SE = std(MIboot,1);
CC.M = CCdirect;
MI.M = MIdirect;

MI.Mt = MIdirect_t;
MI.SEt = std(MIboot_t,1);

%Plotting Results  
FM2 = log10(FMAxis)
figure
subplot(211)
errorbar(FM2,CC.M,CC.SE);
set(gca,'Xtick',FMAxis);
axis([0 log10(2000) 0 1])
ylabel('CC');
subplot(212)
errorbar(FM2,MI.M,MI.SE);
hold on 

errorbar(FM2,MI.Mt,MI.SEt,'r');
set(gca,'Xtick',FMAxis);
axis([0 log10(2000) 0 1])
ylabel('MI');
     



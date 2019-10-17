% DESCRIPTION   : Generate reliability MTF according the auto- and
% cross-correlation method.

% Yi Zheng, Jan 2007.  Refer to jitterrastercorrfit.m

function [MTFreli,MTFj]=reliagen(RASTER,FMAxis,Fs,MaxTau)

%Number of Trials and Stimulus Conditions
N=length(FMAxis);           %Number of stimulus conditions
NTrial=length(RASTER)/N;    %Number of trials per stimulus

%Generating Jitter Correlation Functions at each FM
for k=1:length(FMAxis)
   
    %Determining Jitter Correlation, sigma,p, and lambda
    RAS=rasterexpand(RASTER((k-1)*NTrial+1:k*NTrial),Fs);
    [Tau,Raa,Rab,Rpp,Rmodel,sigmag,pg,lambdag,sigma,p,lambda]=jitterrastercorrfit(RAS,Fs,MaxTau,'y');
    MTFreli(k) = p;
    MTFj(k) =sigma;


%     taxis=(1:size(RAS,2)-1)/Fs;
%     RAS=full(RAS);
%     Rab=rastercorr(RAS,taxis,MaxTau,100,Fs);
%     Rab=mean(Rab);
%     Raa=rasterautocorr(RAS,taxis,MaxTau,100,Fs);
%     lambda=mean(mean(RAS));
%  
%     N=(length(Raa)-1)/2;
%     Raa(N+1)=0;
%     Rpp=abs(Rab-Raa);
%     Tau=(-N:N)/Fs;
%     Ncenter=(length(Rpp)-1)/2+1;
%     dN=min(max(find(Rpp>1/2*max(Rpp)))-Ncenter,floor((Ncenter-1)/6));   %Makes sure the 1/2 duration 
%                                                                         %does not exceed the number of samples
%     if dN==0    %In case jitter is too tight
%       dN=1; 
%     end
%     Rpp2=Rpp(Ncenter-dN*6:Ncenter+dN*6);    %Select segment 12 half heights wide relative to center
%     p=sum(Rpp2)/Fs/lambda;
end

figure
%subplot(211)
semilogx(FMAxis,MTFreli,'.b-');
title('Reliability MTF');
% subplot(212)
% semilogx(FMAxis,MTFj,'-b');
% title('Jitter MTF')



   
    

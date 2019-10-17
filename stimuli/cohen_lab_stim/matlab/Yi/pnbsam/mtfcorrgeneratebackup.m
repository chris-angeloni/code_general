%
% function [MTF] = mtfcorrgenerate(RASTER,FMAxis,L,NB)
%
%	FILE NAME 	: MTF GENERATE
%	DESCRIPTION : Generates a MTF on the TDT system
%
%   RASTER      : Rastergram array of data structure, spet format
%                 RASTER(k).spet - Spike event time array
%                 RASTER(k).Fs   - Sampling Frequency (Hz)
%                 RASTER(k).T    - Stimulus duration
%   Fsd         : Sampling rate for correlation analysis (Hz)
%   FMAxis      : Modulation Rate Axis Array (Hz)
%   L           : Number of samples used to compute the shuffled
%                 correlation per period of the modulation response
%   NB          : Number of boostraps
%   Flag        : 0:SAM; 1:PNB; 2:ONSET
%
% RETURNED DATA
%   MTF         : MTF Data Structure
%                 MTF.FMAxis    - Modulation Frequency Axis
%                 MTF.Rab       - shuffled correlation
%                 MTF.Rabmodel  - Fitted sinusoid model
%                 MTF.A         - Fitted peak-to-peak response amplitude
%                 MTF.DC        - Fitted DC response level
%                 MTF.Mean      - Measured mean response 
%                 MTF.Max       - Measured maximum response
%                 MTF.r         - Correlation coefficient between true
%                                 response and sinusoid model
%                 MTF.Aboot     - Bootstrapped A
%                 MTF.DCboot    - Bootstrapped DC
%                 MTF.Meanboot  - Bootstrapped Mean
%                 MTF.Maxboot   - Bootstrapped Max
%                 MTF.rboot     - Bootstrapped r
%
%   (C) Monty A. Escabi, February 2007
%
function [MTF] = mtfcorrgenerate(RASTER,Flag,FMAxis,L,NB)


%Number of Trials and Stimulus Conditions
NF=length(FMAxis);           %Number of stimulus conditions
NTrial=length(RASTER)/NF;    %Number of trials per stimulus

%Generating Jitter Correlation Functions at each FM
for k=1:NF
    Tau=[]; Rab_m=[];
    %Computing Shuffled Correlation
    if Flag==1
    % MaxTau=0.1*1000;
    MaxTau=1/2/FMAxis(k)*1000*4; 
    Fsd = 4000;
    else
    MaxTau=1/2/FMAxis(k)*1000*4; 
        % MaxTau = 100;
    Fsd=min(FMAxis(k)*L,RASTER(1).Fs);
    end
    % rasterexpand(), =0, one period as the maximum SPET (for cir-corr); =1, the true MaxSpet from spike
    RAS=rasterexpand(RASTER((k-1)*NTrial+1:k*NTrial),Fsd,1/FMAxis(k),1);
    taxis=(1:size(RAS,2)-1)/Fsd;
    [Rab]=rastercorr(RAS,taxis,MaxTau,NB,Fsd);
    MTF(k).FMAxis=FMAxis(k);
    MTF(k).Rab=mean(Rab);
    MTF(k).MI = (max(real(sqrt(MTF(k).Rab)))-min(real(sqrt(MTF(k).Rab))))/max(real(sqrt(MTF(k).Rab)));
    N=(length(mean(Rab))-1)/2;
    Tau=(-N:N)/Fsd;
   
    %Finding Optimal DC value and Peak to Peak Response Amplitude
    %Note that I am using sqrt of Rab as the response. Initial Inspeaction
    %Appears like the response is much more sinusoidal for sqrt(Rab). This
    %is expected because Rab squares the response (units of spikes^2 /
    %sec^2) so you need sqrt to get spikes/sec
    %
    if length(Rab)==0
        MTF(k).Rab=0
    else
    if size(Rab,1)==length(Tau)
        Rab=Rab';
    end
    
    for j=1:size(Rab,2)
        Rabj = Rab(:,j)
        Rab_m(j)=mean(Rabj(~isnan(Rabj)))
    end
    
    if Flag==1
    % for PNB (and ONSET), use impulse model to match shuf-corr
    Rabmodel = zeros(1,length(Rab_m));
    Rabmodel(1,(length(Rab_m)+1)/2)=max(real(sqrt(Rab_m)));
    shift=0;
    while (length(Rab_m)-1)/2 - shift>0
        Rabmodel(1,(length(Rab_m)+1)/2-shift)=max(real(sqrt(Rab_m)));
        Rabmodel(1,(length(Rab_m)+1)/2+shift)=max(real(sqrt(Rab_m)));
        shift=shift+round(Fsd/FMAxis(k));
    end
   
    MTF(k).Rabmodel=Rabmodel;
     % *************
    else
     % for SAM and SUSTAIN, use cosine model to match shuf-corr
    beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2),[10 10],Tau,real(sqrt(Rab_m)));
    MTF(k).Rabmodel=beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2);
    % beta = lsqcurvefit(@(beta,time)
    % beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2),[10 10],Tau,Rab_m);
    MTF(k).A=beta(1);
    MTF(k).DC=beta(2);
    end  % end of if
        
    %Adding Model Results
    
    MTF(k).Mean=mean(real(sqrt(mean(Rab))));
    MTF(k).Max=max(real(sqrt(mean(Rab))));
    
    %Correlation Coefficient
    r=corrcoef(MTF(k).Rabmodel,real(sqrt(mean(Rab))));
    MTF(k).r=r(1,2);
    
    plot(Tau,real(sqrt(Rab_m)));
    % plot(Tau,Rab_m);
    hold on
    plot(Tau,MTF(k).Rabmodel,'r')
    hold off
    pause(1)   
    %Bootstraping Optimization / Fitting 
    for l=1:NB
        
        %Bootstrap Resample
        i=randsample(size(Rab,1),size(Rab,1),'true');
        R=mean(Rab(i,:));
        Rshuf=real(sqrt(R));
        MTF(k).MIboot(l,1)=(max(Rshuf)-min(Rshuf))/max(Rshuf);
        %Finding Optimal DC value and Peak to Peak Response Amplitude
        %Note that I am using sqrt of Rab as the response. Initial Inspeaction
        %Appears like the response is much more sinusoidal for sqrt(Rab)
        beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2),[10 10],Tau,real(sqrt(R)));
        
        %Adding Model Results
        MTF(k).Aboot(l,1)=beta(1);
        MTF(k).DCboot(l,1)=beta(2);
        MTF(k).Meanboot(l,1)=mean(real(sqrt(R)));
        MTF(k).Maxboot(l,1)=max(real(sqrt(R)));
        Rabmodel=beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2);
    
        %Correlation Coefficient
        r=corrcoef(Rabmodel,real(sqrt(R)));
        MTF(k).rboot(l,1)=r(1,2);
        
    end  % end of NB
  end % end of if ength(Rab=0) 
end % end od NF


% else Flag==1  % PNB
%     Fsd=20000;
%     MaxTau = 2;
%     RAS=rasterexpand(RASTER((k-1)*NTrial+1:k*NTrial),Fsd);
%     taxis=(1:size(RAS,2)-1)/Fsd;
%     [Rab]=rastercorr(RAS,taxis,MaxTau,NB,Fsd);
%     MTF(k).FMAxis=FMAxis(k);
%     MTF(k).Rab=mean(Rab);
%     N=(length(Rab)-1)/2;
%     Tau=(-N:N)/Fsd;   
%     
%     W=window(Fsd,3,0.5,0.1);
%     M=round(Fsd/FMAxis(k));
%     X1=zeros(1,M);
%     X1(1:length(W))=W;
%     Env=[];
%     L = 2*MaxTau*FMAxis(k);
%     for k=1:L
% 	  Env=[Env X1];
%     end
%         
%     beta = lsqcurvefit(@(beta,time) beta(1)*Env+beta(2),[10 10],Tau,real(sqrt(mean(Rab))));
 
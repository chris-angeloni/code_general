%
% function [MTF] = mtfcorrgen4brkras(RASTER,Flag,FMAxis,L,NB,Nbrk,Norg)
%
%	FILE NAME 	: shuf-corr MTF for broken-raster
%	DESCRIPTION : 
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
%                 MTF.MI        - modulation index from real correlation
%                 MTF.Aboot     - Bootstrapped A
%                 MTF.DCboot    - Bootstrapped DC
%                 MTF.Meanboot  - Bootstrapped Mean
%                 MTF.Maxboot   - Bootstrapped Max
%                 MTF.rboot     - Bootstrapped r
%
%   Modified by Yi Zheng, July 2007
%
function [MTF] = mtfcorrgenbootC(RASTER,Flag,FMAxis,L,NB)

% 
% Flag      : 0:SAMN  1:PNB   2:onset or sus
% L         : Number of samples/cyc to compute the shuffled
% Nbrk       : (got from N2 in rasterbrk) # of broken trials for each given
% stimulus trial in orginal raster
% Norg      :  # of trials per condition in orginal raster (=10 for SAMN)

%Number of Trials and Stimulus Conditions
NF=length(FMAxis);           %Number of stimulus conditions 
Ntrial=size(RASTER,2)/NF;   % # of trials per stimulus condition

%Generating Jitter Correlation Functions at each FM
for k=1:NF
    clc
	disp(['Mod Freq: ' num2str(FMAxis(k))])
    Tau=[]; Rab_m=[];
    %Computing Shuffled Correlation
    
    % Fsd=min(FMAxis(k)*L,RASTER(1).Fs);  % sampling rate to compute raster-corr
    Fsd = FMAxis(k)*L;
    RASk = RASTER((Ntrial*k-99):(Ntrial*k));

    [Ravg,Rstd,R05,R01,Rab]=rastercircularxcorr2(RASk,Fsd,100);  % cxcorr algthim
    
    MTF(k).FMAxis = FMAxis(k);
    MTF(k).Raball = Rab;
    % N=(length(Rshuf)-1)/2;
    % Tau=(-N:N)/Fsd;
    N=(length(Ravg))/2;  % Modified by Yi Zheng, July 2007
    Tau=(-N:(N-1))/Fsd;
   
    %Finding Optimal DC value and Peak to Peak Response Amplitude
    %Note that I am using sqrt of Rab as the response. Initial Inspeaction
    %Appears like the response is much more sinusoidal for sqrt(Rab). This
    %is expected because Rab squares the response (units of spikes^2 /
    %sec^2) so you need sqrt to get spikes/sec
    
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
    
    MTF(k).Rab = Rab_m;
    MTF(k).MI = (max(real(sqrt(MTF(k).Rab)))-min(real(sqrt(MTF(k).Rab))))/max(real(sqrt(MTF(k).Rab)));
    
  if Flag==1
    % for PNB (and ONSET), use impulse model to match shuf-corr
    
    ondiv = 0.00025./((1./FMAxis(k))/L);  % stimulus(2.5ms) on divisions
    if ondiv<1  % for FMAXis(k)<400 Hz in the case L=10
    
    Rabmodel = zeros(1,length(Rshuf));
    Rabmodel(1,(length(Rshuf)+1)/2) = max(real(sqrt(Rshuf)));
    shift=0;
    while (length(Rshuf)-1)/2 - shift>=0
        Rabmodel(1,(length(Rshuf)+1)/2-shift)=max(real(sqrt(Rshuf)));
        Rabmodel(1,(length(Rshuf)+1)/2+shift)=max(real(sqrt(Rshuf)));
        shift=shift+round(Fsd/FMAxis(k));
    end
    
    else  % for FAMsix(k)>400Hz in the case L=10
    
    Rabmodel = zeros(1,length(Rshuf));
    Rabmodel(1,(length(Rshuf)+1)/2) = max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+1)/2+1) = min(max(0,ondiv-1),1)*max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+1)/2+L-1) = min(max(0,ondiv-2),1)*max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+1)/2+2) = min(max(0,ondiv-3),1)*max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+1)/2+L-2) = min(max(0,ondiv-4),1)*max(real(sqrt(Rshuf)));
    shift=1:round(Fsd/FMAxis(k));
    while (length(Rshuf)-1)/2 - max(shift)>=0
        Rabmodel(1,(length(Rshuf)+1)/2-length(shift)-1+shift)=Rabmodel(1,(length(Rshuf)+1)/2-1+shift);
        Rabmodel(1,(length(Rshuf)+1)/2+length(shift)-1+shift)=Rabmodel(1,(length(Rshuf)+1)/2-1+shift);
        shift = shift + round(Fsd/FMAxis(k));
    end
    end % end of if ondiv    
    MTF(k).Rabmodel=Rabmodel((length(Rshuf)+1)/2-((length(Rshuf)-1)/2):(length(Rshuf)+1)/2+((length(Rshuf)-1)/2));
   
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

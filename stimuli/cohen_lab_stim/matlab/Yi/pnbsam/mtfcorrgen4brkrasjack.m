%
% function [MTF] = mtfcorrgen4brkrasjack(RASTER,Flag,FMAxis,L,Nbrk,Norg)
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
% Flag      : 0:SAMN  1:PNB   2:onset or sus
% L         : Number of samples/cyc to compute the shuffled
% Nbrk       : (got from N2 in rasterbrk) # of broken trials for each given
% stimulus trial in orginal raster
% Norg      :  # of trials per condition in orginal raster (=10 for SAMN)
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
function [MTF] = mtfcorrgen4brkrasjack(RASTER,Flag,FMAxis,L,Nbrk,Norg)

%Number of Trials and Stimulus Conditions
NF=length(FMAxis);           %Number of stimulus conditions 
Ntrial=Nbrk*Norg;   % # of trials per stimulus condition

%Generating Jitter Correlation Functions at each FM
for k=1:NF
    clc
	disp(['Mod Freq: ' num2str(FMAxis(k))])
    Tau=[]; Rab_m=[];
    %Computing Shuffled Correlation
    % Fsd=min(FMAxis(k)*L,RASTER(1).Fs);  % sampling rate to compute raster-corr
    Fsd = FMAxis(k)*L;
    
    if k==1
       RASk = RASTER(1:Ntrial(k));
    else
       RASk = RASTER(sum(Ntrial(1:(k-1))) + (1:Ntrial(k)));
    end
MTF(k).FMAxis = FMAxis(k);
%     if Ntrial(k)<1000
%       m=1; NJshuf=Ntrial(k);
%     else
%       m=10; NJshuf=Ntrial(k)/10;
%     end
    % NJshuf = min(1000,Ntrial(k)*(Ntrial(k)-1)/2);
    %[Rshuf,Rse,RshufJ]=rastercircularxcorrfast(RASk,Fsd,'y',NJshuf);
    %[Rshuf,Rse,RshufJ]=rastercircularxcorrfast2(RASk,Fsd,'y',NJshuf,m);
    [R]=rastercircularxcorrfast(RASk,Fsd,'y',1000);
    Rshuf = R.Rshuf;
    % Rshuf = R.Rshuf(1:40);
%    RshufJ = R.RshufJc;
%    Rse= R.Rsec;
    MTF(k).R = R;
    
    % N=(length(Rshuf)-1)/2;
    % Tau=(-N:N)/Fsd;
    N=(length(Rshuf))/2;  % Modified by Yi Zheng, July 2007
    Tau=(-N:(N-1))/Fsd;
   
    %Finding Optimal DC value and Peak to Peak Response Amplitude
    %Note that I am using sqrt of Rab as the response. Initial Inspeaction
    %Appears like the response is much more sinusoidal for sqrt(Rab). This
    %is expected because Rab squares the response (units of spikes^2 /
    %sec^2) so you need sqrt to get spikes/sec
    
    MTF(k).Rab = Rshuf;
    MTF(k).MI = (max(real(sqrt(MTF(k).Rab)))-min(real(sqrt(MTF(k).Rab))))/max(real(sqrt(MTF(k).Rab)));
    
  if Flag==1
    % for PNB (and ONSET), use impulse model to match shuf-corr
    
    ondiv = 0.00025./((1./FMAxis(k))/L);  % stimulus(2.5ms) on divisions
    if ondiv<1  % for FMAXis(k)<400 Hz in the case L=10
    
    Rabmodel = zeros(1,length(Rshuf));
    Rabmodel(1,(length(Rshuf)+2)/2) = max(real(sqrt(Rshuf)));
    shift=0;
    while length(Rshuf)/2 - shift>=0
        Rabmodel(1,(length(Rshuf)+2)/2-shift)=max(real(sqrt(Rshuf)));
        Rabmodel(1,(length(Rshuf)+2)/2+shift)=max(real(sqrt(Rshuf)));
        shift=shift+round(Fsd/FMAxis(k));
    end
    
    else  % for FAMsix(k)>400Hz in the case L=10
    
    Rabmodel = zeros(1,length(Rshuf));
    Rabmodel(1,(length(Rshuf)+2)/2) = max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+2)/2+1) = min(max(0,ondiv-1),1)*max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+2)/2+L-1) = min(max(0,ondiv-2),1)*max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+2)/2+2) = min(max(0,ondiv-3),1)*max(real(sqrt(Rshuf)));
    Rabmodel(1,(length(Rshuf)+2)/2+L-2) = min(max(0,ondiv-4),1)*max(real(sqrt(Rshuf)));
    LL = round(Fsd/FMAxis(k));
    shift=1:LL;
%     while (length(Rshuf)+2)/2 - max(shift)>=0
%         Rabmodel(1,(length(Rshuf)+2)/2-max(shift)-1+shift)=Rabmodel(1,(length(Rshuf)+2)/2-1+shift);
%         Rabmodel(1,(length(Rshuf)+2)/2+max(shift)-1+shift)=Rabmodel(1,(length(Rshuf)+2)/2-1+shift);
%         shift = shift + round(Fsd/FMAxis(k));
%     end
   for step=1:2
        Rabmodel(1,(length(Rshuf)+2)/2+LL*step-1+shift)=Rabmodel(1,(length(Rshuf)+2)/2-1+shift);
        Rabmodel(1,(length(Rshuf)+2)/2-LL*step-1+shift)=Rabmodel(1,(length(Rshuf)+2)/2-1+shift);
   end


    end % end of if ondiv    
    % MTF(k).Rabmodel=Rabmodel((length(Rshuf)+2)/2-(length(Rshuf)/2):(length(Rshuf)+2)/2+(length(Rshuf)/2))
    MTF(k).Rabmodel=Rabmodel(1:length(Rshuf));
    % MTF(k).Rabmodel(1)=Rabmodel(length(Rshuf)/2);
     % *************
    else
     % for SAM and SUSTAIN, use cosine model to match shuf-corr
    [beta,resnorm] = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2),[10 10],Tau,real(sqrt(Rshuf)));
    MTF(k).Rabmodel=beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2);
    % beta = lsqcurvefit(@(beta,time)
    % beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2),[10 10],Tau,Rshuf);
    MTF(k).A=beta(1);
    MTF(k).DC=beta(2);
    end  % end of if
        
    %Adding Model Results
    
    MTF(k).Mean=mean(real(sqrt(mean(Rshuf))));
    MTF(k).Max=max(real(sqrt(mean(Rshuf))));
    
    %Correlation Coefficient
    r=corrcoef(MTF(k).Rabmodel,real(sqrt(Rshuf)));
    MTF(k).r=r(1,2);
    
    plot(Tau,real(sqrt(Rshuf)));
    % plot(Tau,Rshuf);
    hold on
    plot(Tau,MTF(k).Rabmodel,'r')
    hold off
    pause(1)   
    
%     %Jackknife MI, EI etc. 
%     for l=1:size(RshufJ,1)
%         R=real(sqrt(RshufJ(l,:)));
%         MTF(k).MIjack(l,1)=(max(R)-min(R))/max(R);
%         beta = lsqcurvefit(@(beta,time) beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2),[10 10],Tau,real(sqrt(R)));
%         MTF(k).Ajack(l,1)=beta(1);
%         MTF(k).DCjack(l,1)=beta(2);
%         MTF(k).Meanjack(l,1)=mean(real(sqrt(R)));
%         MTF(k).Maxjack(l,1)=max(real(sqrt(R)));
%         Rabmodel=beta(1)*cos(2*pi*FMAxis(k)*Tau)+beta(2);
%     
%         %Correlation Coefficient
%         r=corrcoef(Rabmodel,real(sqrt(R)));
%         MTF(k).rjack(l,1)=r(1,2);
%         
%     end  % end of l
    
end % end od NF



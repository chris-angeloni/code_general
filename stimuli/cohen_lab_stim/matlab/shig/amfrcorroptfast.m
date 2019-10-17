%
%function [AMFR]=amfrcorroptfast(X,Fs,Fm,L,alpha,M)
%
%	FILE NAME   : AMFR CORR OPT FAST
%	DESCRIPTION : Auditory modulation following response shuffled
%                 correlation. Optimally selects response segments to
%                 maximize measured correlation.
%
%   X           : Rcorded EEG signal
%   Fs          : Sampling rate (Hz)
%   Fm          : Modulation Rate (Hz)
%   L           : Number of periods per shuffling block
%   alpha       : Correlation coefficient tolerance. 
%                 Optimization requires that 
%                 r[k]-r[k-1]>alpha
%   M           : Samples in past to look at corrcoef to meet tolerance
%                 requirement
%
%RETURNED VARIABLES
%
%   AMFR        : AMFR Data Structure
%                 .R        : Shuffled Correlation
%                 .Tau      : Delay (msec)
%                 .Rmodel   : Cosine model correlation
%                 .A        : Cosine model amplitude
%                 .Res      : Model residuals
%                 .SNR      : Signal to noise ratio
%
% (C) Monty A. Escabi, May 2007
%
function [AMFR]=amfrcorroptfast(X,Fs,Fm,L,alpha,M)

%Reshaping data into N period trials segments
N=Fs/Fm*L;                          %Samples per block
Nblocks=floor(length(X)/N);         %Number of blocks
X=reshape(X(1:N*Nblocks),N,Nblocks);

%Computing Shuffled Corelation
countOpt=1;
Ropt=zeros(1,N);
RTrial=zeros(1,N);
Tau=((0:size(X,1)-1)-size(X,1)/2)/Fs;
kopt=1:10;
ropt=-1*ones(1,M);
SNRopt=-100*ones(1,M);
for k=2:size(X,2)
    
    RTrial=zeros(1,N);
    countTrial=0;
    for l=1:min(length(kopt),k)-1
        %Correalation Function for each trial
        RTrial=[RTrial + real(ifft(fft(X(:,k)).*conj(fft(X(:,kopt(l))))))'];
        countTrial=countTrial+1;
    end
    
    %Average Correlation including k Trials
    Ravg(k,:)=(Ropt+RTrial);
    Rtemp=Ravg(k,:)/(countOpt+countTrial);
    
    %Fitting Ravg to Cosine Correlation Model and finding residuals
    [AA(k),ResNorm,Res]=lsqcurvefit(@(A,Tau) A.^2/2*cos(2*pi*Fm*Tau),sqrt(max(Rtemp)*2),Tau,Rtemp);
    
    %Computing SNR
    SNR(k)=20*log10(norm(AA(k).^2/2*cos(2*pi*Fm*Tau))/norm(Res));
    rr=corrcoef(AA(k).^2/2*cos(2*pi*Fm*Tau),Rtemp);
    r(k)=rr(1,2);
    
    %Determining whether to keep block
    %r(k)-ropt(k-1)
    %mean(r(max(k-M-1,1):k))-mean(ropt(max(k-M-2,1):max(k-1,1)))
    %mean(r(max(k-M-1,1):k))-ropt(k-1)
    if mean(r(max(k-M-1,1):k))-mean(ropt(max(k-M-2,1):max(k-1,1)))>alpha
        Ropt=Ropt+RTrial;
        kopt=[kopt k];
        ropt(k)=r(k);
        SNRopt(k)=SNR(k);
        countOpt=countOpt+countTrial;
    else
        ropt(k)=ropt(k-1);
        SNRopt(k)=SNRopt(k-1);
        Ravg(k,:)=Ravg(k-1,:);
    end
    
    if 1
        %Plotting Data and Model
        subplot(311)
        plot(Tau*1000,AA(k).^2/2*cos(2*pi*Fm*Tau),'r')
        hold on
        plot(Tau*1000,Ropt/countOpt)
        hold off
        xlabel('Delay (msec)')
        
        subplot(312)
        plot((1:length(SNR))*L/Fm,SNR)
        hold on
        plot((1:length(SNRopt))*L/Fm,SNRopt,'r')
        hold off
        axis([0 size(X,2)*L/Fm -5 50])
        xlabel('Time (sec)')
        ylabel('SNR (dB)')
        
        subplot(313)
        plot((1:length(r))*L/Fm,r)
        hold on
        plot((1:length(ropt))*L/Fm,ropt,'r')
        hold off
        axis([0 size(X,2)*L/Fm 0 1.2])
        xlabel('Time (sec)')
        ylabel('Correlation Coefficient')
        pause(0)
    end
    
    %Display Status 
    clc
    disp(['Correlating Trial ' int2str(k) ' of ' int2str(size(X,2))])
    
end

%Appending Data to AMFR Structure
AMFR.Ropt=Ropt/countOpt;
AMFR.Ravg=Ravg;
AMFR.Tau=Tau*1000;
AMFR.X=X;
AMFR.r=r;
AMFR.ropt=ropt;
AMFR.kopt=kopt;
AMFR.SNR=SNR;

%Fitting Cosine Model to Correaltion
[A]=lsqcurvefit(@(A,Tau) A.^2/2*cos(2*pi*Fm*Tau),sqrt(max(AMFR.Ropt)*2),Tau,AMFR.Ropt);
AMFR.Rmodel=A^2/2*cos(2*pi*Fm*Tau);

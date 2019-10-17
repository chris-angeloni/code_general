%
%function [AMFR]=amfrcorr(X,Fs,Fm,L)
%
%	FILE NAME   : AMFR CORR
%	DESCRIPTION : Auditory modulation following response shuffled
%                 correlation.
%
%   X           : Rcorded EEG signal
%   Fs          : Sampling rate (Hz)
%   Fm          : Modulation Rate (Hz)
%   L           : Number of periods per shuffling block
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
function [AMFR]=amfrcorr(X,Fs,Fm,L)

%Reshaping data into N period trials segments
N=Fs/Fm*L;                          %Samples per block
Nblocks=floor(length(X)/N);         %Number of blocks
X=reshape(X(1:N*Nblocks),N,Nblocks);

%Computing Shuffled Corelation
count=1;
R=zeros(1,N);
Tau=((0:size(X,1)-1)-size(X,1)/2)/Fs;
for k=2:size(X,2)
    
    for l=1:k-1
        %Correalation Function for each trial
        R=[R + real(ifft(fft(X(:,k)).*conj(fft(X(:,l)))))'];
        count=count+1;
    end
    
    %Average Correlation including k Trials
    Ravg(k,:)=R/count;
    
    %Fitting Ravg to Cosine Correlation Model and finding residuals
    [AA(k),ResNorm,Res]=lsqcurvefit(@(A,Tau) A.^2/2*cos(2*pi*Fm*Tau),sqrt(max(Ravg(k,:))*2),Tau,Ravg(k,:));
    
    %Computing SNR
    SNR(k)=20*log10(norm(AA(k).^2/2*cos(2*pi*Fm*Tau))/norm(Res));
    rr=corrcoef(AA(k).^2/2*cos(2*pi*Fm*Tau),Ravg(k,:));
    r(k)=rr(1,2);
    
    %Plotting Data and Model
    subplot(311)
    plot(Tau*1000,AA(k).^2/2*cos(2*pi*Fm*Tau),'r')
    hold on
    plot(Tau*1000,Ravg(k,:))
    hold off
    xlabel('Delay (msec)')
    subplot(312)
    plot(1:length(SNR),SNR)
    axis([0 size(X,2) -5 25])
    xlabel('Trial Number')
    ylabel('SNR (dB)')
    subplot(313)
    plot(1:length(r),r)
    axis([0 size(X,2) 0 1])
    xlabel('Trial Number')
    ylabel('Correlation Coefficient')
    pause(0)
    
    %Display Status 
    clc
    disp(['Correlating Trial ' int2str(k) ' of ' int2str(size(X,2))])
    
end

%Appending Data to AMFR Structure
AMFR.R=R/count;
AMFR.Ravg=Ravg;
AMFR.Tau=Tau*1000;
AMFR.X=X;
AMFR.r=r;

%Fitting Cosine Model to Correaltion
[A]=lsqcurvefit(@(A,Tau) A.^2/2*cos(2*pi*Fm*Tau),sqrt(max(AMFR.R)*2),Tau,AMFR.R);
AMFR.Rmodel=A^2/2*cos(2*pi*Fm*Tau);

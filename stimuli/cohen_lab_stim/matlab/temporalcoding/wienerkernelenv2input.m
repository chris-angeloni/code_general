%
%function [Wkernel]=wienerkernelenv2input(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp)
%
%       FILE NAME       : WIENER KERNEL ENV 2 INPUT
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. This is 
%                         done for each of the inputs. Next, the nonlinaer
%                         interaction kernel between the two inputs is
%                         computed. 
%
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994. Details for
%                         the second order interaction kernels are found in
%                         Marmarelis & Naka
%
%       RASData         : Data structure containing the estimation and
%                         prediciton responses. Organized as follows:
%
%           .Est        : Estimation Rastergram
%           .spet       : Spike event times for each trial. Different sound
%                         segments are repeated L times (in sample number).
%           .T          : Trial duration
%           .Fs         : Samping rate (Hz)
%
%           .Pre        : Prediction Rastergram
%           .spet       : Spike event times (sample number).
%           .T          : Trial duration.
%           .Fs         : Sampling rate (Hz)
%       SoundEstEnv    : Sound envelopes for estimating wiener kernels.
%                         Contains the envelopes for both input channels (1
%                         and 2). Each envelope is repeated L times.
%       SoundParam      : Data structure containing sound parameters
%       T1              : Minimum negative delay used for estimating 
%                         kernels (msec). T1>0 but negative sign is added
%                         in program.
%       T2              : Maximum delay used for estimating kernels (msec)
%       DF              : Downsampling factor for envelope
%       Disp            : Displaying output ('y' or 'n', Default=='n')
%
%       Wkernel         : Structure containing 1st and 2nd order kernels
%
%                         .N        - number of spikes
%                         .k0       - zeroth order kernel (spike rate)
%                         .Varxx1   - Channel 1 input variance
%                         .Varxx2   - Channel 2 input variance
%                         .k1_1     - first order kernel on channel 1
%                         .k1_1ste  - Standard error on k1_1
%                         .k1_2     - first order kernel on channel 1
%                         .k1_2ste  - Standard error on k1_2
%                         .Rx1x2    - Envelope 1 & 2 crosscovariance
%                         .Ryx1x2   - Spike triggered envelope 1 & 2
%                                     crosscovariance
%                         .k2_12    - second order interaction kernel 
%                         .PEE1     - Channel 1 pre event envelope
%                         .PEE2     - Channel 2 pre event envelope
%                         .T        - Time delay vecotr 
%                         .T1       - Time delay vecotr channel 1
%                         .T2       - Time delay vecotr channel 2
%                         .Y1spike  - Spike triggered channel 1 output. 
%                                     Used to construct output nonlinearity. 
%                         .Y2spike  - Spike triggered channel 2 output.
%                                     Used to construct output nonlinearity.
%                         .Y1prior  - Prior first channel 1. Used to
%                                     construct output nonlinearity (F). 
%                         .Y2prior  - Prior second channel 2. Used to
%                                     construct output nonlinearity (F).
%                         .F        - Channel 1 & 2 mixing/output nonlinearity
%                         .F1       - Channel 1 nonlinearity
%                         .F2       - Channel 2 nonlinearity
%                         .y1       - Y1 axis for F
%                         .y2       - Y2 axis for F
%
%   (C) Monty A. Escabi, Jan 2010 (Edit Nov 2011)
%
function [Wkernel]=wienerkernelenv2input(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp)

%Input Arguments
if nargin<7
    Disp='n';
end

%Stored Enevelope Sampling rate
Fs=SoundParam.Fs/SoundParam.DS;

%Temporal Lag (number of samples)
N1=ceil(T1/1000*Fs/DF);
N2=ceil(T2/1000*Fs/DF);
Fsd=Fs/DF;

%Extracting Pre-event envelopes
L=length(RASData.Est);
NN=0;
Ttotal=0;
for k=1:L

    %Sound Envelope in dB
    X1=20*log10(SoundEstEnv(ceil(k/2)).Env1)+15;
    i=find(X1<-15);
    X1(i)=zeros(size(i));
    X1=X1(1:DF:end);
    X2=20*log10(SoundEstEnv(ceil(k/2)).Env2)+15;
    i=find(X2<-15);
    X2(i)=zeros(size(i));
    X2=X2(1:DF:end);
    
    %Selecting spikes so that pre-event stimuli do not exceed sound
    %duration and resampling to desired sampling rate
    spet=round(RASData.Est(k).spet/RASData.Est(k).Fs*Fs/DF);
    i=find(spet-N2>0 & spet+N1<length(X1));
    spet=spet(i);

    %Finding Waveforms prior to spike (pre-event envelope) for channel 1 and 2
    STAEnv(k).Env1=zeros(length(spet),N2+N1+1);  %Initializing pre-event envelope matrix
    STAEnv(k).Env2=zeros(length(spet),N2+N1+1);  %Initializing pre-event envelope matrix
    for l=1:length(spet)
        STAEnv(k).Env1(l,:)=X1(spet(l)-N2:spet(l)+N1);
        STAEnv(k).Env2(l,:)=X2(spet(l)-N2:spet(l)+N1);
    end
    
    %Number of spikes and total durtion
    NN=NN+length(spet);
    Ttotal=Ttotal+length(X1)/Fsd;
end

%Computing spike rate
lambda=NN/Ttotal;

%Organizing envelopes in Semi Toeplitz form. Used to compute sound covariance
XEnv1=[];
XEnv2=[];
for k=1:L
 
    %Sound Envelope in dB
    X1=20*log10(SoundEstEnv(ceil(k/2)).Env1)+15;
    i=find(X1<-15);
    X1(i)=zeros(size(i));
    X1=X1(1:DF:end);
    X2=20*log10(SoundEstEnv(ceil(k/2)).Env2)+15;
    i=find(X2<-15);
    X2(i)=zeros(size(i));
    X2=X2(1:DF:end);
    
    %Organizing sound in topelitz form
    N=floor(length(X1)/size(STAEnv(k).Env1,2));
    XEnv1=[XEnv1; reshape(X1(1:size(STAEnv(k).Env1,2)*N),size(STAEnv(k).Env1,2),N)'];    %Toeplitz form. Used to compute sound covariance
    XEnv2=[XEnv2; reshape(X2(1:size(STAEnv(k).Env2,2)*N),size(STAEnv(k).Env2,2),N)'];    %Toeplitz form. Used to compute sound covariance
    
end
Varxx1=var(reshape(XEnv1,1,numel(XEnv1)));
Varxx2=var(reshape(XEnv2,1,numel(XEnv2)));

%Computing Wiener kernels and adding results to data structure
PEE1=[];                                     %Pre-event envelope
PEE2=[];                                     %Pre-event envelope
for k=1:L
    PEE1=[PEE1;  (STAEnv(k).Env1)];          %Pre-event envelopes
    PEE2=[PEE2;  (STAEnv(k).Env2)];          %Pre-event envelopes
end
Wkernel.N=NN;                                %Total number of spikes
Wkernel.k0=lambda;                           %Zeroth order kernel (i.e., spike rate)
Wkernel.Varxx1=Varxx1;                       %Sound variance
Wkernel.Varxx2=Varxx2;                       %Sound variance

Wkernel.k1_1=lambda*fliplr(mean(PEE1))/Varxx1;  %First order Wiener kernel channel 1
k1_1b= lambda*bootstrp(100,'mean',PEE1)/Varxx1; %Bootstrap to compute standard error
Wkernel.k1_1ste=std(fliplr(k1_1b));             %Standard error
Wkernel.k1_2=lambda*fliplr(mean(PEE2))/Varxx2;  %First order Wiener kernel channel 2
k1_2b= lambda*bootstrp(100,'mean',PEE2)/Varxx2; %Bootstrap to compute standard error
Wkernel.k1_2ste=std(fliplr(k1_2b));             %Standard error

%Sound Cross Covariance
[m]=size(XEnv1,1)
Wkernel.Rx1x2=fliplr(flipud(XEnv1'*XEnv2/(m-1)));     %Sound cross covariance
 
%Spike Triggered Covariance
[m]=size(PEE1,1)
Wkernel.Ryx1x2=fliplr(flipud(PEE1'*PEE2/(m-1)));   %Second order REVCORR

%Second Order Interaction Kernel
Wkernel.k2_12=2*lambda/Varxx1^2*(Wkernel.Ryx1x2-Wkernel.Rx1x2);      %Second order interaction Wiener kernel
Wkernel.PEE1=PEE1;                            %Pre-event envelopes
Wkernel.PEE2=PEE2;                            %Pre-event envelopes

%Time delays
Wkernel.T=(-N1:N2)/Fsd*1000;                %Delay
Wkernel.T1=(-N1:N2)/Fsd*1000;               %Delay 1
Wkernel.T2=(-N1:N2)/Fsd*1000;               %Delay 2

%Estimating Output Nonlinearity by combining linear kernels
dt=1/(SoundParam.Fs/DF/SoundParam.DS);
Y1spike=[];
Y2spike=[];
Y1prior=[];
Y2prior=[];
for k=1:L
    
    %Spike event times using Fsd
    spet=round(RASData.Est(k).spet/RASData.Est(k).Fs*Fs/DF);
    i=find(spet-N2>0 & spet+N1<length(X1));
    spet=spet(i);
    
    %Sound in dB using Fsd
    X1=20*log10(SoundEstEnv(ceil(k/2)).Env1)+15;
    i=find(X1<-15);
    X1(i)=zeros(size(i));
    X1=X1(1:DF:end);
    X2=20*log10(SoundEstEnv(ceil(k/2)).Env2)+15;
    i=find(X2<-15);
    X2(i)=zeros(size(i));
    X2=X2(1:DF:end);
        
    %Predicting Output
    Y1=conv(Wkernel.k1_1,X1);
    Y2=conv(Wkernel.k1_2,X2);
    
    %Spike triggered and prior outputs
    Y1spike=[Y1spike Y1(spet)];
    Y2spike=[Y2spike Y2(spet)];
    Y1prior=[Y1prior Y1];
    Y2prior=[Y2prior Y2];
    
end
Wkernel.Y1spike=Y1spike;
Wkernel.Y2spike=Y2spike;
Wkernel.Y1prior=Y1prior;
Wkernel.Y2prior=Y2prior;
[y1,y2,Nprior]=hist2(Wkernel.Y1prior,Wkernel.Y2prior,20,20,'n');
[y1,y2,N]=hist2(Wkernel.Y1spike,Wkernel.Y2spike,y1,y2,'n');
Wkernel.F=Wkernel.k0*(N/sum(sum(N)))./(Nprior/sum(sum(Nprior)));
[Nprior,y1]=hist(Wkernel.Y1prior,y1);
[N,y1]=hist(Wkernel.Y1spike,y1);
Wkernel.F1=Wkernel.k0*(N/sum(N))./(Nprior/sum(Nprior));
[yNprior,y2]=hist(Wkernel.Y2prior,y2);
[N,y2]=hist(Wkernel.Y2spike,y2);
Wkernel.F2=Wkernel.k0*(N/sum(N))./(Nprior/sum(Nprior));
Wkernel.y1=y1;
Wkernel.y2=y2;
Wkernel.Fs=SoundParam.Fs;
Wkernel.DS=SoundParam.DS;
Wkernel.DF=DF;

%Displaying if desired
if strcmp(Disp,'y') 
    subplot(221)
    plot(Wkernel.T1,Wkernel.k1_1,'k')
    xlim([-T1 T2])
    xlabel('Delay (msec)')
    
    subplot(222)
    plot(Wkernel.T1,Wkernel.k1_2,'k')
    xlim([-T1 T2])
    xlabel('Delay (msec)')

    subplot(223)
    imagesc(Wkernel.T1,Wkernel.T2,Wkernel.k2_12),colorbar
    axis([-T1 T2 -T1 T2])
    xlabel('Delay1 (msec)')
    ylabel('Delay2 (msec)')
end
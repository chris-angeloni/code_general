%
%function [Wkernel]=wienerkernelenv(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp)
%
%       FILE NAME       : WIENER KERNEL ENV
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994
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
%       SoundEstEnv     : Sound envelopes for estimating wiener kernels.
%                         Each envelope is repeated L times.
%       SoundParam      : Data structure containing sound parameters
%       T1              : Minimum negative delay used for estimating 
%                         kernels (msec). T1>0 but negative sign is added
%                         in program.
%       T2              : Maximum delay used for estimating kernels (msec)
%       DF              : Downsampling factor for envelope
%       Disp            : Displaying output ('y' or 'n', Default=='n')
%
%RETURNED VARIABLES
%
%       Wkernel         : Structure containing 1st and 2nd order kernels
%
%                         .N        - number of spikes
%                         .k0       - zeroth order kernel (spike rate)
%                         .Varxx    - input variance
%                         .k1       - first order kernel
%                         .k1ste    - standard error on k1
%                         .k2       - second order kernel
%                         .PEE      - Pre event envelope
%                         .k2_1     - First singular vector on k2
%                         .k2_2     - Second singular vector on k2
%                         .lambda2_1- First singular value on k2
%                         .lambda2_2- Second singular value on k2
%                         .k2U      - U vector from SVD decomposition on k2
%                         .k2V      - V vector from SVD decomposition on k2
%                         .k2S      - S vector from SVD decomposition on k2
%                         .T1       - Time delay vecotr
%                         .T2       - Time delay vecotr
%                         .Y1spike  - Spike triggered first order output. 
%                                     Used to construct output
%                                     nonlinearity. 
%                         .Y2spike  - Spike triggered second order output. Used to
%                                     construct output nonlinearity.
%                         .Y1prior  - Prior first order output. Used to
%                                     construct output nonlinearity (F). 
%                         .Y2prior  - Prior second order output. Used to
%                                     construct output nonlinearity (F).
%                         .F        - 2-D nonlinearity
%                         .y1       - Y1 axis for F
%                         .y2       - Y2 axis for F
%          
%   (C) Monty A. Escabi, Jan 2011
%
function [Wkernel]=wienerkernelenv(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp)

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
    X=20*log10(SoundEstEnv(ceil(k/2)).Env)+15;
    i=find(X<-15);
    X(i)=zeros(size(i));
    X=X(1:DF:end);

    %Selecting spikes so that pre-event stimuli do not exceed sound
    %duration and resampling to desired sampling rate
    spet=round(RASData.Est(k).spet/RASData.Est(k).Fs*Fs/DF);
    i=find(spet-N2>0 & spet+N1<length(X));
    spet=spet(i);
    
    %Finding Waveforms prior to spike (pre-event envelope)
    STAEnv(k).Env=zeros(length(spet),N2+N1+1);  %Initializing pre-event envelope matrix
    for l=1:length(spet)
        STAEnv(k).Env(l,:)=X(spet(l)-N2:spet(l)+N1);
    end
    
    %Number of spikes and total durtion
    NN=NN+length(spet);
    Ttotal=Ttotal+length(X)/Fsd;
end

%Computing spike rate
lambda=NN/Ttotal;

%Organizing envelopes in Toeplitz form. Used to compute sound covariance
XEnv=[];
for k=1:L
 
    %Sound Envelope in dB
    X=20*log10(SoundEstEnv(ceil(k/2)).Env)+15;
    i=find(X<-15);
    X(i)=zeros(size(i));
    X=X(1:DF:end);

    %Organizing sound in topelitz form
    N=floor(length(X)/size(STAEnv(k).Env,2));
    XEnv=[XEnv; reshape(X(1:size(STAEnv(k).Env,2)*N),size(STAEnv(k).Env,2),N)'];    %Toeplitz form. Used to compute sound covariance
end
Varxx=var(reshape(XEnv,1,numel(XEnv)));

% %Fast estimate of sound covariance
% Rxx2=zeros(1,2*(N2+1)+1);
% for k=1:L
% 
%     %Sound Envelope in dB
%     X=20*log10(SoundEstEnv(ceil(k/2)).Env)+15;
%     i=find(X<-15);
%     X(i)=zeros(size(i));
%     X=X(1:DF:end);
% 
%     %Mean sound autocorrelation
%     Rxx2=Rxx2+xcorr(X,X,N2+1)/(length(X)-1)/L;
%     
% end
% Rxx2=convmtx(Rxx2,N2+1);
% Rxx2=Rxx2(:,N2+1:2*N2+1);

%Computing Wiener kernels and adding results to data structure
PEE=[];                                     %Pre-event envelope
for k=1:L
    PEE=[PEE;  (STAEnv(k).Env)];            %Pre-event envelopes
end
Wkernel.N=NN;                               %Total number of spikes
Wkernel.k0=lambda;                          %Zeroth order kernel (i.e., spike rate)
Wkernel.Varxx=Varxx;                        %Sound variance
Wkernel.k1=lambda*fliplr(mean(PEE))/Varxx;  %First order Wiener kernel
k1b= lambda*bootstrp(100,'mean',PEE)/Varxx; %Bootstrap to compute standard error
Wkernel.k1ste=std(fliplr(k1b));             %Standard error

%Second Order Kernel
Wkernel.Rxx2=fliplr(flipud(cov(XEnv)));     %Sound covariance
%Wkernel.Rxx2=Rxx2;                          %Sound covariance
Wkernel.Ryxx2=fliplr(flipud((cov(PEE))));   %Second order REVCORR
Wkernel.k2=2*lambda/Varxx^2*(Wkernel.Ryxx2-Wkernel.Rxx2);      %Second order Wiener kernel
Wkernel.PEE=PEE;                            %Pre-event envelopes

%Computing Qudrature NL filter approximation a la Yamada & Lewis
[U,S,V]=svd(Wkernel.k2);
Wkernel.k2_1=V(:,1);
Wkernel.k2_2=V(:,2);
Wkernel.lambda2_1=sign(max(V(:,1)./U(:,1)))*S(1,1);
Wkernel.lambda2_2=sign(max(V(:,2)./U(:,2)))*S(2,2);
Wkernel.k2U=U;
Wkernel.k2V=V;
Wkernel.k2S=S;

%Time delays and sampling rates
Wkernel.T=(-N1:N2)/Fsd*1000;                %Delay
Wkernel.T1=(-N1:N2)/Fsd*1000;               %Delay 1
Wkernel.T2=(-N1:N2)/Fsd*1000;               %Delay 2
Wkernel.Fs=Fsd;

%Estimating Output Nonlinearity
dt=1/(SoundParam.Fs/DF/SoundParam.DS);
Y1spike=[];
Y2spike=[];
Y1prior=[];
Y2prior=[];
for k=1:L
    
    %Spike event times using Fsd
    spet=round(RASData.Est(k).spet/RASData.Est(k).Fs*Fs/DF);
    
    %Sound in dB using Fsd
    X=20*log10(SoundEstEnv(ceil(k/2)).Env)+15;
    i=find(X<-15);
    X(i)=zeros(size(i));
    X=X(1:DF:end);
        
    %Predicting Output
    Y1=conv(Wkernel.k1,X);
    Y2_1=(conv(Wkernel.k2_1,X)).^2;
    Y2_2=(conv(Wkernel.k2_2,X)).^2;
    Y2=Wkernel.lambda2_1*Y2_1+Wkernel.lambda2_2*Y2_2;

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
[Nprior]=hist(Wkernel.Y1prior,y1);
[N]=hist(Wkernel.Y1spike,y1);
Wkernel.F1=Wkernel.k0*(N/sum(N))./(Nprior/sum(Nprior));
Wkernel.MinY1prior=min(Y1prior);
Wkernel.MaxY1prior=max(Y1prior);
Wkernel.MinY2prior=min(Y2prior);
Wkernel.MaxY2prior=max(Y2prior);
%i=find(isnan(Wkernel.F));
%Wkernel.F(i)=zeros(size(i));
Wkernel.y1=y1;
Wkernel.y2=y2;
Wkernel.Fs=SoundParam.Fs;
Wkernel.DS=SoundParam.DS;
Wkernel.DF=DF;

%Finding Regularized Nonlinearity by using closest neighbor. This is done
%because when the distribution for Yprior contains zeros F will contain
%NaN. The closes neighbor removes the NaN and assigns the closest neighbor
%using eucledian distance.
[in,jn]=find(isnan(Wkernel.F));
[i,j]=find(~isnan(Wkernel.F));
Fr=Wkernel.F;
for k=1:length(in)
   D=(in(k)-i).^2+(jn(k)-j).^2;
   l=find(D==min(D));
   l=l(1);
   
   Fr(in(k),jn(k))=Wkernel.F(i(l),j(l));
end
Wkernel.Fr=Fr;

%Displaying if desired
if strcmp(Disp,'y') 
    subplot(221)
    plot(Wkernel.T1,Wkernel.k1,'k')
    xlim([-T1 T2])
    xlabel('Delay (msec)')
    
    subplot(222)
    imagesc(Wkernel.T1,Wkernel.T2,Wkernel.k2),colorbar
    axis([-T1 T2 -T1 T2])
    xlabel('Delay1 (msec)')
    ylabel('Delay2 (msec)')
    
    subplot(223)
    plot(Wkernel.T1,V(:,2),'r')
    hold on
    plot(Wkernel.T1,V(:,1),'b')
    xlim([-T1 T2])
    
    subplot(224)
    imagesc(Wkernel.y1,Wkernel.y2,log10(Wkernel.F))
    set(gca,'ydir','normal')
    xlabel('y1')
    ylabel('y2')
end
%
%function [Wkernelb1,Wkernelb2]=wienerkernelenvboot2(RASData,SoundEstEnv,SoundParam,T1,T2,DF,NB,Disp)
%
%       FILE NAME       : WIENER KERNEL ENV BOOT 2
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994. 
%
%                         The program generates two bootstrap data sets by 
%                         splitting the data in half during each bootstrap
%                         itteration.
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
%       NB              : Number of boostraps
%       Disp            : Displaying output ('y' or 'n', Default=='n')
%
%RETURNED VARIABLES
%
%       Wkernelb1(k), Wkernelb2(k)
%                       : Vector structure containing 1st and 2nd order
%                          kernels. The first element corresobonds to all
%                          of the data. Elements 2:NB+1 corresponds to the
%                          bootstrap samples.
%
%                         The program returns two bootstrapped kernel by
%                         splitting the data into halfs for each bootstrap.                         
%
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
%   (C) Monty A. Escabi, Feb 2012
%
function [Wkernelb1,Wkernelb2]=wienerkernelenvboot2(RASData,SoundEstEnv,SoundParam,T1,T2,DF,NB,Disp)

%Input Arguments
if nargin<8
    Disp='n';
end

%Computing Wkernel for all of the data
[Wkernel1]=wienerkernelenv(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp);

%Removing Unecessary fields
Wkernel1=rmfield(Wkernel1,'PEE');
Wkernel1=rmfield(Wkernel1,'k2U');
Wkernel1=rmfield(Wkernel1,'k2V');
Wkernel1=rmfield(Wkernel1,'k2S');
Wkernel1=rmfield(Wkernel1,'Y1prior');
Wkernel1=rmfield(Wkernel1,'Y2prior');
Wkernel1=rmfield(Wkernel1,'Y1spike');
Wkernel1=rmfield(Wkernel1,'Y2spike');

%Adding to bootstrap structure
Wkernelb1(1)=Wkernel1;
Wkernelb2(1)=Wkernel1;

%Bootstrapping WIENERKERNELENV across spikes
for k=2:NB+1
    
    %Display Progress
    clc
    disp(['Bootstrapping Kernel Estimation: ' num2str((k-1)/NB*100,3) ' % done'])
    
    %Resampling data across spikes with replacement
    N=length(RASData.Est);
    RASDatab1=RASData;
    RASDatab2=RASData;
    for n=1:N
        
        %Selecting first and second half of spikes
        spet=RASData.Est(n).spet;
        NS=length(spet);
        i=randperm(NS);
        spet=spet(i);
        spet1=sort(spet(1:floor(NS/2)));
        spet2=sort(spet(floor(NS/2)+1:end));
        
        %Generating Kernel for both half of spikes
        RASDatab1.Est(n).spet=sort([spet1 spet1]);
        RASDatab2.Est(n).spet=sort([spet2 spet2]);
        
    end
    
    %Bootstrapping
    [Wkernel1]=wienerkernelenv(RASDatab1,SoundEstEnv,SoundParam,T1,T2,DF,Disp);
    [Wkernel2]=wienerkernelenv(RASDatab2,SoundEstEnv,SoundParam,T1,T2,DF,Disp);
    
    %Removing Unecessary fields
    Wkernel1=rmfield(Wkernel1,'PEE');
    Wkernel1=rmfield(Wkernel1,'k2U');
    Wkernel1=rmfield(Wkernel1,'k2V');
    Wkernel1=rmfield(Wkernel1,'k2S');
    Wkernel1=rmfield(Wkernel1,'Y1prior');
    Wkernel1=rmfield(Wkernel1,'Y2prior');
    Wkernel1=rmfield(Wkernel1,'Y1spike');
    Wkernel1=rmfield(Wkernel1,'Y2spike');
    Wkernel2=rmfield(Wkernel2,'PEE');
    Wkernel2=rmfield(Wkernel2,'k2U');
    Wkernel2=rmfield(Wkernel2,'k2V');
    Wkernel2=rmfield(Wkernel2,'k2S');
    Wkernel2=rmfield(Wkernel2,'Y1prior');
    Wkernel2=rmfield(Wkernel2,'Y2prior');
    Wkernel2=rmfield(Wkernel2,'Y1spike');
    Wkernel2=rmfield(Wkernel2,'Y2spike');

    %Adding to bootstrap structure
    Wkernelb1(k)=Wkernel1;
    Wkernelb2(k)=Wkernel2;
    
end
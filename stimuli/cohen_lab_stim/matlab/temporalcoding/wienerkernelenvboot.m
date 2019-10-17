%
%function [Wkernelb]=wienerkernelenvboot(RASData,SoundEstEnv,SoundParam,T1,T2,DF,NB,Disp)
%
%       FILE NAME       : WIENER KERNEL ENV BOOT
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994. The data is
%                         bootstrapped across spikes.
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
%       Wkernelb(k)      : Vector structure containing 1st and 2nd order
%                          kernels. The first element corresobonds to all
%                          of the data. Elements 2:NB+1 corresponds to the
%                          bootstrap samples.
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
%   (C) Monty A. Escabi, Jan 2012
%
function [Wkernelb]=wienerkernelenvboot(RASData,SoundEstEnv,SoundParam,T1,T2,DF,NB,Disp)

%Input Arguments
if nargin<8
    Disp='n';
end

%Computing Wkernel for all of the data
[Wkernel]=wienerkernelenv(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp);

%Removing Unecessary fields
Wkernel=rmfield(Wkernel,'PEE');
Wkernel=rmfield(Wkernel,'k2U');
Wkernel=rmfield(Wkernel,'k2V');
Wkernel=rmfield(Wkernel,'k2S');
Wkernel=rmfield(Wkernel,'Y1prior');
Wkernel=rmfield(Wkernel,'Y2prior');
Wkernel=rmfield(Wkernel,'Y1spike');
Wkernel=rmfield(Wkernel,'Y2spike');

%Adding to bootstrap structure
Wkernelb(1)=Wkernel;
    
%Bootstrapping WIENERKERNELENV across spikes
for k=2:NB+1
    
    %Display Progress
    clc
    disp(['Bootstrapping Kernel Estimation: ' num2str((k-1)/NB*100,3) ' % done'])
    
    %Resampling data across spikes with replacement
    N=length(RASData.Est);
    RASDatab=RASData;
    for n=1:N
        RASDatab.Est(n).spet=randsample(RASData.Est(n).spet,length(RASData.Est(n).spet),'true');
    end
    
    %Bootstrapping
    [Wkernel]=wienerkernelenv(RASDatab,SoundEstEnv,SoundParam,T1,T2,DF,Disp);
    
    %Removing Unecessary fields
    Wkernel=rmfield(Wkernel,'PEE');
    Wkernel=rmfield(Wkernel,'k2U');
    Wkernel=rmfield(Wkernel,'k2V');
    Wkernel=rmfield(Wkernel,'k2S');
    Wkernel=rmfield(Wkernel,'Y1prior');
    Wkernel=rmfield(Wkernel,'Y2prior');
    Wkernel=rmfield(Wkernel,'Y1spike');
    Wkernel=rmfield(Wkernel,'Y2spike');
    
    %Adding to bootstrap structure
    Wkernelb(k)=Wkernel;
end
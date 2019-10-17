%
%function [SAMPreb1,SAMPre2]=wienerkernelsampreboot2(Wkernelb1,Wkernelb2,SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp)
%
%       FILE NAME       : WIENER KERNEL SAM PRE BOOT 2
%       DESCRIPTION     : Prediction routine for SAM using the generalized 
%                         Wkernel nonlinear model. The predictions are
%                         bootstrapped across spikes. The data is also
%                         split in half during each bootstrap and two
%                         separate bootstrapped data sets are returned.
%
%                         For details see WIENERKERNELENVBOOT2.
%
%       Wkernelb1,      : Data structure vectors containing bootstrapped
%       Wkernelb2         kernels with estimated spiking nonlinearities.
%                         1 and 2 corresponds to bootstrapped kernels for
%                         each half of the data.
%                         See WIENERKERNELENVBOOT2.
%
%       SoundParam      : Data structure containing sound parameters
%       FMAxis          : Modulation frequency vector (e.g, [2 4 8 16 ...])
%       Beta            : Modualtion index (1)
%       Ncyc            : Number of cycles for simulation  (2 or 4)
%       Mcyc            : Number of bins per cycle to generate cycle
%                         histogram
%       Disp            : Display output ('y' or 'n'; Defaul=='n')
%
%RETURNED VARIABLES
%
%       SAMPreb1(k),SAMPreb2(k)      
%                       : Vector data structures containing bootstrapped
%                         prediction results for each half of the data (1
%                         and 2)
%
%                         .Data
%                           .Y1     - Predicted 1st-order output for channel 1
%                           .Y2     - Predicted 1st-order output for channel 2
%                           .Y1nl   - Predicted nonlinear output for channel 1
%                           .Y2nl   - Predicted nonlinear output for channel 2
%                           .Ytot   - Total combined output for channel 1 
%                                     and 2. Linear and nonlinear output
%                                     including the output nonlinearity (F).
%
%                         .MTF
%                           .Rate1nl        - Predicted rate MTF using 1st
%                                             order kernel + output
%                                             nonlinearity
%                           .VS1nl          - Predicted VS MTF using 1st
%                                             order kernel + output
%                                             nonlinearity
%                           .Ratetot        - Predicted rate MTF using 1st 
%                                             + 2nd order kernel + output
%                                             nonlinearity
%                           .VStot          - Predicted VS MTF using 1st
%                                             + 2nd order kernel + output
%                                             nonlinearity
%                           .FMAxis         - Modulation frequency vector (Hz)
%
%                         .CycleHist
%                           .Y1    -        - Linear model
%                           .Y1nl  -        - Linear + nonlinear model (1st
%                                             order kernel + output
%                                             nonlinearity)
%                           .Ytot  -        - Full nonlinear model (1st +
%                                             2nd order kernel + output 
%                                             nonlinearity)
%          
%   (C) Monty A. Escabi, Feb 2012
%
function [SAMPreb1,SAMPreb2]=wienerkernelsampreboot2(Wkernelb1,Wkernelb2,SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp)

%Input Args
if nargin<8
    Disp='n';
end

%Number of bootstraps
NB=length(Wkernelb1)-1;

%Prediction for full dataset
SAMPreb1(1)=wienerkernelsampre(Wkernelb1(1),SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp);
SAMPreb2(1)=SAMPreb1(1);

%Bootstrapping SAM Prediction
for k=2:NB+1
    
    %Display Progress
    clc
    disp(['Bootstrapping SAM Prediction: ' num2str((k-1)/NB*100,3) ' % done'])
    
    %Predicting SAM for bootstrap samples
    [SAMPreb1(k)]=wienerkernelsampre(Wkernelb1(k),SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp);
    [SAMPreb2(k)]=wienerkernelsampre(Wkernelb2(k),SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp);
    
end
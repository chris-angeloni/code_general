%
%function [SAMPreb]=wienerkernelsampreboot(Wkernelb,SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp)
%
%       FILE NAME       : WIENER KERNEL SAM PRE BOOT
%       DESCRIPTION     : Prediction routine for SAM using the generalized 
%                         Wkernel nonlinear model. The predictions are
%                         bootstrapped across spikes.
%
%                         For details see WIENERKERNELENVBOOT.
%
%       Wkernelb        : Structure vector containing bootstrapped kernels along
%                         with estimated spiking nonlinearities. See
%                         WIENERKERNELENVBOOT.
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
%       SAMPreb(k)      : Vector structure containing bootstrapped prediction results
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
function [SAMPreb]=wienerkernelsampreboot(Wkernelb,SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp)

%Input Args
if nargin<7
    Disp='n';
end

%Number of bootstraps
NB=length(Wkernelb)-1;

%Prediction for full dataset
[SAMPreb(1)]=wienerkernelsampre(Wkernelb(1),SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp);

%Bootstrapping SAM Prediction
for k=2:NB+1
    
    %Display Progress
    clc
    disp(['Bootstrapping SAM Prediction: ' num2str((k-1)/NB*100,3) ' % done'])
    
    %Predicting SAM for bootstrap samples
    [SAMPreb(k)]=wienerkernelsampre(Wkernelb(k),SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp);
    
end
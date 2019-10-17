%
%function [AudNetData]=integratefirenetworkaudsoundlist(List,Dir,Nlayer,Nnode,Nsig,TauE0,TauI0,SigE0,SigI0,lambda,alpha,gamma,Tref,SNR,EIR,Fs,flag,detrendim,detrendin)
%
%   FILE NAME       : INTEGRATE FIRE NETWORK AUD SOUND LIST
%   DESCRIPTION     : Auditory network composed of cochlear model followed
%                     by a multi-layer network of Excitatory / Inhibitory
%                     integrate fire model neurons
%
%   List            : Ordered filename matrix structure (N1xN2xN3) where N1 
%                     is the number of words, N2 is the number of subjects
%                     and N3 is the number of trials. The filenames are
%                     located under List(k,l,m).name
%   Dir             : Directory name containing files on list
%   Nlayer          : Number of network layers
%   Nnode           : Vector containg the number of neurons for each layer
%   Nsig0           : Normalized threshold for layer 1
%   TauE0           : Excitatory time constant for layer 1 (msec)
%   TauI0           : Inhibitory time constant for layer 1 (msec)
%   SigE0           : Excitatory spatial gaussian integration width 
%                     standard deviation (spatial axis is normalized from 
%                     0 to 1) for layer 1
%   SigI0           : Inhibitory spatial gaussian integration width 
%                     standard deviation (spatial axis is normalized from 
%                     0 to 1) for layer 1
%   lambda          : Scaling coefficiecnt for Nsig paramter where Nsig
%                     follows a power law : Nsig = Nsig0*lambda^(Layer-1)
%   alpha           : Scaling coefficiecnt for TauE and TauI paramter where
%                     both follows a power law : Tau = Tau0*alpha^(Layer-1)
%   gamma           : Scaling coefficiecnt for SigI and SigE paramter where
%                     both follow a power law : Sig = Sig0*gamma^(Layer-1)
%   Tref            : Vector containgn refractory Period (msec) for each
%                     layer
%   SNR             : Vector containg signal to noise ratio (dB) for each
%                     layer
%   EIR             : Vector containing excitatory to inhibitory ratio - normalized so that: StdE=EIR*StdI
%   Fs              : Sampling Rate (Hz)
%   Ntrial          : Number of simulated trials
%   flag            : flag = 0: Voltage variance is constant (Default)
%                     sig_m = (Vtresh-Vrest)/Nsig
%                     SNR is determined by Current
%                     1: Total Voltage variance is constant
%                        sig_tot = (Vtresh-Vrest)/Nsig
%                        SNR is determined by Current
%                     2: Voltage Variance is Constant
%                        SNR is determined by the Voltage
%                     3: Total Voltage Variance is constant
%                        sig_tot = (Vtresh-Vrest)/Nsig
%                        SNR is determined by the Voltage
%   detrendim       : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='y'). This detrending is usefull if you 
%                     know the desired intracellular voltage Vm, but not
%                     the intracellular current.
%   detrendin       : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you
%                     know the desired intracellular noise voltage but 
%                     not the intracellular noise current.
%
%OUTPUT VARIABLES
%
%   Ouputs are saved to data files. The files contain the spike trains for
%   all network layers and for all sounds in the sorted list.
%
% (C) MAE / Fatemeh, March 2015
%
function [AudNetData]=integratefirenetworkaudsoundlist(List,Dir,Nlayer,Nnode,Nsig,TauE0,TauI0,SigE0,SigI0,lambda,alpha,gamma,Tref,SNR,EIR,Fs,flag,detrendim,detrendin)

%Input Arguments
if nargin<17
    flag=3;
end
if nargin<18
    detrendim='y';
end
if nargin<19
    detrendin='n';
end

%Power law rules for threshold, time constants, and connectivity widths
Nsig=Nsig0*lambda.^(0:Nlayer-1);
TauE=TauE0*alpha.^(0:Nlayer-1);
TauI=TauI0*alpha.^(0:Nlayer-1);
SigE=SigE0*gamma.^(0:Nlayer-1);
SigI=SigI0*gamma.^(0:Nlayer-1);

%Simulating network for all sounds
for k=1:size(List,1)
    for l=1:size(List,2)
        for m=1:sizer(List,3)
            
            %Loading Audiogram files to simulate
            load([Dir List(k,l,m).name])
            
            %Simulating network
            [AudNetData(k,l,m)]=integratefirenetworkaud(S,Nlayer,Nnode,TauE,TauI,Tref,Nsig,SNR,SigE,SigI,EIR,Fs,flag,detrendim,detrendin);

        end
    end
end


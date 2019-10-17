%
%function [AudNetData]=integratefirenetworkaud(S,Nlayer,Nnode,TauE,TauI,Tref,Nsig,SNR,SigE,SigI,EIR,Fs,Ntrial,flag,detrendim,detrendin)
%
%   FILE NAME       : INTEGRATE FIRE NETWORK AUD
%   DESCRIPTION     : Auditory network composed of cochlear model followed
%                     by a multi-layer network of Excitatory / Inhibitory
%                     integrate fire model neurons
%
%   S               : Spectrotemporal sound input
%   Nlayer          : Number of network layers
%   Nnode           : Vector containg the number of neurons for each layer
%   TauE            : Vector containgn excitatory integration time constant 
%                     (msec) for each layer - time to reach maximum EPSP 
%                     amplitude
%   TauI            : Vector containging unhibitory integration time 
%                     constant (msec) for each layer - time to reach 
%                     minimum EPSP amplitude
%   Tref            : Vector containgn refractory Period (msec) for each
%                     layer
%   Nsig            : Vector containging number of standard deviations of the
%                     intracellular voltage to set the spike threshold for
%                     each layer
%   SNR             : Vector containg signal to noise ratio (dB) for each
%                     layer
%   SigE            : Vector containgin excitatory spatial gaussian integration width 
%                     standard deviation (spatial axis is normalized from 
%                     0 to 1) 
%   SigI            : Vector containign inhibitory spatial gaussian integration width 
%                     standard deviation (spatial axis is normalized from 
%                     0 to 1)
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
%   detrendin       : Removes time constant from In if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you
%                     know the desired intracellular noise voltage but 
%                     not the intracellular noise current.
%
%OUTPUT VARIABLES
%
%   AudNetData      : Output cell matrix containg network respones for all
%                     trials and layers
%
% (C) Monty A. Escabi, April 2013 (Edit June 20, 2016; Oct 2016)
%
function [AudNetData]=integratefirenetworkaud(S,Nlayer,Nnode,TauE,TauI,Tref,Nsig,SNR,SigE,SigI,EIR,Fs,Ntrial,flag,detrendim,detrendin)

%Input Arguments
if nargin<14
    flag=3;
end
if nargin<15
    detrendim='y';
end
if nargin<16
    detrendin='n';
end

%Parameter Vectors
if length(Nnode)==1
    Nnode=ones(1,Nlayer)*Nnode;
end
if length(TauE)==1
    TauE=ones(1,Nlayer)*TauE;
end
if length(TauI)==1
    TauI=ones(1,Nlayer)*TauI;
end
if length(Tref)==1
    Tref=ones(1,Nlayer)*Tref;
end
if length(Nsig)==1
    Nsig=ones(1,Nlayer)*Nsig;
end
if length(SNR)==1
    SNR=ones(1,Nlayer)*SNR;
end
if length(SigE)==1
    SigE=ones(1,Nlayer)*SigE;
end
if length(SigI)==1
    SigI=ones(1,Nlayer)*SigI;
end
if length(EIR)==1
    EIR=ones(1,Nlayer)*EIR;
end

%Simulating Auditory Network 
for n=1:Ntrial
        
        %Simulating Layer 1
%       [Y]=integratefirenetworklayer(S,Nnode(1),TauE(1),TauI(1),Tref,Nsig(1),SNR(1),SigE(1),SigI(1),EIR(1),Fs,flag,'y','n');
        [Y]=integratefirenetworkcontmulti(S,Nnode(1),TauE(1),Tref(1),Nsig(1),SNR(1),SigE(1),SigI(1),EIR(1),Fs,flag,detrendim,detrendin);    %Oct 2016, added detrendim and detrendin; previously hard coded
        AudNetData.Layer(1).Y{n}=sparse(Y);
        
        %Simulating Layers 2 to Nlayer
        for l=2:Nlayer
            clc
            disp(['Simulating Layer: ' num2str(l) ' of ' num2str(Nlayer) ' and Trial: ' num2str(n) ' of ' num2str(Ntrial)])
            
            [Y]=integratefirenetworklayer(full(AudNetData.Layer(l-1).Y{n}),Nnode(l),TauE(l),TauI(l),Tref,Nsig(l),SNR(l),SigE(l),SigI(l),EIR(l),Fs,flag,detrendim,detrendin);
            AudNetData.Layer(l).Y{n}=sparse(Y);
        end
end

%Saving Parameters (June 20, 2016)
AudNetData.Param.Nlayer=Nlayer;
AudNetData.Param.Nnode=Nnode;
AudNetData.Param.TauE=TauE;
AudNetData.Param.TauI=TauI;
AudNetData.Param.Tref=Tref;
AudNetData.Param.Nsig=Nsig;
AudNetData.Param.SNR=SNR;
AudNetData.Param.SigE=SigE;
AudNetData.Param.SigI=SigI;
AudNetData.Param.EIR=EIR;
AudNetData.Param.Fs=Fs;
AudNetData.Param.Ntrial=Ntrial;
AudNetData.Param.flag=flag;
AudNetData.Param.detrendim=detrendim;
AudNetData.Param.detrendin=detrendin;
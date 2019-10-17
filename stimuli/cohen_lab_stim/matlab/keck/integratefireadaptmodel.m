%
%function [Y]=integratefireadaptmodel(beta,X)
%
%       FILE NAME       : INTEGRATE FIRE ADAPT MODEL
%       DESCRIPTION     : Integrate and fire model neuron with threshold
%                         adaptation. Modified version of
%                         INTEGRATEFIREADAPT for use with LSQCURVEFIT.
%
%       beta        : Vector containing the following model parameters
%                     Tau       : Integration time constant (msec)
%                     Taum      : Membrane dependent threshold-adaptation
%                                 time constant (msec)
%                     Taus      : Spike dependent threhold-adaptation time
%                                 constant (msec)
%                     Gm        : Threshold-membrane voltage coupling gain
%                     Gs        : Threshold-spike coupling gain
%                     Tref      : Refractory Period (msec)
%                     Nsig      : Number of standard deviations of the
%                                 intracellular voltage to set the spike
%                                 threshold
%                     SNR       : Signal to Noise Ratio (dB)
%
%       X           : Data structure containg input and other relevant
%                     parameters. Data structure contains the following
%                     elements
%
%                     Im        : Input Membrane Current Signal
%                     Vtresh    : Threshold Membrane Potential (mVolts)
%                     Vrest     : Resting Membrane Potential - Same as the
%                                 leackage membrane potential (mVolts)
%                     Fs        : Sampling Rate
%                     flag      : flag = 0: Voltage variance is constant (Default)
%                                 sig_m = (Vtresh-Vrest)/Nsig
%                                 SNR is determined by Current
%                                 1: Total Voltage variance is constant
%                                    sig_tot = (Vtresh-Vrest)/Nsig
%                                    SNR is determined by Current
%                                 2: Voltage Variance is Constant
%                                    SNR is determined by the Voltage
%                                 3: Total Voltage Variance is constant
%                                    sig_tot = (Vtresh-Vrest)/Nsig
%                                    SNR is determined by the Voltage
%                     In        : Noise current signal (Optional: Default = 1/f noise)
%                     detrendim	: Removes time constant from Im if desired ('y' or 'n')
%                                 (Default=='n'). This detrending is usefull if you 
%                                 know the desired intracellular voltage Vm, but not
%                                 the intracellular current.
%                     detrendin	: Removes time constant from Im if desired ('y' or 'n')
%                                 (Default=='n'). This detrending is usefull if you
%                                 know the desired intracellular noise voltage but 
%                                 not the intracellular noise current.
%                     L         : Number of trials
%                     outtype   : Type of output
%                                 1: Mean Rate
%                                 2: PSTH
%                                 3: RASTERGRAM
%               
%OUTPUT SIGNAL
%	Y           : Output, Type of output is designated by outtype
%
function [Y]=integratefireadaptmodel(beta,X)

%Model Parameters
Tau=beta(1);
Taum=beta(2);
Taus=beta(3);
Gm=beta(4);
Gs=beta(5);
Tref=beta(6);
Nsig=beta(7);
SNR=beta(8);

%Input Parameters
Im=X.Im;
Vtresh=X.Vtresh;
Vrest=X.Vrest;
Fs=X.Fs;
flag=X.flag;
detrendim=X.detrendim;
detrendin=X.detrendin;

%Simulating Model
[taxis,RASTER]=rasterifadaptsim(Im,Tau,Taum,Taus,Gm,Gs,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L,In,detrendim,detrendin);

%Selecting output type
if outtype==1
    Y=mean(mean(RASTER))*Fs;
elseif outtype==2
    Y=mean(RASTER)*Fs;
else
    Y=RASTER;
end
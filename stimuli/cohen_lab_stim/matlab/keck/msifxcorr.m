%
%function [Rmodel]=msifxcorr(beta,spetpre)
%
%       FILE NAME       : MS IF XCORR
%       DESCRIPTION     : Mono-Synaptic Integrate and fire model neuron 
%			  Xcorrelation. The MS IF Neuron is Run using the
%			  Pre Synaptic Spike Train as Input. Returns the 
%			  Cross Correlation between the Real Pre Synaptic
%			  Neuron and the Model Post Synaptic Neuron
%
%	beta		: Monosynaptic Integrate Fire Parameters
%			  beta(1)=Tau    : Membrane Time Constant
%			  beta(2)=Tref   : Refractory Period
%			  beta(3)=tdelay : Mono Synaptic Delay
%			  beta(4)=Nsig   : Normalized Threshold
%			  beta(5)=SNR    : Intracellular Singal to Noise Ratio
%	spetpre		: Pre-Synaptic Spike Event Times Input
%			  The Following data parameters are appended to the
%			  begining of the array
%			  Fsp : Presynaptic Neuron Sampling Rate
%
%OUTPUT SIGNAL
%	Rmodel		: XCorrealtion Function Between Real Presynaptic and 
%			  Modeled Post Synaptic Neuron
%
function [Rmodel]=msifxcorr(beta,spetpre)
format long
disp(beta)

%Extracting Integrate Fire Parameters
Tau=beta(1);
%Tref=beta(2);
%tdelay=beta(3);
Tref=2;
tdelay=1;
Nsig=beta(2);
SNR=beta(3);

%Sampling Rate 
FsMSIF=2000;		%Sampling Rate for Mono Synaptic IF Model
Fspre=spetpre(1);	%Sampling Rate for Pre Synaptic Neuron
FsCorr=1000;		%Sampling Rate for Xcorrelation

%Removing Fs from spetp Array
spetpre=spetpre(2:length(spetpre));

%Running Mono Synaptic Integrate Fire Model
tic,
[Y,Vm,R,C,sigma_m,sigma_i,sigma_n,sigma_tot]=msintegratefire(spetpre,Fspre,Tau,Tref,tdelay,-55,-65,Nsig,SNR,FsMSIF,0);
toc

%Converting Spike Array to Interevent Time Array
spetpost=impulse2spet(Y,FsMSIF,Fspre);

%Performing XCorrelation Between the Real Pre Synaptic
%and the Model Post Synaptic Neurons
Rmodel=xcorrspikeb(spetpre,spetpost,Fspre,FsCorr,.5,30)';

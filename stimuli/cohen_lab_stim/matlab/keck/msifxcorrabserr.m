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
function [MSE]=msifxcorrabserr(beta,spetpre,Rreal)

Rmodel=msifxcorr(beta,spetpre);
whos
spetpre(1)
MSE=mean((Rmodel-Rreal).^2)/var(Rreal)


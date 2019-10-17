%
%function [Rmodel]=ifxcorr(X,beta)
%
%       FILE NAME       : MS IF XCORR
%       DESCRIPTION     : Integrate and fire model neuron Xcorrelatin
%			  The IF Neuron is Run using an intracellular 
%			  waveform as input. The across trial correlation 
%			  function is estimated. 
%
%	X		: Input Data Structure
%			  X.Im      : Intracellular current
%			  X.In      : Intracellular noise (length must be twice 
%				      as long as for Im)
%			  X.Fs      : Sampling rate for Im and In
%			  X.FsCorr  : Xcorr sampling rate
%			  X.FsSpet  : Sampling rate for spet variables
%			  X.T	    : Temporal Lag for Correlation
%			  X.Rreal   : Real across channel correlation
%
%	beta		: Monosynaptic Integrate Fire Parameters
%			  beta(1)=Tau    : Membrane Time Constant
%			  beta(2)=Tref   : Refractory Period
%			  beta(4)=Nsig   : Normalized Threshold
%			  beta(5)=SNR    : Intracellular Singal to Noise Ratio
%
%OUTPUT SIGNAL
%	Rmodel		: XCorrealtion Function Between Real Neuron and 
%			  Modeled Neuron
%
function [Rmodel]=ifxcorr(beta,X)
format long
disp(beta)

%Extracting Integrate Fire Parameters
Tau=beta(1);
%Tref=beta(2);
Tref=2;
Nsig=beta(2);
SNR=beta(3);

%Running Integrate Fire Model
tic,
L=length(X.Im);
N1=round(.8*rand*L)+1;
N2=round(.8*rand*L)+1;
[Y1]=integratefire(X.Im,Tau,Tref,-50,-65,Nsig,SNR,X.Fs,0,X.In(N1+1:N1+L));
[Y2]=integratefire(X.Im,Tau,Tref,-50,-65,Nsig,SNR,X.Fs,0,X.In(N2+1:N2+L));
toc

%Converting Spike Array to Interevent Time Array
spetif1=impulse2spet(Y1,X.Fs,X.FsSpet);
spetif2=impulse2spet(Y2,X.Fs,X.FsSpet);

%Performing XCorrelation Between the Real Pre Synaptic
%and the Model Post Synaptic Neurons
Rmodel=xcorrspikeb(spetif1,spetif2,X.FsSpet,X.FsCorr,X.T,30)';

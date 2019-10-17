%
%function [MSE]=ifxcorrmse(beta,X)
%
%       FILE NAME       : IF XCORR MSE
%       DESCRIPTION     : Integrate fire model xcorrelation mean square error
%
%	beta		: Monosynaptic Integrate Fire Parameters
%			  beta(1)=Tau    : Membrane Time Constant
%			  beta(2)=Tref   : Refractory Period
%			  beta(4)=Nsig   : Normalized Threshold
%			  beta(5)=SNR    : Intracellular Singal to Noise Ratio
%
%	X		: Input Data Structure
%			  X.Im      : Intracellular current
%			  X.In      : Intracellular noise (length must be twice 
%				      as long as for Im)
%			  X.Fs      : Sampling rate for Im and In
%			  X.FsCorr  : Xcorr sampling rate
%			  X.FsSpet  : Sampling rate for spet variables
%			  X.T	    : Temporal Lag for Correlation
%			  X.Real    : Real across channel correlation
%
%OUTPUT SIGNAL
%	MSE		: Mean Square Error between model and data 
%
function [MSE]=ifxcorrmse(beta,X)

%Generating Model Across Trial Correlation
[Rmodel]=ifxcorr(beta,X);

close all
plot(Rmodel)
hold on
plot(X.Rreal,'r')
pause(0)

%Finding Mean Square Error
if size(X.Rreal)~=size(Rmodel)
	MSE=sum((X.Rreal-Rmodel').^2);
else
	MSE=sum((X.Rreal-Rmodel).^2);
end

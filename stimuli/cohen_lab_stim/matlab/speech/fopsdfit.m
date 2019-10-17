%function [Po,alpha]=fopsdfit(To,F1,F2)
%	
%	FILE NAME 	: FO PSD FIT
%	DESCRIPTION 	: Fits the Power Spectrum of Fo=1/To to a Power Law
%			  in a RMS sense
%
%	To		: Measured Fundamental Period Array 
%	F1		: Lower Freqeuncy used for polyfit
%	F2		: Upper Frequency used for polyfit
%
%	Fit is of the Form:
%
%		Po * F ^ ( - alpha )
%
function [Po,alpha]=fopsdfit(To,F1,F2)

%Finding PSD
[P,F]=psd(1./To,length(To),mean(1./To));

%Finding data used for fit
index1=min(find(F>F1));
index2=max(find(F<F2));
logF=log10(F(index1:index2));
logP=log10(P(index1:index2));

%Fiting to Power Law
[p,S]=polyfit(logF,logP,1);
alpha=abs(p(1));
Po=10^p(2);

%
% function [STRFg]=strfgmodel1(taxis,Xaxis,beta);
%
%	FILE NAME	: STRF G MODEL 1
%	DESCRIPTION	: Separable STRF Gabor Model 
%
%	taxis		: Time axis
%	Xaxis		: Octave frequency axis
%	beta		: Gabor function parameters
%
%			  beta(1)  Center frequency
%			  beta(2)  SRF bandwidht
%			  beta(3)  Best spectral modulation
%			  beta(4)  Spectral phase
%			  beta(5)  Peak latency
%			  beta(6)  Response duration
%			  beta(7)  Best temporal modulation
%			  beta(8)  Temporal Phase
%			  beta(9)  Magnitude Scaling Factor
%
% RETURNED VALUES
%	
%	STRFg		: Model Gabor STRF Data structure
%			  STRFg.TRF1: First order temporal component
%			  STRFg.SRF1: First order spectral component
%			  STRFg.K1  : First order amplitude constant
%
%
function [STRFg]=strfgmodel1(taxis,Xaxis,beta);

%Gabor Spectral Receptive Field
SRF=exp(-(2*(Xaxis-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(Xaxis-beta(1))+beta(4));

%Gabor Temporal Receptive Field
TRF=(exp(-(taxis-beta(5))/beta(6)).^2).*cos(2*pi*beta(7)*(taxis-beta(5))+beta(8));

%Gabor STRF Model
STRFg.TRF1=TRF;
STRFg.SRF1=SRF;
STRFg.K1=beta(9);

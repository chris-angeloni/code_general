%
% function [STRFg2]=strfgmodel1(taxis,Xaxis,beta);
%
%	FILE NAME	: STRF G MODEL 1
%	DESCRIPTION	: Separable STRF Gabor Model 
%
%	taxis		: Time axis
%	Xaxis		: Octave frequency axis
%	beta		: Gabor function parameters
%
%			Parameters for 1st Gabor Component
%			  beta(1)   Center frequency
%			  beta(2)   SRF bandwidht
%			  beta(3)   Best spectral modulation
%			  beta(4)   Spectral phase
%			  beta(5)   Peak latency
%			  beta(6)   Response duration
%			  beta(7)   Best temporal modulation
%			  beta(8)   Temporal Phase
%			  beta(9)   Magnitude Scaling Factor
%
%			Parameters for 2nd Gabor Component
%			  beta(10)  Center frequency
%			  beta(11)  SRF bandwidht
%			  beta(12)  Best spectral modulation
%			  beta(13)  Spectral phase
%			  beta(14)  Peak latency
%			  beta(15)  Response duration
%			  beta(16)  Best temporal modulation
%			  beta(17)  Temporal Phase
%			  beta(18)  Magnitude Scaling Factor
%
% RETURNED VALUES
%
%       STRFg           : Model Gabor STRF Data structure
%			  STRFg.TRF1: First order temporal component
%			  STRFg.SRF1: First order spectral component
%			  STRFg.K1  : First order Amplitude constant
%			  STRFg.TRF2: Second order temporal component
%			  STRFg.SRF2: Second order spectral component
%			  STRFg.K2  : Second order amplitude constant
%
%
function [STRFg2]=strfgmodel1(taxis,Xaxis,beta);

%Gabor Spectral Receptive Field
SRF1=exp(-(2*(Xaxis-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(Xaxis-beta(1))+beta(4));
SRF2=exp(-(2*(Xaxis-beta(10))/beta(11)).^2).*cos(2*pi*beta(12)*(Xaxis-beta(10))+beta(13));

%Gabor Temporal Receptive Field
TRF1=(exp(-(taxis-beta(5))/beta(6)).^2).*cos(2*pi*beta(7)*(taxis-beta(5))+beta(8));
TRF2=(exp(-(taxis-beta(14))/beta(15)).^2).*cos(2*pi*beta(16)*(taxis-beta(14))+beta(17));

%Gabor STRF Model
STRFg2=beta(9)*SRF1'*TRF1+beta(18)*SRF2'*TRF2;

STRFg2.TRF1=TRF1;
STRFg2.SRF1=SRF1;
STRFg2.K1=beta(9);
STRFg2.TRF2=TRF2;
STRFg2.SRF2=SRF2;
STRFg2.K2=beta(18);


%function [To]=titze(x,Fs)
%	
%	FILE NAME 	: TITZE
%	DESCRIPTION 	: Finds To using Linear Interpolation
%
%	x		: Input Signal
%	Fs		: Sampling Frequency
%	To		: Measured Fundamental Period Array 
%
function [To]=titze(x,Fs)

%Finding ZC
nz=findzc(x);

%Interpolating
Ts=1/Fs;
tzc=Ts*(nz+1-x(nz+1)./(x(nz+1)-x(nz)));

%Finding Periods
To=tzc(2:length(tzc))-tzc(1:length(tzc)-1);



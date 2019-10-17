%
%function [Hinv] = ripplecalibrate(calib,faxis)
%
%	FILE NAME 	: RIPPLE CALIBRATE
%	DESCRIPTION 	: Generates a lookup table to callibrates the 
%			  Dynamic Ripple and Ripple Noise signals.
%			  Uses a recorded speaker transfer function to derive 
%			  the inverse transfer function that is converted into 
%			  frequency dependent lookup table.
%
%	calib		: Calibration Data Structure
%			  ADrate: Sampling Rate
%			  chan1: transfer function for chan1 (speaker 1)
%			  chan2: transfer function for chan2 (speaker 2)
%	faxis		: Frequency axis used to generate Rippple Signal
%
%RETURNED DATA
%
%	Hinv		: Inverse transfer function lookup table
%
function [Hinv] = ripplecalibrate(calib,faxis)

%Finding the Normalized Mean Transfer function (combined speaker 1+2 )
H=(abs(calib.chan1)+abs(calib.chan2))/2;
H=H/max(H);
Faxis=(1:length(H))/length(H)*calib.ADrate;

%Inverse Transfer function
Hi=1./H;

%Generating Lookup Table (Cubic Interpolation)
Hinv=interp1(Faxis,Hi,faxis,'cubic');
Hinv=Hinv/max(Hinv);


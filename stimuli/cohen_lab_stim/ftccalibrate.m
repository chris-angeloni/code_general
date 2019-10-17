%
%function [FTC] = ftccalibrate(H,faxis)
%
%	FILE NAME 	: FTC CALIB
%	DESCRIPTION 	: Calibrated Frequency Tunning Curve. Uses a lookup
%			  table approach.
%
%	H		: Calibration Transfer Function Data Structure
%			  ADrate: Sampling Rate
%			  chan1: transfer function for chan1 (speaker 1)
%			  chan2: transfer function for chan2 (speaker 2)
%	faxis		: Frequency axis used to generate Rippple Signal
%
%RETURNED DATA
%
%	FTC		: Data structure containing frequency tunning curve
%			  entries
%
%			  FTC.Freq     - Frequency Axis
%			  FTC.ATTCalib - Calibrated Attenuation
%			  FTC.ATT      - Uncalibrated Attenuation
%
function [FTC] = ftccalibrate(H,faxis,ATT)

%Finding the Normalized Mean Transfer function (combined speaker 1+2 )
%Note: Average of dB transfer function is equivalent to geometric means of H
HdB=(20*log10(abs(H.chan1))+20*log10(abs(H.chan2)))/2;
HdB=HdB-mean(HdB);
Faxis=(0:length(HdB)-1)/length(HdB)*H.ADrate;
N=length(HdB);
HdB=HdB(1:N/2);
Faxis=Faxis(1:N/2);

%Inverse Mean Transfer function - Note that when Using dBs simply multiply by -
%sign
Hi=-HdB;

%Generating Lookup Table (Cubic Interpolation)
Hinv=interp1(Faxis,Hi,faxis,'cubic');
Hinv=Hinv-mean(Hinv);

%Generating Frequency and ATT Arrays
att=[];
Faxis=[];
for k=1:length(ATT)

	Faxis=[Faxis faxis];
	att=[att ATT(k)*ones(size(faxis))+Hinv];
end

%Reordering and Saving to Data Structure
FTC.Faxis=Faxis;
FTC.ATT=att;
rand('state',0);
index=randperm(length(Faxis));
FTC.FaxisPerm=Faxis(index);
FTC.ATTPerm=att(index);


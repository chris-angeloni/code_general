%
%function [Y]=mgaborripple(f1,f2,RD,FM,App,M,Fs,NS,RP)
%
%	
%	FILE NAME       : M GABOR RIPPLE
%	DESCRIPTION 	: Genrates GABOR Moving Ripple sound
%
%	f1              : Lower Noise Frequency
%	f2              : Upper Noise Frequnecy
%	RD              : Ripple Density (cycles/octave)
%	FM              : Temporal Modulation Rate (Hz)
%   App             : Peak to Peak Riple Amplitude ( dB )
%   sigmaX          : Gabor standard deviation (octaves)
%   M               : Number of Samples
%   Fs              : Sampling Rate
%   NS              : Number of sinusoid carriers
%   RP              : Ripple Phase [0,2*pi]
%                     Optional - default = random from [0,2*pi]
%
function [Y]=mgaborripple(f1,f2,RD,FM,App,sigmaX,M,Fs,NS,RP)

%Input arguments
if nargin<9
	RP=2*pi*rand;
end

%Octave Frequency Axis
XMax=log2(f2/f1);
X=(0:NS-1)/(NS-1)*XMax;
faxis=f1*2.^X;

%Time Axis
time=(1:M)/Fs;

%Generating Ripple Sound
Y=zeros(1,M);
for k=1:NS

	Sk=10.^( App/40*sin( 2*pi*RD*X(k) + 2*pi*FM*time +RP )-App/40 );
	Y=Y+Sk.*sin(2*pi*faxis(k).*time + 2*pi*rand );

end
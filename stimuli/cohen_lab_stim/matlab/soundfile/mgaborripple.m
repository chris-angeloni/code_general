%
%function [Y,S,t,X]=mgaborripple(f1,f2,RD,FM,App,sigmaX,M,Fs,NS,RP,RPG,DF)
%	
%   FILE NAME       : M GABOR RIPPLE
%   DESCRIPTION     : Genrates GABOR Moving Ripple sound
%
%   f1              : Lower Noise Frequency
%   f2              : Upper Noise Frequnecy
%   RD              : Ripple Density (cycles/octave)
%   FM              : Temporal Modulation Rate (Hz)
%   App             : Peak to Peak Riple Amplitude ( dB )
%   sigmaX          : Gabor standard deviation (octaves)
%   M               : Number of Samples
%   Fs              : Sampling Rate
%   NS              : Number of sinusoid carriers
%   RP              : Ripple Phase [0,2*pi]
%                     Optional - default = random from [0,2*pi]
%   RPG             : Relative Phase Between Center of Gabor and Ripple
%   DF              : Temporal Downsampling factor for spectrotemporal
%                     envelope (S)
%
%RETURNED VALUES
%   Y               : Sound Waveform
%   S               : Spectrotemporal Profile
%   t               : Time axis for S
%   X               : Octave frequency axis for S
%
% (C) Monty Escabi, August 2006
%
function [Y,S,t,X]=mgaborripple(f1,f2,RD,FM,App,sigmaX,M,Fs,NS,RP,RPG,DF)

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
    
    X0=(-RP-2*pi*FM*time)/2/pi/RD; %Time Varying Gabor Centroid
    Gk=exp( - ( X(k)-X0 ).^2 / 2 / sigmaX.^2 );
	Sk=10.^( App/40*Gk .* cos( 2*pi*RD*X(k) + 2*pi*FM*time + RP + RPG)-App/40 );
	S(k,:)=Sk(1:DF:length(Sk));
    Y=Y+Sk.*sin(2*pi*faxis(k).*time + 2*pi*rand );
    t=time(1:DF:length(time));

end

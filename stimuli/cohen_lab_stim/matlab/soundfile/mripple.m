%
%function [Y,S,t,X]=mripple(f1,f2,RD,FM,App,ModType,M,Fs,NS,RP,DF)
%	
%	FILE NAME       : M RIPPLE
%	DESCRIPTION 	: Genrates Moving Ripple sound. Sound is normalized for
%                     unit variance.
%
%	f1              : Lower Noise Frequency
%	f2              : Upper Noise Frequnecy
%	RD              : Ripple Density (cycles/octave)
%	FM              : Temporal Modulation Rate (Hz)
%   App             : Peak to Peak Riple Amplitude ( dB or Lin)
%   ModType         : Ripple Envelope modulation Type: 'Log' or 'Lin'
%                     Log - Logarithmic modulations in dB
%                     Lin - linear modulation, App corresponds to the
%                           modulation index [0 1]
%   M               : Number of Samples
%   Fs              : Sampling Rate
%   NS              : Number of sinusoid carriers
%   RP              : Ripple Phase [0,2*pi]
%                     Optional - default = random from [0,2*pi]
%   DF              : Temporal Downsampling factor for spectrotemporal
%                     envelope (S). If DF=Inf then it will not generate the
%                     spectrotemporal profile (S). Optional, Default==Inf
%                     (no spectrotemporal envelope).
%
%RETURNED VALUES
%   Y               : Sound Waveform
%   S               : Spectrotemporal Profile
%   t               : Time axis for S
%   X               : Octave frequency axis for S
%
% (C) Monty Escabi, August 2006 (Last Edit May 2009)
%
function [Y,S,t,X]=mripple(f1,f2,RD,FM,App,ModType,M,Fs,NS,RP,DF)

%Input arguments
if nargin<10
	RP=2*pi*rand;
end
if nargin<11
    DF=inf;
end

%Octave Frequency Axis
XMax=log2(f2/f1);
X=(0:NS-1)/(NS-1)*XMax;
faxis=f1*2.^X;

%Time Axis
time=(1:M)/Fs;

%Generating Ripple Sound
Y=zeros(1,M);
if strcmp(ModType,'Log')
    
    S=zeros(NS,M/DF);  %Much faster if matrix is allocated first
    for k=1:NS
        %Displaying Progress
        clc
        disp(['Generating carrier: ' int2str(k) ' of ' int2str(NS)]);
        pause(0)
        
        %Generating Envelope and Carriers (Logarithmic Modulation)
        Sk=10.^( App/40*sin( 2*pi*RD*X(k) + 2*pi*FM*time +RP )-App/40 );
        Y=Y+Sk.*sin(2*pi*faxis(k).*time + 2*pi*rand );
        if ~isinf(DF)   %Reduces Memory Requirement
            S(k,:)=Sk(1:DF:length(Sk));
            t=time(1:DF:length(time));
        end
    end

elseif strcmp(ModType,'Lin')
    
    S=zeros(NS,M);  %Much if matrix is allocated first
    for k=1:NS
        %Displaying Progress
        clc
        disp(['Generating carrier: ' int2str(k) ' of ' int2str(NS)]);
        pause(0)
        
        %Generating Envelope and Carriers (Linear Modulation)
        Sk=(1-App/2)+App/2*sin( 2*pi*RD*X(k) + 2*pi*FM*time +RP );
        Y=Y+Sk.*sin(2*pi*faxis(k).*time + 2*pi*rand );
        if ~isinf(DF)   %Reduces Memory Requirement
            S(k,:)=Sk(1:DF:length(Sk));
            t=time(1:DF:length(time));
        end
    end
    
end

%Returning Dummy Envelope
if isinf(DF)
    S=[];
    t=[];
    X=[];
end

%Normalizing for unit variance
Y=Y/std(Y);
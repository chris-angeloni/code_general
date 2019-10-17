%
%function [Artifact]=findartifact(X,Fs,MaxScale)
%
%	FILE NAME 	: FIND ARTIFACT
%	DESCRIPTION : Manually find the time points for a artifacts in the EEG
%                 trace
%
%	X           : EEG Waveform
%   Fs          : Sampling rate
%   MaxScale    : Maximum amplitude for plotting window (in uVolts)
%
%RETUERNED VARIABLES
%
%	Artifact    : Start and end sample times for artifacts
%                 e.g., Artifact=[s1 e1 s2 e2 s3 e3]
%
function [Artifact]=findartifact(X,Fs,MaxScale)

%Plotting EEG Waveform
X=X*1E6;   %Convert to uVolts
time=(0:length(X)-1)/Fs;
plot(time,X)
if ~exist('MaxScale')
    Max=max(abs(X));
else
    Max=MaxScale;
end
axis([0 max(time) -Max Max])
xlabel('time (sec)')
ylabel('Signal Amplitude (mVolts)')

%Finding Number of Sound Segments
N=input('How Many Artifact Segments (999 to skip record): ');

if N>0 & N~=999

    %Finding Edge Points
    [t,amp]=ginput(2*N);

    %Convering Edge Points to Samples
    Artifact=round(t*Fs)';
    if Artifact(1)<0
    	Artifact(1)=1;
    end
    if Artifact(length(Artifact))>length(time)
    	Artifact(length(Artifact))=length(time);
    end

elseif N==999
    
    Artifact=-999;
    
else
    
    Artifact=[];
    
end
    

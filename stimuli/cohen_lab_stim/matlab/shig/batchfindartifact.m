%
%function [Artifact]=batchfindartifact(ext,Fs,Save,L1,L2)
%
%   FILE NAME   : BATCH FIND ARTIFACT
%   DESCRIPTION : Find the time points for a artifacts in the EEG for all
%                 files in the working directory
%
%   ext         : File extension (e.g., '*.wav', '*.wave', etc
%   Fs          : Samping rate (Hz)
%   Save        : Save to file, Optional (Default=='y')
%   MaxScale    : Maximum amplitude for plotting window (in mVolts)
%   L1          : Starting file in Directory List (Optional)
%   L2          : Ending file in Directory List (Optional)
%
%RETUERNED VARIABLES
%
%	Artifact    : Start and end sample times for artifacts
%                 e.g., Artifact=[s1 e1 s2 e2 s3 e3]
%
%   (C) Monty A. Escabi, June 2007
%
function [Artifact]=batchfindartifact(ext,Fs,Save,MaxScale,L1,L2)

%Finding Files
List=dir(ext);
if nargin>5
   List=List(L1:L2);
end

%Running Find Artifact
for k=1:length(List)
    
    %Reading Data
    fid=fopen(List(k).name);
    X=fread(fid,inf,'float','l');
    
    %Finding Artifacts
    if nargin<4
        Artifact(k).Samplepoints=findartifact(X,Fs)
    else
        Artifact(k).Samplepoints=findartifact(X,Fs,MaxScale)
    end
    Artifact(k).Fs=Fs;
    Artifact(k).Filename=List(k).name;

end

%Saving to file
if Save=='y'
    
    save ArtifactData Artifact
    
end
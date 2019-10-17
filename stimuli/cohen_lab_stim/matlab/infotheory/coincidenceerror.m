%
%function
%[Coincidence,CoincidenceMatrix]=coincidenceerror(RASTERm,RASTERc,Fs,dt)
%
%       FILE NAME       : COINCIDENCE ERROR
%       DESCRIPTION     : Computes the average coincidence rate for single
%                         spikes betweeen two rasters. If the rasters are
%                         identical the diagonal terms are removed. 
%
%       RASTERm         : Model Rastergram
%       RASTERc         : Cell Rastergram
%       Fs              : Sampling rate
%       dt              : Smoothing resolution - square window of width dt
%
%OUTPUT
%
%   Coincidence         : Average coincidence rate across trials
%   CoincidenceMatrix   : Matrix containging the fraction of
%                         coincidence between the kth and lth trials
%
%       (C) Monty A. Escabi, May 2006
%
function [Coincidence,CoincidenceMatrix]=coincidenceerror(RASTERm,RASTERc,Fs,dt)

%Smooting window at resolution dt
W=ones(1,ceil(dt/1000*Fs));
NW=length(W);

%Finding Convolution between rater trials and smooting window
for k=1:size(RASTERm,1)
    for l=1:size(RASTERc,1)
        RASm(k,:)=conv(W,RASTERm(k,:));
        RASc(l,:)=conv(W,RASTERc(l,:));        
    end
end

%Truncating Rastors to remove edge artifact
N=size(RASm,2);
RASm=RASm(:,NW-1:N-NW+1);
RASc=RASc(:,NW-1:N-NW+1);


%Computing Coincidence Rate Matrix
for k=1:size(RASTERm,1)
    for l=1:size(RASTERc,1)
        index1=find(RASm(k,:).*RASc(l,:)>0);
        index2=find(RASm(k,:)~=0 | RASc(l,:)~=0);
        CoincidenceMatrix(k,l)=length(index1)/length(index2);
    end
end

%Average Coincidence 
N1=size(CoincidenceMatrix,1);
N2=size(CoincidenceMatrix,2);
if mean(diag(CoincidenceMatrix))==1    
    Coincidence=(sum(sum(CoincidenceMatrix))-N1)/(N1-1)/N2;     %Removes Diagonal Terms if Rasters are identical
else
    Coincidence=mean(reshape(CoincidenceMatrix,1,N1*N2));
end
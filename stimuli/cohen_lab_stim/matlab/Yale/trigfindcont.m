%
%function [TrigTimes]=trigfindcont(X,Tresh)
%
%       FILE NAME       : TRIG FIND CONT
%       DESCRIPTION     : Find triggers from a continuous session. Used for
%                         STRF recordings with Yale Cohen.
%
%	X		: Unprocessed trigger signal
%	Tresh	: Threshhold : Normalized [0 to 1]
%			  Default: Tresh==.75
%
%RETURNED VARIABLES
%
%   TrigTimes   : Trigger times (in sample number)
%   
%   (C) Monty A. Escabi, July 2010
%
function [TrigTimes]=trigfind(X,Tresh)

%Input args
if nargin<2
    Tresh=0.75;
end

%Reconstructing Triggers
i=find(X>Tresh*max(X));
ii =find(diff(i)>2)+1;
TrigTimes=i(ii);
TrigTimes=[TrigTimes(1)-min(diff(TrigTimes)) TrigTimes];    %Adding first trigger

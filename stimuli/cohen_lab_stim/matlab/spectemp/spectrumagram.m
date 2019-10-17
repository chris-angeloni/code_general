%
%function [ASP]=spectrumagram(header,M,L)
%
%       FILE NAME       : SPECTRUM AGRAM
%       DESCRIPTION     : Computes the Mean Spectrum from the audiogram
%
%	header		: File name header
%	M		: Data block size
%	L		: Number of Blocks to use (Default=inf)
%
%RETURNED VALUES
%
%	ASP		: Audigram Spectrum
%
function [ASP]=corrcoefagram(header,M,L)

%Input Arguments
if nargin<3
        L=inf;
end                 

%Finding Average Audiogram Spectrum 
count=0;
[ste]=xtractagram(header,M*count+1,M*(count+1));
ASP=zeros(1,size(ste,1));
while size(ste)~=[1 1] & count<L
	clc
	disp(['Evaluating Block Number: ' int2str(count+1)])
	[ste]=xtractagram(header,M*count+1,M*(count+1));
	ASP=ASP+sum(ste');
	count=count+1;
end
ASP=ASP/count;


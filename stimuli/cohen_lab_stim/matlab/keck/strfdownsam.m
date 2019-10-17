%
%function [taxis,faxis,STRF]=strfdownsam(taxis,faxis,STRF,LT,LF)
%
%       FILE NAME       : STRF DOWN SAM
%       DESCRIPTION     : Down samples an STRF
%	
%	taxis		: Time Axis
%	faxis		: Frequency Axis
%	STRF		: Spectro Temporal Receptive Field
%	LT		: Temporal down sampling factor 
%			  1 means no down sampling
%	LF		: Spectral down sampling factor
%			  1 means no down sampling
%
function [taxis,faxis,STRF]=strfdownsam(taxis,faxis,STRF,LT,LF)

%Down sampling the STRF
STRF=STRF(1:LF:length(faxis),1:LT:length(taxis));
taxis=taxis(1:LT:length(taxis));
faxis=faxis(1:LF:length(faxis));


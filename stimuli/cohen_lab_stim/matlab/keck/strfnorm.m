%
%function [norm]=strfnorm(STRF1,STRF2,PP)
%
%       FILE NAME       : STRF NORM
%       DESCRIPTION     : Computes the STRF Norm for a binaural STRF pair.
%			  This quantity is equivalent to the STRF standard
%			  deviation.
%
%			  For this analysis to be meaningful 
%			  the statistically significant STRFs are assumed 
%			  as the input.  These can be obatained using 
%			  WSTRFSTAT.
%	
%	STRF1		: Spectro-temporal receptive field 1
%	STRF2		: Spectro-temporal receptive field 2
%	PP		: Stimulus Power Level
%
%RETURNED VARIABLES
%	norm		: STRF Norm
%
function [norm]=strfnorm(STRF1,STRF2,PP)

%Evaluating the Norm
STRF=[STRF1 STRF2];
i=find(STRF~=0);
norm= sqrt(sum(STRF(i).^2)*PP/length(i));


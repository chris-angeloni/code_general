%
%function [Std]=strfstd(STRF1,STRF2,PP,Fst)
%
%       FILE NAME       : STRF STD
%       DESCRIPTION     : Computes the average expected output for a given 
%			  binaural STRF pair. This quantity is computed 
%			  directly from the rate normalized STRF:
%			  RF = std(S(t,X)) * STRF(t,Z). The expected output
%			  STD is computed as follows:
%				std^2=E[y(t)^2]
%			  where 
%				y(t) = sum( y_k(t) )
%			  and
%				y_k(t)=conv(S(t,X_k)) , STRF(t,X_k))
%			
%			  For this analysis to be meaningful 
%			  the statistically significant STRF (STRFs) are assumed 
%			  as the input.  These can be obatained using 
%			  WSTRFSTAT.
%	
%	STRF1   : Significant spectro-temporal receptive field 1
%	STRF2	: Significant spectro-temporal receptive field 2
%	PP		: Stimulus Power Level
%	Fst		: Temporal Sampling Rate for STRF
%
%RETURNED VARIABLES
%	Std		: Standard deviation for expected y(t)
%
function [Std]=strfstd(STRF1,STRF2,PP,Fst)

%Finding Mean Energy 
Var=0;
for k=1:size(STRF1,1)
	Var=Var+PP*sum(STRF1(k,:).^2)/Fst;
end
for k=1:size(STRF2,1)
	Var=Var+PP*sum(STRF2(k,:).^2)/Fst;
end
Std=sqrt(Var);

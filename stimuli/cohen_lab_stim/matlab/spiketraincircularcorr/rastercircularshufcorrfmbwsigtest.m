%
%function [H,p]=rastercircularshufcorrfmbwsigtest(RDataAA,RDataB,alpha,flag)
%
%   FILE NAME       : RASTER CIRCULAR SHUF CORR FM BW SIG TEST
%   DESCRIPTION     : Performs a significance test on the shuffled
%                     correaltion using jackknife samples. Organized to
%                     test significance for various FM and BW conditions.
%
%   RDataA          : Data structure containing Jackknife shuf correlation
%                     for data 
%   RDataB          : Data structure containing Jackknife shuf correlation
%                     for the reference spike train (typically a Poisson of
%                     equal firing rate)
%   alpha           : Significance level
%   flag            : 'MI' or 'REL', default=='REL'
%
%RETURNED VALUES
%
%   H               : Matrix of 0 or 1, null hypothesis MI or REL are equal is
%                     rejected if H=0
%   p               : Matrix containing significance probability
%
% (C) Monty A. Escabi, Oct 2013
%
function [H,p]=rastercircularshufcorrfmbwsigtest(RDataA,RDataB,alpha,flag)

%Input Args
 if nargin<4
    flag='REL';
 end
  
%Significance Testing
for k=1:size(RDataA,2)
    for l=1:k
        [H(l,k),p(l,k)]=rastercircularshufcorrsigtest(RDataA(l,k),RDataB(l,k),alpha,flag);
    end
end
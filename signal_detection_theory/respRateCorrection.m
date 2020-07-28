function [rate1] = respRateCorrection(rate0,n,type)

%% function [rate1] = respRateCorrection(rate0,n)
%
% this function adjusts response rates == 0 or 1 according to
% http://www.kangleelab.com/sdt-d-prime-calculation---other-tips.html
% 
% INPUTS:
%  - rate0: uncorrected detection rates
%  - n: number of trials contributing to this rate
%  - type: if type is 


rate0(rate0 == 0) = 1./(2*n(rate0==0));
rate0(rate0 == 1) = 1-(1./(2*n(rate0==1)));

rate1 = rate0;


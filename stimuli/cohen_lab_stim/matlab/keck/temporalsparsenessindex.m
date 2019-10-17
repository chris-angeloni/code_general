%
%function [TSI]=temporalsparsenessindex(spet,Fs,tau)
%
%       FILE NAME   : Temporal Sparseness Index
%       DESCRIPTION : Temporal sparness metric based on integration time
%                     and ISI cumulative distribution. The TSI is defined
%                     as:
%
%                     TSI = 1 - CDF_isi(tau)
%
%                     Note the the TSI corresponds to 1 - fraction of
%                     spikes pairs that fall within one integration time.
%
%       spet        : Spike event times
%       Fs          : Sampling rate (Hz)
%       tau         : Integration time from STRF in msec
%
%RETURNED PARAMETERS
%
%       TSI         : Temporal sparseness index
%
% (C) Monty A. Escabi, Oct 2009
%
function [TSI]=temporalsparsenessindex(spet,Fs,tau)

%Computing TSI
ISI=diff(spet)/Fs;
tau=tau/1000;
i=find(ISI<tau);
TSI=1 - length(i)/length(ISI); %TSI is the fraction of ISIs that are > one time-constant
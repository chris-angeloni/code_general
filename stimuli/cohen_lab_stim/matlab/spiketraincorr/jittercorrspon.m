%
%function [JitterData]=jittercorrspon(spetA,spetB,Fs,Fsd,T,MaxTau,Disp)
%
%   FILE NAME   : JITTER CORR SPON
%   DESCRIPTION : Generates the shuffled and autocorrelograms used to
%                 estimate spike timing precicison and reliability when
%                 spontaneous firing is present.
%
%   spetA       : Spike train ISI array - trial A
%   spetB       : Spike train ISI array - trail B
%   Fs          : Sampling rate for spetA and spetB
%   Fsd         : Sampling rate for correlation measurement
%   T           : Recording time interval in seconds
%   MaxTau      : Maximum Correlation Delay (msec)
%   Disp        : Display Output (Optional; Default='n')
%
%RETURNED VARIABLES
%
%   JitterData: Data Structure containgin
%       .Tau         : Delay Axis (msec)
%       .Raa         : Autocorrelation
%       .Rab         : Crosscorrelation
%       .RaaS        : ISI shuffled crosscorrelogram
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .lambdap     : Measured spike rate. Ideal spike rate x p.
%
% (C) Monty A. Escabi, Edit Dec 2010
%
function [JitterData]=jittercorrspon(spetA,spetB,Fs,Fsd,T,MaxTau,Disp)

%Input Arguments
if nargin<7
	Disp='n';
end

%Estimating auto and cross correlations
[Rab]=xcorrspikefast(spetA,spetB,Fs,Fsd,MaxTau,T,'n','n','n');
[Raa]=xcorrspikefast(spetA,spetA,Fs,Fsd,MaxTau,T,'y','n','n');
[Rbb]=xcorrspikefast(spetB,spetB,Fs,Fsd,MaxTau,T,'y','n','n');
spetAS=shufflespet(spetA);
spetBS=shufflespet(spetB);
[RaaS]=xcorrspikefast(spetAS,spetAS,Fs,Fsd,MaxTau,T,'y','n','n');
[RbbS]=xcorrspikefast(spetBS,spetBS,Fs,Fsd,MaxTau,T,'y','n','n');
[RabS]=xcorrspikefast(spetAS,spetBS,Fs,Fsd,MaxTau,T,'n','n','n');
Raa=(Raa+Rbb)/2;
RaaS=(RaaS+RbbS)/2;
Rab=(Rab+fliplr(Rab))/2;        %We are correlating k-l and l-k, Rab is now symetric, Dec 2010
RabS=(RabS+fliplr(RabS))/2;     %We are correlating k-l and l-k, Rab is now symetric, Dec 2010

%Estimating Mean Spike Rate including reliability errors
lambdap=length([spetA spetB])/(2*T);
lambdapS=length([spetA spetB])/(2*T);

%Estimating Noise Correlation Function
N=(length(Raa)-1)/2;
%Raa(N+1)=Raa(N+1)-lambdap*Fsd;
%RaaS(N+1)=RaaS(N+1)-lambdapS*Fsd;
Rnoise=Rab-Raa+(RaaS-lambdap^2)/lambdap^2*lambdap^2;
Tau=(-N:N)/Fsd*1000;

%Saving Raw Data in Structure
JitterData.Tau=Tau;
JitterData.Raa=Raa;
JitterData.RaaS=RaaS;
JitterData.Rab=Rab;
JitterData.RabS=RabS;
JitterData.Rnoise=Rnoise;
JitterData.lambdap=lambdap;

%Plotting Results
if strcmp(Disp,'y')
	subplot(211)
	plot(Tau,Raa)
	hold on
	plot(Tau,Rab,'r')
	ylabel('Raa (blue), Rab (red)')
	hold off

	subplot(212)
	plot(Tau,Rnoise)
	xlabel('Delay (msec)')
	ylabel('Rnoise - Jitter Correlation')
	pause(0)
end
%
%function [Tau,Raa,Rab,Rpp,Rmodel,sigma,p,lambda,lambdan]=jittercorrfit2(spetA,spetB,Fs,Fsd,T,MaxTau,Disp)
%
%       FILE NAME       : JITTER CORR FIT
%       DESCRIPTION     : Correlation model to fit Cross-Channel correlation
%			  from RASTERGRAM by a Gaussian function.
%
%	spetA	: Spike train ISI array - trial A
%	spetB	: Spike train ISI array - trail B
%	Fs		: Sampling rate for spetA and spetB
%	Fsd		: Sampling rate for correlation measurement
%	T		: Recording time interval in seconds
%	MaxTau	: Maximum Correlation Delay (sec)
%	Disp	: Display Output (Optional; Default='n')
%
%Returned Variables
%	Tau		: Delay Axis
%	Raa		: Autocorrelation
%	Rab		: Crosscorrelation
%	Rpp		: Raw Data Jitter Distribution Correlation
%	Rmodel	: Model Fitted Jitter Distribution Correlation
%	sigma	: Estimated timing jitter
%	p 		: Estimated trial reproducibility
%	lambda	: Estimated spike rate (hypothetical - 
%			  no jitter or trial reprodicibility errors)
%   lambdan : Estimated spike rate for additive noise component
%
function [Tau,Raa,Rab,Rpp,Rmodel,sigma,p,lambda,lambdan]=jittercorrfit2(spetA,spetB,Fs,Fsd,T,MaxTau,Disp)

%Input Arguments
if nargin<7
	Disp='n';
end

%Estimating auto and cross correlations
[Rab]=xcorrspike(spetA,spetB,Fs,Fsd,MaxTau,'n','n','n');
[Raa]=xcorrspike(spetA,spetA,Fs,Fsd,MaxTau,'n','n','n');
[Rbb]=xcorrspike(spetB,spetB,Fs,Fsd,MaxTau,'n','n','n');
[Rab2sec]=xcorrspike(spetA,spetB,Fs,Fsd,2,'n','n','n');
Rab2sec=mean(Rab2sec(1:Fsd))    %Averages Corr between 1-2 sec
Raa=(Raa+Rbb)/2;

%Estimating Mean Spike Rate
lambda=(length(spetA)+length(spetB))/2/T;

%Estimating Jitter Correlation Function
N=(length(Raa)-1)/2;
%Raa(N+1)=Raa(N+1)-lambda*Fsd;
Raa0=Raa(N+1);
Raa(N+1)=0;
Rpp=Rab-Raa;
Tau=(-N:N)/Fsd;

%Fitting Gaussian Jitter Model to Rpp
[Rmodel,Rpeak,sigma]=corrmodelfit(Rpp,Tau,'n');
[Rmodel]=corrmodel([Rpeak sigma],Tau);

%Finding Optimal Jitter and Reproducibility Parameters
sigma=sigma/1000;
%lambdan=Raa0/Fsd-Rpeak*sqrt(4*pi*sigma^2);
%fun=['lambdan=fsolve(@(lambdan) 2*lambdan^2-2*lambdan*' num2str(Raa0) '/' num2str(Fsd) '+' num2str(Raa0) '^2/' num2str(Fsd) '^2 - ' num2str(Rab2sec) ',[0 1000])];
%lambdan = fsolve(@(lambdan) fun,[0 1000],optimset('Display','off'));
%fun=['lambdan=fsolve(@(lambdan) 2*lambdan^2-2*lambdan*' num2str(Raa0) '/' num2str(Fsd) '+' num2str(Raa0) '^2/' num2str(Fsd) '^2 - ' num2str(Rab2sec) ',[0 1000],optimset('Display','off'));'];

fun=['lambdan=fsolve(@(lambdan) 2*lambdan^2-2*lambdan*' num2str(Raa0) '/' num2str(Fsd) '+' num2str(Raa0) '^2/' num2str(Fsd) '^2 - ' num2str(Rab2sec) ',[1000]);'];
eval(fun)
%lambdan = fsolve(fun,[0 1000]);

%lambdan=(2*Raa0/Fsd+sqrt( 4*Raa0^2/Fsd^2 - 8 * (Raa0^2/Fsd^2-Rab2sec) ))/4;
%lambda=(Rab2sec-lambdan^2)/Rpeak/sqrt(4*pi*sigma^2);  %This EQN is WRONG!!!! 


p=sqrt(Rpeak/lambda*sqrt(4*pi*sigma^2));
p=Rpeak*sqrt(4*pi*sigma^2)/(Raa0/Fsd-lambdan);
sigma=sigma*1000;

%Plotting Results
if strcmp(Disp,'y')
	subplot(211)
	plot(Tau*1000,Raa)
	hold on
	plot(Tau*1000,Rab,'r')
	ylabel('Raa (blue), Rab (red)')
	hold off

	subplot(212)
	plot(Tau*1000,Rpp)
	xlabel('Delay (msec)')
	ylabel('Rpp - Jitter Correlation')
	hold on
	plot(Tau*1000,Rmodel,'r')
	hold off
	pause(0)
end

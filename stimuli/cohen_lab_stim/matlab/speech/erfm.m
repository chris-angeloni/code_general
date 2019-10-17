%
%function [To,FoAvg,FoMid]=erfm(Fo,dFo,Fs,NdB,M,disp)
%	
%	FILE NAME 	: ERFM
%	DESCRIPTION 	: Finds cycle to cycle To using Escabi/Roark
%			  Interpolation Method. Simulated For Frequency
%			  Modulated Sinusoid
%
%	Fo		: Fundamental Frequency
%	dFo		: Fundamental Frequency Perturbation / Modulation
%			  Index
%	Fs		: Sampling Frequency
%	NdB		: Signal to Noise Ration in dB 
%	M		: Aproximate Number of Periods used in simulation
%
%	To		: Extracted Period Array
%	FoAvg		: Actual Fo Averaged over each cycle
%	FoMid		: Actual Fo at Mid Cycle
%	disp		: Display = 'y' or 'n'
% 
function [To,FoAvg,FoMid]=erfm(Fo,dFo,Fs,NdB,M,disp)

%Finding Vector Length
Ts=1/Fs;
N=2^ceil(log10(1/(Ts*Fo)*M)/log10(2));

%Noise Signal
n=10^(-NdB/20)*rand(1,N);

%Modulated Signal
naxis=1:N;
dPHY=cos( 2*pi*dFo*naxis*Ts );
x=sin( 2*pi*Fo*naxis*Ts + dPHY );

%Signal and Noise
y=x + n;

%Finding Fo using ER method
[To,L]=er(y,Fs,1E-12);

%Finding Average Fo over Each Period
taxis=naxis*Ts;
FoAct= Fo - dFo*sin( 2*pi*dFo*taxis );

%Finding ZC - Used to determine Average Fo over each Period
nz=findzc(x);
for k=L:length(nz)-L-1
	FoAvg(k-L+1)=mean(FoAct(nz(k):nz(k+1)));
end

%Finding Fo at the middle of a Period
nzd=findzcd(x);
FoMid=FoAct(nzd(L+1:length(nz)-L));

if disp=='y'
	%Plotting Results
	figure
	subplot(311)
	hold on
	plot(FoAvg,'yo')
	plot(1./To,'ro')
	ylabel('Extracted (Red) and Actual Fo (Yellow)')

	%Error Curve
	subplot(312)
	plot((1./To-FoAvg)./FoAvg*100,'ro')
	ylabel('% Error')

	%Error Curve
	subplot(313)
	plot((1./To-FoMid)./FoMid*100,'ro')
	xlabel('n (observation number)')
	ylabel('% Error')
end

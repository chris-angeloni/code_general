%
%function [To,FoAvg,FoMid]=titzefm(Fo,dFo,Fs,NdB,L,disp)
%	
%	FILE NAME 	: TITZEFM
%	DESCRIPTION 	: Finds cycle to cycle To using Linear 
%			  Interpolation. Simulated For Frequency
%			  Modulated Sinusoid
%
%	Fo		: Fundamental Frequency
%	dFo		: Fundamental Frequency Perturbation / Modulation
%			  Index
%	Fs		: Sampling Frequency
%	NdB		: Signal to Noise Ration in dB 
%	L		: Aproximate Number of Periods used in simulation
%	disp		: Display = 'y' or 'n'
%
function [To,FoAvg,FoMid]=titzefm(Fo,dFo,Fs,NdB,L,disp)

%Finding Vector Length
Ts=1/Fs;
N=2^ceil(log10(1/(Ts*Fo)*L)/log10(2));

%Noise Signal
n=10^(-NdB/20)*rand(1,N);

%Modulated Signal
naxis=1:N;
dPHY=cos( 2*pi*dFo*naxis*Ts );
x=sin( 2*pi*Fo*naxis*Ts + dPHY );

%Signal and Noise
y=x + n;

%Finding Fo using Titze method
[To]=titze(y,Fs);

%Finding Average Fo over Each Period
taxis=naxis*Ts;
FoAct= Fo - dFo*sin( 2*pi*dFo*taxis );

%Finding ZC - Used to determine Average Fo over each Period
nz=findzc(x);
for k=1:length(nz)-1
	FoAvg(k)=mean(FoAct(nz(k):nz(k+1)));
end

%Finding Fo at the middle of a Period
nzd=findzcd(x);
FoMid=FoAct(nzd(2:length(nz)));

%Finding Fo  - Testing
%FsN=100000
%naxisN=1:N*FsN/Fs;
%TsN=1/FsN;
%dPHYN=cos( 2*pi*dFo*naxisN*TsN );
%xN=sin( 2*pi*Fo*naxisN*TsN + dPHYN );
%plot(x)
%pause
%plot(xN)

%nzN=findzc(xN);
%tzc=nzN*1/FsN;
%to=(tzc(1:length(tzc)-1)+tzc(2:length(tzc)))/2;
%FoMid=Fo-dFo*sin(2*pi*dFo*to);

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
	size(FoMid)
	size(To)
	plot((1./To-FoMid)./FoMid*100,'ro')
	xlabel('n (observation number)')
	ylabel('% Error')
end

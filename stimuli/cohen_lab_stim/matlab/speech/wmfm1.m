%
%function [TP,FoAvg]=wmfm1(Fo,dFo,Fs,NdB,L)
%	
%	FILE NAME 	: WMFM1
%	DESCRIPTION 	: Finds cycle to cycle To using Milenkovic's
%			  Waveform Matching Method. Simulated For Frequency
%			  Modulated Sinusoid
%			  Unlike WMFM extracts only one value of TP per cycle
%
%	Fo		: Fundamental Frequency
%	dFo		: Fundamental Frequency Perturbation / Modulation
%			  Index
%	Fs		: Sampling Frequency
%	NdB		: Signal to Noise Ration in dB 
%	L		: Aproximate Number of Periods used in simulation
%	TP		: Extracted Period Array
%	FoAvg		: Actual Fo Array Corresponding to TP
%
function [TP,FoAvg]=wmfm1(Fo,dFo,Fs,NdB,L)

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

%Finding Fo using WM method
[TP,MO]=wm1(y,Fs);

%Finding Average Fo over Each Period
taxis=naxis*Ts;
FoAct= Fo - dFo*sin( 2*pi*dFo*taxis );
[nzd]=findzcd(x);
[nzu]=findzc(x);
for k=1:length(nzu)-1
	FoAvg(k)=mean(FoAct(nzu(k):nzu(k+1)));
end

%Removing first and last 10 Periods
L=10;
FoAvg=FoAvg(L-2:length(TP)+L-3);

%figure
%hold on
%plot(x)
%plot(nzd,x(nzd),'ro')
%plot(nzu,x(nzu),'go')
%pause

%Plotting Results
figure
subplot(211)
hold on
plot(FoAvg,'yo')
plot(1./TP,'ro')
ylabel('Extracted (Red) and Actual Fo (Yellow)')

%Error Curve
subplot(212)
plot((1./TP-FoAvg)./FoAvg*100,'ro')
xlabel('n (observation number)')
ylabel('% Error')

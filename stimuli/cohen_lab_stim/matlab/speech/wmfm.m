%
%function [No,TP,MO]=wmfm(Fo,dFo,Fs,NdB,L)
%	
%	FILE NAME 	: WMFM
%	DESCRIPTION 	: Finds cycle to cycle To using Milenkovic's
%			  Waveform Matching Method. Simulated For Frequency
%			  Modulated Sinusoid
%
%	Fo		: Fundamental Frequency
%	dFo		: Fundamental Frequency Perturbation / Modulation
%			  Index
%	Fs		: Sampling Frequency
%	NdB		: Signal to Noise Ration in dB 
%	L		: Aproximate Number of Periods used in simulation
%
function [No,TP,MO]=wmfm(Fo,dFo,Fs,NdB,L)

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
[No,TP,MO]=wm(y,Fs);

%Actual Signal Fundamental
naxis=No-MO(1):N-No-MO(1);
taxis=naxis*Ts;
FoAct= Fo - dFo*sin( 2*pi*dFo*taxis );

%Plotting Results
figure
subplot(211)
hold on
plot(FoAct,'yo')
plot(1./TP,'ro')
ylabel('Extracted (Red) and Actual Fo (Yellow)')

%Error Curve
subplot(212)
plot((1./TP-FoAct)./FoAct*100,'ro')
xlabel('n (observation number)')
ylabel('% Error')

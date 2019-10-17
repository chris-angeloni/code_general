%
%function [Y,phase,SpecProf,faxis,taxis,AF]=noisegensinc(f1,f2,RD,RP,PFm,App,Fs,phase,fphase,K,MaxRD,MaxFM,Axis,DF,AmpDist)
%	
%	FILE NAME 	: RIP GEN SIN C
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise Generator
%			  via sinusoid bank.
%			  This file is used by RIPNOISEB 
%			  This file is similar to NOISEGENSIN but it allows you
%			  to superimpose an arbitrary number of Moving Ripple
%			  Profiles to Generate a Ripple Noise Profile
% 
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	RD		: Ripple Density Signal
%	RP		: Ripple Phase Signal
%	PFm		: Fine sturcutre modulation phase signal
%       App             : Peak to Peak Riple Amplitude 
%	Fs		: Sampling Rate
%	phase		: Sinusoid Initial Phases
%	fphase		: Bandlimit Frequency of Phase Signal
%	K		: Itteration Number
%	MaxRD		: Maximum Ripple Density
%	MaxFM		: Maximum Amplitude Modulation Frequency
%       Axis            : Carrier Freqeuncy Axis Type: 'log' or 'lin'
%	DF		: Temporal Dowsampling Factor For Spectral Profile
%
%RETURNED VALUE
%
%	Y		: Ripple noise array
%	phase		: Phase array for all carriers
%	SpecProf	: Spectral profile signal
%	faxis		: Frequency axis
%	taxis		: Time axis
%	AF		: Fine structure amplitude modulation
%
function [Y,phase,SpecProf,faxis,taxis,AF]=noisegensinc(f1,f2,RD,RP,PFm,App,Fs,phase,fphase,K,MaxRD,MaxFM,Axis,DF,AmpDist)

%Parameters
N=32;				%Noise Reconstruction Size  ->> Before changing check RIPNOISE!!!
LL=1000;			%Noise Upsampling Factor    ->> Before changing check RIPNOISE!!!
M=N*LL;				%Number of samples

%Log Frequency Axis
NS=length(phase);
if Axis=='log'
        XMax=log2(f2/f1);
        X=(0:NS-1)/(NS-1)*XMax;
        faxis=f1*2.^X;
else
        faxis=(0:NS-1)/(NS-1)*(f2-f1)+f1;
        X=log2(faxis/f1);
end

%Full Ripple Spectrum Noise
Y=zeros(length(App),M);
for k=1:NS

	%Display
	clc
	disp(['Carier : ' int2str(k) ' of ' int2str(NS)])

	%Finding Carrier Phase Signal so that variability in phase
	%Is Uniformly distributed in [-df/2 , df/2]
	if strcmp(Axis,'lin')
		df=(faxis(2)-faxis(1))*(noiseunif(fphase,Fs/LL,N*2)-.5);
		dphase=2*pi*intfft(df)/(Fs/LL);
		dphase=dphase(1:N);
		dphase=interp10(dphase,3);
		dphase=dphase  - dphase(1) + phase(k);
		phase(k)=dphase(M);
	else
		dphase=phase(k);
	end

	%Generating Ripple Spectral Profile Modulators with fine structure modulations
	A=zeros(1,N*LL);
	A=sin( 2*pi*RD(:)*X(k)+ RP(:) )'+1 ;
	A=A.*(sin(PFm)+1)/4;

	if strcmp(AmpDist,'lin')

		%Modulating for Multiple values of App ( Linear Case )
                for i=1:length(App-1)
                        %Modulating Carriers/Expanding Dynamic Range -> [-App,0]
			Y(i,:)= Y(i,:) + ( A*( 1-10^(-App(i)/20) )+10^(-App(i)/20) ).* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );
                end

	elseif strcmp(AmpDist,'dB')

		%Converting to Linear Scale and 
		%Compresing Dynamic Range to [-1 , 0]
		A=A-1;

		%Modulating for Multiple values of App
		for i=1:length(App)
			%Modulating Carriers/Expanding Dynamic Range->[-App,0]
			Y(i,:)= Y(i,:) + 10.^(App(i)*A/(20)) .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );
		end

	else

                %Converting to Linear Scale and
                %Compresing Dynamic Range to [-1 , 0]
		A=A-1;

		%Modulating for Multiple values of App ( dB Case ) 
		for i=1:length(App)-1
			%Modulating Carriers/Expanding Dynamic Range-> [-App,0]
			Y(i,:)= Y(i,:) + 10.^( App(i)*A/20 ) .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );
		 end

		%Modulating Linear Carrier
		i=i+1;
                Y(i,:) = Y(i,:) + ( (A+1)*( 1-10^(-App(i)/20) ) + 10^(-App(i)/20) ) .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );

	end

end

%Generating Spectral Profile to Save
%Downsample RP and RD by DF
SpecProf=zeros(length(X),length(RD(1:DF:M)));
for k=1:length(X)
	%Moving Ripple Profile
	SpecProf(k,:)= sin( 2*pi*RD(1:DF:M)*X(k)+RP(1:DF:M) ) ;
end

%Converting to Linear Scale and 
%Compresing Dynamic Range to [-1 , 0]
SpecProf=1/2*(SpecProf-1);

%Generating Fine Structure Envelope
AF=(sin(PFm(1:DF:M))+1)/2;

%Defining Time Axis
taxis=(0:length(RD(1:DF:M))-1)/Fs*DF;


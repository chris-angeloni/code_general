%
%function [Y,phase,SpecProf,faxis,taxis]=noisegensind(f1,f2,RD,RP,PFm,dFm,App,Fs,phase,fphase,K,MaxRD,MaxFM,DF,AmpDist,NS)
%	
%	FILE NAME 	: RIP GEN SIN D
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
%	dFm		: Fine structure instantenous difference
%			  frequency signal - Pitch
%       App             : Peak to Peak Riple Amplitude 
%	Fs		: Sampling Rate
%	phase		: Sinusoid Initial Phases
%	fphase		: Bandlimit Frequency of Phase Signal
%	K		: Itteration Number
%	MaxRD		: Maximum Ripple Density
%	MaxFM		: Maximum Amplitude Modulation Frequency
%	DF		: Temporal Dowsampling Factor For Spectral Profile
%	NS		: Number of spectral samples for Spectral Profile
%
%RETURNED VALUE
%
%	Y		: Ripple noise array
%	phase		: Phase array for all carriers
%	SpecProf	: Spectral profile signal
%	faxis		: Frequency axis
%	taxis		: Time axis
%
function [Y,phase,SpecProf,faxis,taxis]=noisegensind(f1,f2,RD,RP,PFm,dFm,App,Fs,phase,fphase,K,MaxRD,MaxFM,DF,AmpDist,NS)

%Parameters
N=32;				%Noise Reconstruction Size  ->> Before changing check RIPNOISE!!!
LL=1000;			%Noise Upsampling Factor    ->> Before changing check RIPNOISE!!!
M=N*LL;				%Number of samples

%Time Axis
taxis=K*M+(1:M)/Fs;

%Initializing Instantenous Phase and Carrier Frequency Profile
k   = 1;
fc  = f1+k*dFm;
pfc = 2*pi*f1*taxis+k*PFm + phase(k);
X   = log2(fc/f1);

plot(taxis,pfc)
hold on
pause

%Generating Ripple Spectrum Noise
Y=zeros(length(App),M);
k=1;
while min(X) < log2(f2/f1)	%Stops when all carriers exceed f2

	%Display
	clc
	disp(['Carier : ' int2str(k) ' of possible ' int2str(length(phase))])

	%Generating Ripple Spectral Profile Modulator
	A=zeros(1,N*LL);
	A=(sin( 2*pi*RD.*X + RP ) + 1)/2 ;

	%Window to remove spectral edge discontinuities 
	alpha=0.025;
	[FF,W]=hproto(3,alpha,9750,fc-10000,'n');

	%Modulating Carriers and Summing	
	if strcmp(AmpDist,'lin')

		%Modulating for Multiple values of App ( Linear Case )
		for i=1:length(App-1)

			%Epsilon
			e=10^(-App(i)/20)

			%Modulating Carriers/Expanding Dynamic Range -> [-App,0]
			Y(i,:) = Y(i,:) + 1./fc.^.5 .* W .* ( A*(1-e)+e ).* sin( pfc );

		end

	elseif strcmp(AmpDist,'dB')
              
		%Converting to Linear Scale and
                %Compresing Dynamic Range to [-1 , 0]
		A=A-1;

		%Modulating for Multiple values of App
		for i=1:length(App)

			%Modulating Carriers/Expanding Dynamic Range->[-App,0]
			Y(i,:) = Y(i,:) + 1./fc.^.5 .* W .* 10.^(App(i)*A/(20)) .* sin( pfc );

		end

	else

                %Converting to Linear Scale and
                %Compresing Dynamic Range to [-1 , 0]
		A=A-1;

		%Modulating for Multiple values of App ( dB Case ) 
		for i=1:length(App)-1
			%Modulating Carriers/Expanding Dynamic Range-> [-App,0]
			Y(i,:) = Y(i,:) + 1./fc.^.5 .* W .* 10.^( App(i)*A/20 ) .* sin( pfc );
		 end

		%Modulating Linear Carrier
		i=i+1;

		%Epsilon
		e=10^(-App(i)/20)

		%Modulating Carriers/Expanding Dynamic Range -> [-App,0]
		Y(i,:) = Y(i,:) + 1./fc.^.5 .* W .* ( A*(1-e)+e ).* sin( pfc );

	end

	%Incrementing Counter
	k=k+1;

	%Finding Instantenous Phase and Carrier Frequency Profile
	fc  = f1+k*dFm;
	pfc = 2*pi*f1*taxis + k*PFm + phase(k);
	X   = log2(fc/f1);

	%Find Components that are > f2 and setting to zero
	index=find(fc>f2);
	if length(index)>1
		pfc(index)=zeros(size(index));
	end

end

%Making Energy Uniform For All Times
%Note that the Energy Varies With Time 
%Since the Number of Carriers Changes With Time
LT=(f2-f1)./dFm;
Y=Y./sqrt(LT);

%Octave Frequency Axis
XMax=log2(f2/f1);
X=(0:NS-1)/(NS-1)*XMax;
faxis=f1*2.^X;

%Generating Spectral Profile to Save
%Note log freq axis despite the fact that carriers are linearly spaced
%Downsample RP and RD by DF
SpecProf=zeros(length(X),length(RD(1:DF:M)));
for k=1:length(X)
	%Moving Ripple Profile
	SpecProf(k,:)= sin( 2*pi*RD(1:DF:M)*X(k)+RP(1:DF:M) ) ;
end

%Converting to Linear Scale and 
%Compresing Dynamic Range to [-1 , 0]
SpecProf=1/2*(SpecProf-1);

%Defining Time Axis
taxis=(0:length(RD(1:DF:M))-1)/Fs*DF;


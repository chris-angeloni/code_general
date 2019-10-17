%
%function [Y,phase,SpecProf,faxis,taxis]=noisegensin(f1,f2,RD,RP,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,AmpDist,calib)
%	
%	FILE NAME 	: RIP GEN SIN
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise Generator
%			  via sinusoid bank.
%
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	RD		: Ripple Density Signal
%	RP		: Ripple Phase Signal
%       App             : Peak to Peak Riple Amplitude 
%	Fs		: Sampling Rate
%	phase		: Sinusoid Initial Phases
%	fphase		: Bandlimit Frequency of Phase Signal
%	K		: Itteration Number
%	NB		: Number of Blocks to divide parameter space into
%                         Note that number of ripple components is NBxNB
%	MaxRD		: Maximum Ripple Density
%	MaxFM		: Maximum Amplitude Modulation Frequency
%       Axis            : Carrier Freqeuncy Axis Type: 'log' or 'lin'
%	DF		: Temporal Dowsampling Factor For Spectral Profile
%	calib		: Speaker Callibration Data Structure (Optional)
%
function [Y,phase,SpecProf,faxis,taxis]=noisegensin(f1,f2,RD,RP,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,AmpDist,calib)

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

%Generate Inverse Filter For Calibration (Optional)
if exist('calib')
	Hinv=ripplecalibrate(calib,faxis);
else
	Hinv=ones(size(faxis));		%No Calibration
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

	%Generating Spectral Profile Modulators
	A=zeros(1,N*LL);
	n=1;
	for i=1:NB
		for j=1:NB
			A=A + sin( 2*pi*RD(n,:)*X(k)+ RP(i+(j-1)*NB,:) ) ;
			n=n+1;
		end
	end

	if strcmp(AmpDist,'lin')

		%Converting to Linear Scale and
		%Compresing Dynamic Range to [0 , 1]
		if NB>1
			A=A/sqrt(NB*NB/2);
			A=norm2unif(A,0,1,'erf1',0,1);
		else
			A=(A+1)/2;
		end

		%Modulating for Multiple values of App ( Linear Case )
                for i=1:length(App-1)
                        %Modulating Carriers and Expanding Dynamic Range -> [-App,0]
			Y(i,:)= Y(i,:) +  Hinv(k) * ( A*( 1-10^(-App(i)/20) )+10^(-App(i)/20) )  .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );
                end

	elseif strcmp(AmpDist,'dB')

		%Converting to Linear Scale and 
		%Compresing Dynamic Range to [-1 , 0]
		if NB>1
			A=A/sqrt(NB*NB/2);
			A=norm2unif(A,-1,0,'erf1',0,1);
		else
			A=(A-1)/2;
		end

		%Modulating for Multiple values of App
		for i=1:length(App)
			%Modulating Carriers and Expanding Dynamic Range -> [-App,0]
			Y(i,:)= Y(i,:) + Hinv(k) * 10.^(App(i)*A/(20)) .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );
		end

	else

                %Converting to Linear Scale and
                %Compresing Dynamic Range to [-1 , 0]
                if NB>1
                        A=A/sqrt(NB*NB/2);
                        A=norm2unif(A,-1,0,'erf1',0,1);
                else
                        A=(A-1)/2;
                end

		%Modulating for Multiple values of App ( dB Case ) 
		for i=1:length(App)-1
			%Modulating Carriers and Expanding Dynamic Range -> [-App,0]
			Y(i,:)= Y(i,:) + Hinv(k) * 10.^(App(i)*A/(20)) .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );
		 end

		%Modulating Linear Carrier
		i=i+1;
                Y(i,:) = Y(i,:) + Hinv(k) * ( (A+1)*( 1-10^(-App(i)/20) ) + 10^(-App(i)/20) )  .* sin( 2*pi*faxis(k)*(K*M+1:(K+1)*M)/Fs + dphase );

	end

end

%Generating Spectral Profile to Save
%Downsample RP and RD by DF
SpecProf=zeros(length(X),length(RD(1:DF:M)));
for k=1:length(X)
	n=1;
	for i=1:NB
		for j=1:NB
			%Adding NB*NB Ripple Profiles
			SpecProf(k,:)=SpecProf(k,:) + sin( 2*pi*RD(n,1:DF:M)*X(k)+RP(i+(j-1)*NB,1:DF:M) ) ;
			n=n+1;
		end
	end
end

%Converting to Linear Scale and 
%Compresing Dynamic Range to [-1 , 0]
if NB>1
	SpecProf=SpecProf/sqrt(NB*NB/2);
	SpecProf=norm2unif(SpecProf,-1,0,'erf1',0,1);
else
	SpecProf=1/2*(SpecProf-1);
end

%Defining Time Axis
taxis=(0:length(RD(1:DF:M))-1)/Fs*DF;


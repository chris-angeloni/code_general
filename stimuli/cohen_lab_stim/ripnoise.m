%
%function []=ripnoise(filename,f1,f2,fRD,fFM,MaxRD,MaxFM,App,M,Fs,NS,NB,Axis,Block,DF,AmpDist,seed,calib)
%
%	
%	FILE NAME 	: RIP NOISE
%	DESCRIPTION 	: Genrates Dynamic Moving Ripple and Ripple Noise
%			  Save sound as a 'float' file
%			  Saves Spectral Profile as a continuous SPR file
%
%	filename	: Ouput data file name
%       f1              : Lower carrier frequency
%       f2              : Upper carrier Frequency
%	fRD		: Ripple Density Bandlimit Frequency
%	fFM		: Temporal Modulation Bandlimit Frequency
%	MaxRD		: Maximum Ripple Density ( Cycles / Octaves )
%	MaxFM		: Maximum Modulation Frequency ( Hz )
%       App             : Peak to Peak Riple Amplitude ( dB )
%       M               : Number of Samples
%       Fs              : Sampling Rate
%	NS		: Number of Sinusoids Cariers used for ripple Noise
%	NB		: Number of Blocks to divide parameter space into
%			  or the number of Ripples Profiles to Add
%			  Note that number of ripple components is NBxNB
%	Axis            : Carrier Freqeuncy Axis Type: 'log' or 'lin'
%			  Default = 'lin'
%	Block		: Breaks up the Fm vs. RD parameter space into
%			  NBxNB discrete blocks, 'y' or 'n', Default : 'n'
%	DF		: Temporal Dowsampling Factor For Spectral Profile
%			  Must Be an Integer
%	AmpDist		: Modulation Amplitude Distribution
%			  'dB'   = Uniformly Distributed on dB Scale
%			  'lin'  = Uniformly Distributed on linear Scale
%			  'both' = Designs Signals with both
%				   Uses the last element in the App Array to 
%				   Designate the modulation depth for 'lin'
%	seed		: Starting random seed for generating ripple noise or 
%			  dynamic moving ripple parameters (Default=1)
%	calib		: Speaker Callibration Data Structure (Optional)
%
function []=ripnoise(filename,f1,f2,fRD,fFM,MaxRD,MaxFM,App,M,Fs,NS,NB,Axis,Block,DF,AmpDist,seed,calib)

%Parameter Conversions
N=32;				%Noise Reconstruction Size  ->> Before changing check ripgensin!!!
LL=1000;			%Noise Upsampling Factor    ->> Before changing check ripgensin!!!
Fsn=Fs/LL;			%Noise Sampling Frequency
Mn=M/LL;			%Noise Signal Length
Mnfft=2^(ceil(log2(Mn)));	%Used for Signal Generation
fphase=5*fRD;			%Temporal Phase Signal Bandlimit Frequency
fphase=2;

%Log Frequency Axis
if Axis=='log'
	XMax=log2(f2/f1);
	X=(0:NS-1)/(NS-1)*XMax;
	faxis=f1*2.^X;
else
	faxis=(0:NS-1)/(NS-1)*(f2-f1)+f1;
	X=log2(faxis/f1);
end

%Generating Ripple Density Signal (Uniformly Distributed Between [0 , MaxRD] )
count=1;
if exist('seed')
	seedt=seed;
else
	seedt=1;
end
for k=1:NB
	for l=1:NB
		if Block=='y'
			RD(count,:)=(k-1)*MaxRD/NB ,...
			+ MaxRD/NB*noiseunif(fRD,Fsn,Mnfft,seedt);
		else
			RD(count,:)=MaxRD*noiseunif(fRD,Fsn,Mnfft,seedt);
		end
		count=count+1;
		seedt=seedt+1;
	end
end

%Generating the Teporal Modulation Signal 
%Signal Varies Between [-MaxFM , MaxFM]
count=1;
if exist('seed')
	seedt=seed;
else
	seedt=1;
end
for k=1:NB
	for l=1:NB
		FM1=noiseunif(fFM,Fsn,Mnfft,seedt+NB^2+1);
		if Block=='y'
			FM(count,:)=FM1*2*MaxFM/NB + 2*MaxFM/NB*(NB/2-k);
		else
			FM(count,:)=2*MaxFM*(FM1-.5);
		end
		count=count+1;
		seedt=seedt+1;
	end
end

%Genreating Ripple Phase Components
%Note that: RP = 2*pi/Fsn*intfft(FM);
for k=1:NB*NB
	RP(k,:)=2*pi/Fsn*intfft(FM(k,:));
end

%Initial Carrier Sinusoid Phases 
phase=2*pi*rand(1,NS);

%For Displaying Statistics
%figure(1),hist(RD,100),title('Rippe Density Distribution')
%figure(2),hist(FM,100),title('Modulation Frequency Distribution')
%figure(3),plot((1:length(FM))/Fsn,FM),title('Modulation Frequency')
%figure(4),plot((1:length(RD))/Fsn,RD),title('Rippe Density')
%save data RD FM RP Fsn

%Generating Ripple Noise
K=0;
flag=0;		%Marks Last segment
for k=2:N:Mn-N-1

	%Extracting RD and RP Noise Segment 
	RDk    = RD(:,k-1:k+N-1);
	RPk    = RP(:,k-1:k+N-1);

	%Interpolating RD and RP
	MM=length(RDk)-1;
	RDint   = interp10(RDk,3);
	RPint   = interp10(RPk,3);
	RDint   = RDint(:,1:N*LL);
	RPint   = RPint(:,1:N*LL);

if K/2==round(K/2)
%plot((1:N*LL)+K*N*LL,RDint,'r.')
else
%plot((1:N*LL)+K*N*LL,RDint,'y.')
end
%hold on
%pause(0)

	%Generating Ripple Noise
	if exist('calib')
	[Y,phase,SpecProf,faxis,taxis]=noisegensin(f1,f2,RDint,RPint,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,AmpDist,calib);
	else
	[Y,phase,SpecProf,faxis,taxis]=noisegensin(f1,f2,RDint,RPint,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,AmpDist);
	end
	clear RDint RPint

	%Saving Sound Files
	if strcmp(AmpDist,'lin')

		%Saving Lin AmpDist
		for i=1:length(App)
			tofloat([filename int2str(App(i)) 'Lin.bin'],Y(i,:));
		end

	elseif strcmp(AmpDist,'dB')

		%Saving dB AmpDist
		for i=1:length(App)
			tofloat([filename int2str(App(i)) 'dB.bin'],Y(i,:));
		end

	else
	
		%Saving dB AmpDist
		for i=1:length(App)-1
			tofloat([filename int2str(App(i)) 'dB.bin'],Y(i,:));
		end

		%Saving Lin AmpDist
		tofloat([filename int2str(App(i+1)) 'Lin.bin'],Y(i+1,:));

	end
	clear Y

	%Writing Spectral Profile File as 'float' file
	NT=length(taxis);
	NF=length(faxis);
	tofloat([filename '.spr'],reshape(SpecProf,1,NT*NF));
	clear SpecProf 

	%Updating Display
	K=K+1;
	clc
	disp(['Segment ' num2str(K) ' Done'])

	%Saving Parameters Just in Case it Does Not Reach End
	if K==1
		%Saving Parameters
		v=version;
		f=['save ' filename '_param'];
	end

end

%Saving Parameters
clear RPint RDint RDk RPk k K Y flag f count FM1 filenumber MM ans l;
v=version;
if strcmp(v(1),'5')
	f=['save ' filename '_param -v4'];
	eval(f)
else
	f=['save ' filename '_param'];
	eval(f)
end

%Closing All Opened Files
fclose('all');

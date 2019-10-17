%
%function [DataSTC]=rtwstrfdbstc(SpecFile,T1,T2,spet,Trig,Fss,SPL,MdB,Sound,NBlocks,fchan)
%
%   FILE NAME   : RT WSTRF DB STC
%   DESCRIPTION : Real Time spectro-temporal receptive field based
%                 on spike triggered covariance. 
%                 Uses Lee/Schetzen Aproach via Specto-Temporal Envelope
%                 For dB Amplitude Sound distributions 
%
%	SpecFile	: Spectral Profile File Header
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%                 T E [- T1 , T2 ], Note that T1 and T2 > 0
%	spet		: Array of spike event times in sample number
%	Trig		: Array of Trigger Times
%	Fss         : Sampling Rate for TRIGGER and SPET
%	SPL         : Signal RMS Sound Pressur
%	MdB         : Signal Modulation Index in dB
%	Sound		: Sound Type 
%                 Moving Ripple	: MR ( Default )
%                 Ripple Noise	: RN
%	NBlocks		: Number of Blocks Between Displays
%   fchan       : Indices for frequency channel used to compute STC
%
%	RETURNED VALUES 
%
%   DataSTCB    : Data structure containing Bootstrap segments for STC
%                 .taxis		- Time Axis
%                 .faxis		- Frequency Axis (Hz)
%                 .STC1 , STC2	- Spectro-Temporal Spike Triggered
%                                 Covaraince. The STC is not normalized by
%                                 the power or by the number of spikes
%                                 (technically its a spike triggered sum of
%                                 the waveform outer products).
%                 .PP           - Power Level
%                 .Wo1, Wo2     - Zeroth-Order Kernels ( Average Number of Spikes / Sec )
%                 .No1, No2     - Number of Spikes
%                 .SPLN         - Sound Pressure Level per Frequency Band
%
function [DataSTC]=rtwstrfdbstc(SpecFile,T1,T2,spet,Trig,Fss,SPL,MdB,Sound,NBlocks,fchan)

%Parameters
NTrig=length(Trig);

%Loading Parameter Data
ParamFile=[SpecFile '_param.mat'];
f=['load ' ParamFile];
eval(f);
clear App  MaxFM XMax Axis MaxRD RD f phase Block Mn RP f1 f2 Mnfft FM N fFM fRD NB NS LL filename M X fphase Fsn

%Downsampling the number of frequency channels
faxis=faxis(fchan);
NF=length(faxis);

%Fliping Trig and Spet for channel 2 and channel 1 STRFs
MinTime=min([Trig spet]);
MaxTime=max([Trig spet]);
spet=spet-MinTime+1;
Trig=Trig-MinTime+1;

%Converting Temporal Delays to Sample Numbers
N1=round(T1*Fs/DF);
N2=round(T2*Fs/DF);
 
%Initializing Some Variables
No1=0;				%Number of Spikes for channel 1
No2=0;				%Number of Spikes for channel 2
STC1=zeros(N1+N2,N1+N2,NF);		%Receptive Field  for channel 1
STC2=zeros(N1+N2,N1+N2,NF);		%Receptive Field  for channel 2

%Fiding Mean Spectral Profile and RMS Power
SPLN=SPL-10*log10(NF);              % Normalized SPL per frequency band
if strcmp(Sound,'RN')
    RMSP=-MdB/2;					% RMS value of normalized Spectral Profile
    PP=MdB^2/12;					% Modulation Depth Variance 
elseif strcmp(Sound,'MR')
    RMSP=-MdB/2;					% RMS value of normalized Spectral Profile
    PP=MdB^2/8;					    % Modulation Depth Variance 
end

%Computing Spectrotemporal STC
for m=1:NF
    %Opening Spectral Profile File
    load([SpecFile '_ch' int2strconvert(m,3) '.mat']);

	%Initializing First and Second Spectral Profile Segments
    S1=Sk(1:NT);
	S2=Sk(NT+1:2*NT);
	S3=Sk(2*NT+1:3*NT);
    
    %Initializing Some Variables
    No1=0;				%Number of Spikes for channel 1
    No2=0;				%Number of Spikes for channel 2
    TrigCount=2;
    
	%Loading Data and Computing 'dB' STRF
	while TrigCount<length(Trig)-1

		%Finding SPET in between triggers
		index1=find(spet>=Trig(TrigCount) & spet<Trig(TrigCount+1));
		index2=find(spet>Trig(NTrig-TrigCount+1) & spet<=Trig(NTrig-TrigCount+2));

		%Resampling spet relative to the Spectral Profile samples
		spettrig1=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF );
		spettrig2=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF );

		%Finding Receptive Field for Channel 1
		epsilon=10^(-MdB/20);
		for k=1:length(spettrig1)

			%Setting Spike Time and STRF length
			M=size(S1);,M=M(2);
			L=spettrig1(k);

			%Averaging Pre-Event Spectral Profiles
			if L < N2
                S=MdB*[S1(M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP;
				STC1(:,:,m)=STC1(:,:,m)+ S'*S;
			elseif L+N1 > M
                S=MdB*[S2(L-N2+1:M) S3(:,1:N1-M+L)] - RMSP;
				STC1(:,:,m)=STC1(:,:,m)+ S'*S;
            else
                S=MdB*[S2(L-N2+1:L+N1)] - RMSP;
				STC1(:,:,m)=STC1(:,:,m)+ S'*S;
			end

			%Counting the number of Spikes averaged
			No1=No1+1;

		end

		%Finding Receptive Field for Channel 2
		for k=1:length(spettrig2)
	
			%Setting Spike Time and STRF length
			M=size(S1);,M=M(2);
			L=spettrig2(k);

			%Averaging Pre-Event Spectral Profiles
			if L < N1
                S=MdB*[S1(M-(N1-L-1):M) S2(:,1:L+N2)] - RMSP;
				STC2(:,:,m)=STC2(:,:,m)+ S'*S;
			elseif L+N2 > M
                S=MdB*[S2(L-N1+1:M) S3(:,1:N2-M+L)] -RMSP;
				STC2(:,:,m)=STC2(:,:,m)+ S'*S;
            else
                S=MdB*[S2(L-N1+1:L+N2)] - RMSP;
				STC2(:,:,m)=STC2(:,:,m)+ S'*S;
			end

			%Counting the number of Spikes averaged
			No2=No2+1;

		end

		%Reading Spectral Profile Data File
		S1=S2;
		S2=S3;
		S3=Sk((TrigCount+1)*NT+1:(TrigCount+2)*NT);
        
		%Updating Trigger Counter
		TrigCount=TrigCount+1;
		clc
		disp(['Block Number ' num2str(TrigCount) ' of ' num2str(NTrig)])

		%Sending To Display - Updates every NBlocks
		if TrigCount/NBlocks==round(TrigCount/NBlocks)
			T=min([ ( Trig(TrigCount) - Trig(1) )/Fss  (max(spet) - min(spet))/Fss]);
			Wo1=No1/T;
			Wo2=No2/T; 
			taxis=(-N1:N2-1)/(Fs/DF);
			subplot(211)

			%Displaying STC1
			%pcolor(taxis,log2(faxis/500),Wo1/PP*fliplr(STC1)/No1*sqrt(PP))
            imagesc(STC1(:,:,m))
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(No1) ' ( Spikes ), Wo = ' num2str(Wo1,5) ' ( Spikes/Sec )'])

			%Displaying STC2
			subplot(212)
			%pcolor(taxis,log2(faxis/500),Wo2/PP*STC2/No2*sqrt(PP))
            imagesc(STC2(:,:,m))
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(No2) ' ( Spikes ) , Wo = ' num2str(Wo2,5) ' ( Spikes/Sec )'])
			pause(0)
		end
	end

	%Normalizing 'dB' STRF According to Paper by Van Dijk
	if max(spet)>max(Trig)
		T=( max(Trig) - min(Trig) )/Fss;
	else
		T=( max(spet) - min(spet) )/Fss;
	end
	if ~( T==0 | isempty(T) )
		Wo1=No1/T;
		Wo2=No2/T;
	else
		No1=-9999;						%No Spikes in SPET
		No2=-9999;
    end
end

%Generating Time Axis
taxis=(-N1:N2-1)/(Fs/DF);

%Adding Elements to Data Structure
DataSTC.taxis=taxis;
DataSTC.faxis=faxis;
DataSTC.STC1=STC1;
DataSTC.STC2=STC2;
DataSTC.PP=PP;
DataSTC.Wo1=Wo1;
DataSTC.Wo2=Wo2;
DataSTC.No1=No1;
DataSTC.No2=No2;
DataSTC.T=T;
DataSTC.SPLN=SPLN;
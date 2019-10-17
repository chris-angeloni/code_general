%
%function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2]=rtwstrfspec(SpecFile,T1,T2,spet,Trig,Fss,SPL,NBlocks)
%
%       FILE NAME       : RT WSTRF SPEC
%       DESCRIPTION     : Real Time 2nd order spectro-temporal Wiener Receptive Field
%			  Uses Lee/Schetzen Aproach via Spectogram Transform
%
%	SpecFile	: Spectral Profile File
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%			  T E [ T1 , T2 ]
%	spet		: Array of spike event times in sample number
%	Trig		: Array of Trigger Times
%	Fss		: Sampling Rate for TRIGGER and SPET
%	SPL		: Signal RMS Sound Pressure Level
%	NBlocks		: Number of Blocks Between Displays
%	
%	RETURNED VALUES 
%
%	taxis		: Time Axis
%	faxis		: Frequency Axis (Hz)
%	STRF1 , STRF2	: Spectro-Temporal Receptive Field
%	PP		: Power Level
%	Wo1, Wo2	: Zeroth-Order Kernels ( Average Number of Spikes / Sec )
%	No1, No2	: Number of Spikes
%
function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2]=rtwstrfspec(SpecFile,T1,T2,spet,Trig,Fss,SPL,NBlocks)

%Parameters
NTrig=length(Trig);

%Loading Parameter Data
index=findstr(SpecFile,'.spr');
ParamFile=[SpecFile(1:index(1)-1) '_param.mat'];
f=['load ' ParamFile];
eval(f);
clear App  MaxFM XMax Axis MaxRD RD f phase Block Mn RP f1 f2 Mnfft FM N fFM fRD NB NS LL filename M X fphase Fsn

%Fliping Trig and Spet for channel 2 and channel 1 STRFs
MinTime=min([Trig spet]);
MaxTime=max([Trig spet]);
spet=spet-MinTime+1;
Trig=Trig-MinTime+1;

%Converting Temporal Delays to Sample Numbers
N1=round(T1*Fs/DF);
N2=round(T2*Fs/DF);
 
%Opening Spectral Profile File
fid=fopen(SpecFile);

%Initializing Some Variables
TrigCount=2;
No1=0;				%Number of Spikes for channel 1
No2=0;				%Number of Spikes for channel 2
STRF1=zeros(NF,N1+N2);		%Receptive Field  for channel 1
STRF2=zeros(NF,N1+N2);		%Receptive Field  for channel 2

%Finding Signal RMS Sound Pressure from SPL
Po=2.2E-5;              % Threshold of Hearing at 1KHz in Pascals
P= Po*10^(SPL/20);      % Pressure conversion
PP=P*P;                 % Power spectrum

%Finding RMS value of the input spectrogram
%S=reshape(fread(fid,NT*NF,'float'),NF,NT);
%SS=mean(S')/1260;
%for k=1:1259
%	S=reshape(fread(fid,NT*NF,'float'),NF,NT);
%	SS=SS+mean(S')/1260;
%plot(SS)
%pause(0)
%end
%RMSP=SS;
%save /marsalis2/escabim/RMSP.mat RMSP
load RMSP
%Initializing First and Second Spectral Profile Segments
frewind(fid);
S1=fread(fid,NT*NF,'float');
S1=reshape(S1,NF,NT);
S2=fread(fid,NT*NF,'float');
S2=reshape(S2,NF,NT);
S3=fread(fid,NT*NF,'float');
S3=reshape(S2,NF,NT);

SS=ones(length(RMSP),N2+N1);
for k=1:length(RMSP)
	SS(k,:)=SS(k,:)*RMSP(k);
end
RMSP=SS;			%Mean Power Spectrum
RMSPP=mean(RMSP(50:150));	%Mean Value of Power Spectrum
clear SS

%Loading Data and Computing 'dB' STRF
while ~feof(fid) & TrigCount<length(Trig)-1

	%Finding SPET in between triggers
	index1=find(spet>=Trig(TrigCount) & spet<Trig(TrigCount+1));
	index2=find(spet>Trig(NTrig-TrigCount+1) & spet<=Trig(NTrig-TrigCount+2));

	%Resampling spet relative to the Spectral Profile samples
	spettrig1=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF );
	spettrig2=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF );

	%Finding Receptive Field for Channel 1
	for k=1:length(spettrig1)

		%Setting Spike Time and STRF length
		M=size(S1);,M=M(2);
		L=spettrig1(k);

		%Averaging Pre-Event Spectral Profiles
		if L < N2
			STRF1=STRF1+([S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP)/RMSPP*PP;
		elseif L+N1 > M
			STRF1=STRF1+([S2(:,L-N2+1:M) S3(:,1:N1-M+L)] - RMSP)/RMSPP*PP;
		else
			STRF1=STRF1+(S2(:,L-N2+1:L+N1) - RMSP)/RMSPP*PP;
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
		if L < N2
			STRF1=STRF1+([S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP)/RMSPP*PP;
		elseif L+N1 > M
			STRF1=STRF1+([S2(:,L-N2+1:M) S3(:,1:N1-M+L)] - RMSP)/RMSPP*PP;
		else
			STRF1=STRF1+(S2(:,L-N2+1:L+N1) - RMSP)/RMSPP*PP;
		end

		%Counting the number of Spikes averaged
		No2=No2+1;

	end

	%Reading Spectral Profile Data File
	S1=S2;
	S2=S3;
	S3=fread(fid,NT*NF,'float');
	if ~feof(fid)
		S3=reshape(S3,NF,NT);
	end

	%Updating Trigger Counter
	TrigCount=TrigCount+1;
	clc
	disp(['Block Number ' num2str(TrigCount) ' of ' num2str(NTrig)])

	%Sending To Display - Updates every NBlocks
	if TrigCount/NBlocks==round(TrigCount/NBlocks)
		T=( Trig(TrigCount) - Trig(1) )/Fss;
		Wo1=No1/T;
		Wo2=No2/T; 
		taxis=(-N1:N2-1)/(Fs/DF);
		subplot(211)

		%Displaying STRF1
		pcolor(taxis,log2(faxis/1000+1E-10),Wo1/fact(2)/PP^2*fliplr(STRF1)/No1*PP)
		shading flat,colormap jet,colorbar,axis([0 max(taxis) 0 4.17])
		title(['No = ' int2str(No1) ' ( Spikes ), Wo = ' num2str(Wo1,5) ' ( Spikes/Sec )'])

		%Displaying STRF2
		subplot(212)
		pcolor(taxis,log2(faxis/1000+1E-10),Wo2/fact(2)/PP^2*STRF2/No2*PP)
		shading flat,colormap jet,colorbar,axis([0 max(taxis) 0 4.17])
		title(['No = ' int2str(No2) ' ( Spikes ) , Wo = ' num2str(Wo2,5) ' ( Spikes/Sec )'])
		pause(0)
	end
end

%Normalizing 'dB' STRF According to Paper by Van Dijk
T=( max(spet) - min(spet) )/Fss;
if ~( T==0 | isempty(T) )
	Wo1=No1/T;
	Wo2=No2/T;
else
	No1=-9999;						%No Spikes in SPET
	No2=-9999;
end
STRF1=Wo1/fact(2)/PP^2*fliplr(STRF1)/No1;
STRF2=Wo2/fact(2)/PP^2*STRF2/No2;

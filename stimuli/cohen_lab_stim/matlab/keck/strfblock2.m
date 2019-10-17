%
%function [taxis,faxis,STRF2,No2]=strfblock2(SpecFile,T1,T2,spet,Trig,TrigBlock,Fss,MdB,Sound,UF,sprtype)
%
%       FILE NAME       : STRF Block 2
%       DESCRIPTION     : Computes Ipsi STRF for a Triggered Block Segment
%
%	SpecFile	: Spectral Profile File
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%			  T E [- T1 , T2 ], Note that T1 and T2 > 0
%	spet		: Array of spike event times in sample number
%	Trig		: Array of Trigger Times
%	TrigBlock	: Block Number to Analyze
%	Fss		: Sampling Rate for TRIGGER and SPET
%	MdB		: Signal Modulation Index in dB
%	Sound		: Sound Type 
%			  Moving Ripple	: MR ( Default )
%			  Ripple Noise	: RN
%	UF		: Upsampling Factor
%	sprtype		: SPR File Type : 'float' or 'int16'
%			  Default=='float'
%	
%	RETURNED VALUES 
%
%	taxis		: Time Axis
%	faxis		: Frequency Axis (Hz)
%	STRF2		: Spectro-Temporal Receptive Field
%	No2		: Number of Spikes
%
function [taxis,faxis,STRF2,No2]=strfblock2(SpecFile,T1,T2,spet,Trig,TrigBlock,Fss,MdB,Sound,UF,sprtype)

%Parameters
if nargin<11
	sprtype='float';
end
NTrig=length(Trig);

%Loading Parameter Data
index=findstr(SpecFile,'.spr');
ParamFile=[SpecFile(1:index(1)-1) '_param.mat'];
f=['load ' ParamFile];
eval(f);
clear App  MaxFM XMax Axis MaxRD RD f phase Block Mn RP f1 f2 Mnfft FM N fFM fRD NB NS LL filename M X fphase Fsn

%Fiding Mean Spectral Profile and RMS Power
RMSP=-MdB/2;	% RMS value of normalized Spectral Profile

%Fliping Trig and Spet for channel 2 and channel 1 STRFs
MinTime=min([Trig spet]);
MaxTime=max([Trig spet]);
spet=spet-MinTime+1;
Trig=Trig-MinTime+1;

%Converting Temporal Delays to Sample Numbers
N1=round(T1*Fs/DF)+2;
N2=round(T2*Fs/DF)+2;
 
%Opening Spectral Profile File
fid=fopen(SpecFile);

%Initializing Some Variables
No2=0;				%Number of Spikes for channel 2
STRF2=zeros(NF,N1+N2,UF);	%Receptive Field  for channel 2

%Advancing File To Desired Trigger Block
fseek(fid,NT*NF*4*(length(Trig)-TrigBlock-1),-1);

%Initializing First and Second Spectral Profile Segments
if strcmp(sprtype,'float')
	S3=fread(fid,NT*NF,'float');
	S2=fread(fid,NT*NF,'float');
	S1=fread(fid,NT*NF,'float');
else
	S3=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
	S2=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
	S1=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
end
S1=fliplr(reshape(S1,NF,NT));
S2=fliplr(reshape(S2,NF,NT));
S3=fliplr(reshape(S2,NF,NT));

%Finding SPET in between triggers
index1=find(spet>=Trig(TrigBlock) & spet<Trig(TrigBlock+1));
index2=find(spet>Trig(NTrig-TrigBlock+1) & spet<=Trig(NTrig-TrigBlock+2));

%Resampling spet relative to the Spectral Profile samples
spettrig1=ceil( (spet(index1)-Trig(TrigBlock)+1) * Fs / Fss /DF );
spettrig2=ceil( (Trig(NTrig-TrigBlock+2)+1-spet(index2)) * Fs / Fss /DF );

%Finding Position of Spike Relative to The Spectro-Temporal Envelope
spettrig1u=ceil( (spet(index1)-Trig(TrigBlock)+1) * Fs / Fss /DF * UF );
spettrig2u=ceil( (Trig(NTrig-TrigBlock+2)+1-spet(index2)) * Fs / Fss /DF * UF );

%Finding Bin Number 
if length(spettrig1)>0
	KK1=-(spettrig1u-UF*spettrig1)+1;
end
if length(spettrig2)>0
	KK2=-(spettrig2u-UF*spettrig2)+1;
end

%Finding Receptive Field for Channel 1
for k=1:length(spettrig1)

	%Setting Spike Time and STRF length
	M=size(S1);,M=M(2);
	L=spettrig1(k);
	kk1=KK1(k);

	%Averaging Pre-Event Spectral Profiles
	if L < N2
		STRF2(:,:,kk1)=...
		STRF2(:,:,kk1) + MdB*[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP;
	elseif L+N1 > M
		STRF2(:,:,kk1)=...
		STRF2(:,:,kk1) + MdB*[S2(:,L-N2+1:M) S3(:,1:N1-M+L)] - RMSP;
	else
		STRF2(:,:,kk1)=...
		STRF2(:,:,kk1) + MdB*[S2(:,L-N2+1:L+N1)] - RMSP;
	end

	%Counting the number of Spikes averaged
	No2=No2+1;

end

%Time and Frequency Axis For STRF
taxis=(-N1:N2-1)/(Fs/DF);

%Closing all opened files
fclose all;

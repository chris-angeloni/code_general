%
%function [I1,I2,Spike1,Spike2]=binild(SpecFile,T1,T2,T,Xc,spet,Trig,Fss,SPL,MdB,ModType,Sound,NBlocks,sprtype)
%
%       FILE NAME       : BIN ILD
%       DESCRIPTION     : Binaural Interaural Level Difference obtained 
%			  from Moving Ripple or Ripple Noise 
%			  Spectral Profile
%
%	SpecFile	: Spectral Profile File
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%			  T E [- T1 , T2 ], Note that T1 and T2 > 0 (sec)
%	T		: Delay for computing ILD sensitivity function (sec)
%			  If 2 element array is given uses first element for 
%			  channel 1 and second for channel 2
%	Xc		: Neurons center frequency in Octaves
%			  If 2 element array is given uses first element for 
%			  channel 1 and second for channel 2
%	spet		: Array of spike event times in sample number
%	Trig		: Array of Trigger Times
%	Fss		: Sampling Rate for TRIGGER and SPET
%	SPL		: Signal RMS Sound Pressure Level
%	MdB		: Signal Modulation Index in dB
%	ModType		: Kernel modulation type : 'lin' or 'dB'
%	Sound		: Sound Type 
%			  Moving Ripple	: MR ( Default )
%			  Ripple Noise	: RN
%	NBlocks		: Number of Blocks Between Displays
%	sprtype		: SPR File Type : 'float' or 'int16'
%			  Default=='float'	
%
%	RETURNED VALUES 
%
%	I1, I2		: Intensity  array for channels one and two
%	Spike1, Spike2	: Spike time array for channels one and two
%
function [I1,I2,Spike1,Spike2]=binild(SpecFile,T1,T2,T,Xc,spet,Trig,Fss,SPL,MdB,ModType,Sound,NBlocks,sprtype)

%Parameters
if nargin<12
	sprtype='float';
end
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
if length(T)>1
	NNT1=round(T(1)*Fs/DF);
	NNT2=round(T(2)*Fs/DF);
else
	NNT1=round(T*Fs/DF);
	NNT2=round(T*Fs/DF);
end

%Finding Spectral location for Xc
if length(Xc)>1
	NXc1=max(find(log2(faxis/faxis(1))<Xc(1)));
	NXc2=max(find(log2(faxis/faxis(1))<Xc(2)));
else
	NXc1=max(find(log2(faxis/faxis(1))<Xc));
	NXc2=max(find(log2(faxis/faxis(1))<Xc));
end
 
%Opening Spectral Profile File
fid=fopen(SpecFile);

%Initializing Some Variables
TrigCount=2;
No1=0;				%Number of Spikes for channel 1
No2=0;				%Number of Spikes for channel 2

%Computing Spectro Temporal Receptive Fields - Checking for 'dB' or 'lin'

%Fiding Mean Spectral Profile and RMS Power
SPLN=SPL-10*log10(NF);					% Normalized SPL per frequency band
if strcmp(Sound,'RN')
	RMSP=-MdB/2;					% RMS value of normalized Spectral Profile
	PP=MdB^2/12;					% Modulation Depth Variance 
elseif strcmp(Sound,'MR')
	RMSP=-MdB/2;					% RMS value of normalized Spectral Profile
	PP=MdB^2/8;					% Modulation Depth Variance 
end

%Initializing First and Second Spectral Profile Segments
frewind(fid);
if strcmp(sprtype,'float')
	S1=fread(fid,NT*NF,'float');
	S2=fread(fid,NT*NF,'float');
	S3=fread(fid,NT*NF,'float');
else
	S1=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
	S2=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
	S3=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
end
S1=reshape(S1,NF,NT);
S2=reshape(S2,NF,NT);
S3=reshape(S2,NF,NT);

%Loading Data and Computing Binaural IDL Function
while ~feof(fid) & TrigCount<length(Trig)-1

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
			SS1= MdB*[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP;
		elseif L+N1 > M
			SS1= MdB*[S2(:,L-N2+1:M) S3(:,1:N1-M+L)] - RMSP;
		else
			SS1= MdB*[S2(:,L-N2+1:L+N1)] - RMSP;
		end

		%Counting the number of Spikes averaged
		No1=No1+1;
	
		%Finding Instantaneous Intensity
		I1(No1)=SS1(NXc1,size(SS1,2)-NNT1);
		Spike1(No1)=spet(index1(k));

	end

	%Finding Receptive Field for Channel 2
	for k=1:length(spettrig2)

		%Setting Spike Time and STRF length
		M=size(S1);,M=M(2);
		L=spettrig2(k);

		%Averaging Pre-Event Spectral Profiles
		if L < N1
			SS2= MdB*[S1(:,M-(N1-L-1):M) S2(:,1:L+N2)] - RMSP;
		elseif L+N2 > M
			SS2= MdB*[S2(:,L-N1+1:M) S3(:,1:N2-M+L)] -RMSP;
		else
			SS2= MdB*[S2(:,L-N1+1:L+N2)] - RMSP;
		end

		%Counting the number of Spikes averaged
		No2=No2+1;

		%Finding Instantaneous Intensity
		I2(No2)=SS2(NXc2,NNT2);
		Spike2(No2)=spet(index2(k));

	end

	%Flipping All Spikes in the pressent block
	NNI2=length(I2);
	if NNI2>0
		Spike2(NNI2-length(index2)+1:NNI2)=fliplr(Spike2(NNI2-length(index2)+1:NNI2));
		I2(NNI2-length(index2)+1:NNI2)=fliplr(I2(NNI2-length(index2)+1:NNI2));
	end

	%Reading Spectral Profile Data File
	S1=S2;
	S2=S3;
	if strcmp(sprtype,'float')
		S3=fread(fid,NT*NF,'float');
	else
		S3=fread(fid,NT*NF,'int16')/.99/1024/32/2-.5;
	end
	if ~feof(fid)
		S3=reshape(S3,NF,NT);
	end

	%Updating Trigger Counter
	TrigCount=TrigCount+1;
	clc
	disp(['Block Number ' num2str(TrigCount) ' of ' num2str(NTrig)])

end

%Finding Contra and Ipso Intensities
count=0;
II=zeros(1,2);
for k=1:length(Spike1)
	index=find(Spike1(k)==Spike2);	
	if length(index)>0
		count=count+1;
		II(count,:)=[I1(k) I2(index)];
	end
end
I1=II(:,1);
I2=II(:,2);


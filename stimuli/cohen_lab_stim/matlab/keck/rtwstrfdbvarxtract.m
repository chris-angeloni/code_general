%
%function [p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrfdbvarxtract(STRF1,STRF2,
%	  SpecFile,T1,T2,spet,Trig,Fss,SPL,MdB,Sound,NBlocks,sprtype)
%
%       FILE NAME       : RT WSTRF DB VAR
%       DESCRIPTION     : Findst the Variability of the Envelope Patterns that
%			  Make up the spectro-temporal receptive field
%			  For dB Amplitude Sound distributions 
%
%			  Saves Pre Event Sound Elements to Files 
%
%	STRF1		: STRF for Channel 1
%			  STRF should be normalized as STRF1s/Wo1*PP
%			  Where STRF1s is the significant STRF, Wo1 is the 
%			  mean spike rate, and PP is the Envelope variance
%	STRF2		: STRF for Channel 2
%			  STRF should be normalized as STRF2s/Wo2*PP
%			  Where STRF2s is the significant STRF, Wo2 is the 
%			  mean spike rate, and PP is the Envelope variance
%	SpecFile	: Spectral Profile File
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%			  T E [- T1 , T2 ], Note that T1 and T2 > 0
%	spet		: Array of spike event times in sample number
%	Trig		: Array of Trigger Times
%	Fss		: Sampling Rate for TRIGGER and SPET
%	SPL		: Signal RMS Sound Pressure Level
%	MdB		: Signal Modulation Index in dB
%	Sound		: Sound Type 
%			  Moving Ripple	: MR ( Default )
%			  Ripple Noise	: RN
%	NBlocks		: Number of Blocks Between Displays
%	sprtype		: SPR File Type : 'float' or 'int16'
%			  Default=='float'	
%
%	RETURNED VALUES 
%
%	p1		: Correlation Coefficient Vector for Channel 1
%	p2		: Correlation Coefficient Vector for Channel 2
%	p1e		: Correlation Coefficient for Excitatory Subfields 
%			  of STRF1
%	p2e		: Correlation Coefficient for Excitatory Subfields
%			  of STRF2
%	p1i		: Correlation Coefficient for Inhibitory Subfields
%			  of STRF1
%	p2i		: Correlation Coefficient for Inhibitory Subfields
%			  of STRF2
%	spindex1	: Spet indecees for channel 1
%	spindex2	: Spet indecees for channel 2
%
function [p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrfdbvarxtract(STRF1,STRF2,SpecFile,T1,T2,spet,Trig,Fss,SPL,MdB,Sound,NBlocks,sprtype)

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
 
%Opening Spectral Profile File
fid=fopen(SpecFile);

%Initializing Some Variables
TrigCount=2;
No1=0;					%Number of Spikes for channel 1
No2=0;					%Number of Spikes for channel 2
Env1=zeros(NF,N1+N2);			%Envelope Buffer for channel 1
Env2=zeros(NF,N1+N2);			%Envelope Buffer for channel 2
STRF1=fliplr(STRF1);			%Fliping from left to right STRF1
STRF1=reshape(STRF1,1,NF*(N1+N2));	%Reshaping STRF1
STRF2=reshape(STRF2,1,NF*(N1+N2));	%Reshaping STRF2
i1=find(STRF1~=0);			%Indeces for significant STRF1
i2=find(STRF2~=0);			%Indeces for significant STRF2
i1e=find(STRF1>0);			%Indeces for Excitatory Subfields
i2e=find(STRF2>0);			%Indeces for Excitatory Subfields
i1i=find(STRF1<0);			%Indeces for Inhibitory Subfields
i2i=find(STRF2<0);			%Indeces for Inhibitory Subfields
X1=STRF1(i1);				%Significant Pixel Values for STRF1
X2=STRF2(i2);				%Significant Pixel Values for STRF2
X1e=STRF1(i1e);				%Significant Exci Pixel Values for STRF1
X2e=STRF2(i2e);				%Significant Exci Pixel Values for STRF2
X1i=STRF1(i1i);				%Significant Inhi Pixel Values for STRF1
X2i=STRF2(i2i);				%Significant Inhi Pixel Values for STRF2
std1=sqrt(mean(X1.^2));			%STRF1 Standard Deviation
std2=sqrt(mean(X2.^2));			%STRF2 Standard Deviation
std1e=sqrt(mean(X1e.^2));		%STRF1e Standard Deviation
std2e=sqrt(mean(X2e.^2));		%STRF2e Standard Deviation
std1i=sqrt(mean(X1i.^2));		%STRF1i Standard Deviation
std2i=sqrt(mean(X2i.^2));		%STRF2i Standard Deviation
p1=[];					%Correlation Coefficient Chan 1
p2=[];					%Correlation Coefficient Chan 2
p1e=[];					%Correlation Coefficient Chan 1
p2e=[];					%Correlation Coefficient Chan 2
p1i=[];					%Correlation Coefficient Chan 1
p2i=[];					%Correlation Coefficient Chan 2
spindex1=[];				%Spike Index 1 
spindex2=[];				%Spike Index 2

%Fiding Mean Spectral Profile and RMS Power
if strcmp(Sound,'RN')
	RMSP=-MdB/2;		% RMS value of normalized Spectral Profile
	PP=MdB^2/12;		% Modulation Depth Variance 
elseif strcmp(Sound,'MR')
	RMSP=-MdB/2;		% RMS value of normalized Spectral Profile
	PP=MdB^2/8;		% Modulation Depth Variance 
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

%Computing Spectro Temporal Receptive Field Variability - 'dB'
while ~feof(fid) & TrigCount<length(Trig)-1

	%Finding SPET in between triggers
	index1=find(spet>=Trig(TrigCount) & spet<Trig(TrigCount+1));
	index2=find(spet>Trig(NTrig-TrigCount+1) & spet<Trig(NTrig-TrigCount+2));

	%Spike Indeces Used for Computing Correlation Coeficient
	spindex1=[spindex1 index1];
	spindex2=[spindex2 index2];

	%Resampling spet relative to the Spectral Profile samples
	M=size(S1,2);
	spettrig1=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF );
	spettrig2=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF );
%	spettrig1=spettrig1(find(spettrig1<M));
%	spettrig2=spettrig2(find(spettrig2<M));

	%Finding Receptive Field Variability for Channel 1
	epsilon=10^(-MdB/20);
	for k=1:length(spettrig1)

		%Setting Spike Time and STRF length
		M=size(S1);,M=M(2);
		L=spettrig1(k);

		if L<=M  %Condition to circumvent rounding errors 
			%Finding Pre-Event Spectral Profiles
			if L < N2
				Env1=MdB*[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)]-RMSP;
			elseif L+N1 > M
				Env1=MdB*[S2(:,L-N2+1:M) S3(:,1:N1-M+L)]-RMSP;
			else
				Env1=MdB*[S2(:,L-N2+1:L+N1)]-RMSP;
			end

			%Counting the number of Spikes averaged
			No1=No1+1;
%f=['save Env1_' num2str(No1) ' Env1'];
f=['save Env1_' num2str(index1(k)) ' Env1'];
disp(f)
eval(f)


			%Reshaping Envelope
			Env1=reshape(Env1,1,NF*(N1+N2));
	
			%Finding Correlation Coefficient and Variance
			Env1e=Env1(i1e);
			Env1i=Env1(i1i);
			Env1=Env1(i1);
			std1E=sqrt(PP);
			p1(No1)=mean(X1.*Env1)/std1/std1E;
			p1e(No1)=mean(X1e.*Env1e)/std1e/std1E;
			p1i(No1)=mean(X1i.*Env1i)/std1i/std1E;
%f=['save Env1_' num2str(No1) ' p1 -append'];
f=['save Env1_' num2str(index1(k)) ' p1 -append'];
eval(f)
		end	
	end

	%Finding Receptive Field Variability for Channel 2
	for k=1:length(spettrig2)

		%Setting Spike Time and STRF length
		M=size(S1);,M=M(2);
		L=spettrig2(k);

		if L<=M  %Condition to circumvent rounding errors 
			%Finding Pre-Event Spectral Profiles
			if L < N1
				Env2=MdB*[S1(:,M-(N1-L-1):M) S2(:,1:L+N2)] -RMSP;
			elseif L+N2 > M
				Env2=MdB*[S2(:,L-N1+1:M) S3(:,1:N2-M+L)] -RMSP;
			else
				Env2=MdB*[S2(:,L-N1+1:L+N2)] -RMSP;
			end
	
			%Counting the number of Spikes averaged
			No2=No2+1;

%f=['save Env2_' num2str(No2) ' Env2'];
f=['save Env2_' num2str(index2(k)) ' Env2'];
disp(f)
eval(f)
	
			%Reshaping Envelope
			Env2=reshape(Env2,1,NF*(N1+N2));
	
			%Finding Correlation Coefficient and Variance
			Env2e=Env2(i2e);
			Env2i=Env2(i2i);
			Env2=Env2(i2);
			std2E=sqrt(PP);
			p2(No2)=mean(X2.*Env2)/std2/std2E;
			p2e(No2)=mean(X2e.*Env2e)/std2e/std2E;
			p2i(No2)=mean(X2i.*Env2i)/std2i/std2E;
%f=['save Env2_' num2str(No2) ' p2 -append'];
f=['save Env2_' num2str(index2(k)) ' p2 -append'];
eval(f)

		end
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

        %Displaying Output
        if TrigCount/NBlocks==round(TrigCount/NBlocks)

                if length(p1)>1
                        subplot(211)
                        hist(p1,-1:.1:1)
			xlabel('Correlation Coefficient')
			ylabel('Counts')
                        pause(0)
                end

                if length(p2)>1
                        subplot(212)
                        hist(p2,-1:.1:1)
			xlabel('Correlation Coefficient')
			ylabel('Counts')
                        pause(0)
                end
        end
end

%Closing all opened files
fclose all


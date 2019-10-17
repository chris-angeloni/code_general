%
%function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrflinint(SpecFile,
%T1,T2,spet,Trig,Fss,SPL,MdB,ModType,Sound,NBlocks,UF,sprtype)
%
%       FILE NAME       : RT WSTRF LIN INT
%       DESCRIPTION     : Real Time spectro-temporal receptive field
%			  Uses Lee/Schetzen Aproach via Specto-Temporal Envelope
%			  For dB Amplitude Sound distributions 
%			  Interpolates the STRF by a factor 
%
%	SpecFile	: Spectral Profile File
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%			  T E [- T1 , T2 ], Note that T1 and T2 > 0
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
%	UF		: Upsampling Factor
%	sprtype		: SPR File Type : 'float' or 'int16'
%			  Default == 'float'
%
%	RETURNED VALUES 
%
%	taxis		: Time Axis
%	faxis		: Frequency Axis (Hz)
%	STRF1 , STRF2	: Spectro-Temporal Receptive Field
%	PP		: Power Level
%	Wo1, Wo2	: Zeroth-Order Kernels ( Average Number of Spikes / Sec )
%	No1, No2	: Number of Spikes
%	SPLN		: Sound Pressure Level per Frequency Band
%
function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrflinint(SpecFile,T1,T2,spet,Trig,Fss,SPL,MdB,ModType,Sound,NBlocks,UF,sprtype)

%Parameters
if nargin<13
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
N1=round(T1*Fs/DF)+2;
N2=round(T2*Fs/DF)+2;
 
%Opening Spectral Profile File
fid=fopen(SpecFile);

%Initializing Some Variables
TrigCount=2;
No1=0;				%Number of Spikes for channel 1
No2=0;				%Number of Spikes for channel 2
STRF1=zeros(NF,N1+N2,UF);	%Receptive Field  for channel 1
STRF2=zeros(NF,N1+N2,UF);	%Receptive Field  for channel 2

%Computing Spectro Temporal Receptive Fields - Checking for 'dB' or 'lin'
if strcmp(ModType,'dB')

        %Fiding Mean Spectral Profile and RMS Power
        SPLN=SPL-10*log10(NF);                                  % Normalized SPL per frequency band
        if strcmp(Sound,'RN')
                X=rand(1,1024*16);
                epsilon=10^(-MdB/20);
                Z=20*log10((1-epsilon)*X+epsilon);
                RMSP=mean(Z);                                   % RMS value of normalized Spectral Profile
                PP=var(Z);                                      % Modulation Depth Variance
        elseif strcmp(Sound,'MR')
                X=rand(1,1024*16)*2*pi;
                epsilon=10^(-MdB/20);
                Z=20*log10(.5*(1-epsilon)*(sin(X)+1)+epsilon);
                RMSP=mean(Z);                                   % RMS value of normalized Spectral Profile
                PP=var(Z);                                      % Modulation Depth Variance
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

	%Loading Data and Computing 'dB' STRF
	while ~feof(fid) & TrigCount<length(Trig)-1

		%Finding SPET in between triggers
		index1=find(spet>=Trig(TrigCount) & spet<Trig(TrigCount+1));
		index2=find(spet>Trig(NTrig-TrigCount+1) & spet<=Trig(NTrig-TrigCount+2));

		%Resampling spet relative to the Spectral Profile samples
		spettrig1=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF );
		spettrig2=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF );

		%Finding Position of Spike Relative to The Spectro-Temporal Envelope
		spettrig1u=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF * UF );
		spettrig2u=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF * UF );
	
		%Finding Bin Number 
		if length(spettrig1)>0
			KK1=-(spettrig1u-UF*spettrig1)+1;
		end
		if length(spettrig2)>0
			KK2=-(spettrig2u-UF*spettrig2)+1;
		end

		%Finding Receptive Field for Channel 1
		epsilon=10^(-MdB/20);
		for k=1:length(spettrig1)

			%Setting Spike Time and STRF length
			M=size(S1);,M=M(2);
			L=spettrig1(k);
			kk1=KK1(k);

			%Averaging Pre-Event Spectral Profiles
                        if L < N2
                                STRF1(:,:,kk1)=STRF1(:,:,kk1)+20*log10( (1-epsilon)*(1+[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)])+epsilon ) - RMSP;
                        elseif L+N1 > M
                                STRF1(:,:,kk1)=STRF1(:,:,kk1)+20*log10( (1-epsilon)*(1+[S2(:,L-N2+1:M) S3(:,1:N1-M+L)])+epsilon ) - RMSP;
                        else
                                STRF1(:,:,kk1)=STRF1(:,:,kk1)+20*log10( (1-epsilon)*(1+[S2(:,L-N2+1:L+N1)])+epsilon ) - RMSP;
                        end

			%Counting the number of Spikes averaged
			No1=No1+1;

		end

		%Finding Receptive Field for Channel 2
		for k=1:length(spettrig2)
	
			%Setting Spike Time and STRF length
			M=size(S1);,M=M(2);
			L=spettrig2(k);
			kk2=KK2(k);

                        %Averaging Pre-Event Spectral Profiles
                        if L < N1
                                STRF2(:,:,kk2)=STRF2(:,:,kk2)+20*log10( (1-epsilon)*(1+[S1(:,M-(N1-L-1):M) S2(:,1:L+N2)])+epsilon ) - RMSP;
                        elseif L+N2 > M
                                STRF2(:,:,kk2)=STRF2(:,:,kk2)+20*log10( (1-epsilon)*(1+[S2(:,L-N1+1:M) S3(:,1:N2-M+L)])+epsilon ) - RMSP;
                        else
                                STRF2(:,:,kk2)=STRF2(:,:,kk2)+20*log10( (1-epsilon)*(1+[S2(:,L-N1+1:L+N2)])+epsilon ) - RMSP;
                        end

			%Counting the number of Spikes averaged
			No2=No2+1;

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

		%Sending To Display - Updates every NBlocks
		if TrigCount/NBlocks==round(TrigCount/NBlocks)
			T=min([ ( Trig(TrigCount) - Trig(1) )/Fss  (max(spet) - min(spet))/Fss]);
			Wo1=No1/T;
			Wo2=No2/T; 
			taxis=(-N1:N2-1)/(Fs/DF);
			subplot(211)

			%Displaying STRF1
			pcolor(taxis,log2(faxis/500),Wo1/PP*fliplr(sum(STRF1,3))/No1*sqrt(PP))
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(No1) ' ( Spikes ), Wo = ' num2str(Wo1,5) ' ( Spikes/Sec )'])

			%Displaying STRF2
			subplot(212)
			pcolor(taxis,log2(faxis/500),Wo2/PP*sum(STRF2,3)/No2*sqrt(PP))
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(No2) ' ( Spikes ) , Wo = ' num2str(Wo2,5) ' ( Spikes/Sec )'])
			pause(0)
		end
	end

	%Normalizing 'dB' STRF According to Paper by Van Dijk
	taxis=(-N1:N2-1)/(Fs/DF);
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
	for k=1:UF
		STRF1(:,:,k)=Wo1/PP*fliplr(STRF1(:,:,k))/No1;
	end
	STRF2=Wo2/PP*STRF2/No2;

	%Interpolating, Realigning, and adding the Waveforms
	for k=1:UF
		dT=taxis(3)-taxis(2);
		STRF1i(:,:,k)=interp1(taxis,STRF1(:,:,k)',(-N1*UF:N2*UF-1)*dT/UF+k*dT/UF,'cubic')';
		STRF2i(:,:,k)=interp1(taxis,STRF2(:,:,k)',(-N1*UF:N2*UF-1)*dT/UF-k*dT/UF+dT,'cubic')';
	end
	taxis=(-UF*N1:N2*UF-1)/(Fs/DF*UF);

	%Truncating Waveforms to Appropriate Size
	STRF1=sum(STRF1i(:,2*UF+1:length(taxis)-2*UF,:),3);
	STRF2=sum(STRF2i(:,2*UF+1:length(taxis)-2*UF,:),3);
	taxis=(-UF*(N1-2):(N2-2)*UF-1)/(Fs/DF*UF);

elseif strcmp(ModType,'lin')

	%Fiding Mean Spectral Profile and RMS Power
        Po=2.2E-5;                                                      % Threshold of Hearing at 1KHz in Pascals
        P= Po*10^(SPL/20);                                              % Pressure conversion
        PP=P*P/NF;                                                      % Mean Power spectrum per frequency band
        SPLN=SPL-10*log10(NF);                                          % Normalized SPL per frequency band
        if strcmp(Sound,'RN')
                %RMSP=sqrt(4/45);                                       % RMS value (std) of normalized Spectral Profile
                %MeanP=1/3;                                             % Note: This is the std and mean of a uniform distribution
                RMSP=1/sqrt(12);
                MeanP=1/2;
        elseif strcmp(Sound,'MR')
                %RMSP=sqrt(17/128);                                     % RMS value (std) of normalized Spectral Profile
                %MeanP=sqrt(3/8);                                       % f=.5*.5+sin(X) where X E of Uniform Distribution
                RMSP=1/sqrt(2)*1/2;
                MeanP=1/2;
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

	%Loading Data and Computing 'lin' STRF
	while ~feof(fid) & TrigCount<length(Trig)

		%Finding SPET in between triggers
		index1=find(spet>=Trig(TrigCount) & spet<Trig(TrigCount+1));
		index2=find(spet>Trig(NTrig-TrigCount+1) & spet<=Trig(NTrig-TrigCount+2));

		%Resampling spet relative to the Spectral Profile samples
		spettrig1=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF );
		spettrig2=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF );

		%Finding Position of Spike Relative to The Spectro-Temporal Envelope
		spettrig1u=ceil( (spet(index1)-Trig(TrigCount)+1) * Fs / Fss /DF * UF );
		spettrig2u=ceil( (Trig(NTrig-TrigCount+2)+1-spet(index2)) * Fs / Fss /DF * UF );
	
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
                                STRF1(:,:,kk1)=STRF1(:,:,kk1)+ ( 1 + [S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - MeanP ) / RMSP*sqrt(PP);
                        elseif L+N1 > M
                                STRF1(:,:,kk1)=STRF1(:,:,kk1)+ ( 1 + [S2(:,L-N2+1:M) S3(:,1:N1-M+L)] - MeanP ) / RMSP*sqrt(PP);
                        else
                                STRF1(:,:,kk1)=STRF1(:,:,kk1)+ ( 1 + S2(:,L-N2+1:L+N1) - MeanP ) / RMSP*sqrt(PP);
                        end


			%Counting the number of Spikes averaged
			No1=No1+1;

		end

		%Finding Receptive Field for Channel 2
		for k=1:length(spettrig2)

			%Setting Spike Time and STRF length
			M=size(S1);,M=M(2);
			L=spettrig2(k);
			kk2=KK2(k);

                        %Averaging Pre-Event Spectral Profiles
                        if L < N1
                                STRF2(:,:,kk2)=STRF2(:,:,kk2)+ ( 1 + [S1(:,M-(N1-L-1):M) S2(:,1:L+N2)] - MeanP ) / RMSP*sqrt(PP);
                        elseif L+N2 > M
                                STRF2(:,:,kk2)=STRF2(:,:,kk2)+ ( 1 + [S2(:,L-N1+1:M) S3(:,1:N2-M+L)] - MeanP ) / RMSP*sqrt(PP);
                        else
                                STRF2(:,:,kk2)=STRF2(:,:,kk2)+ ( 1 + S2(:,L-N1+1:L+N2) - MeanP ) / RMSP*sqrt(PP);
                        end

			%Counting the number of Spikes averaged
			No2=No2+1;

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

		%Sending To Display - Updates every NBlocks
		if TrigCount/NBlocks==round(TrigCount/NBlocks)
	
			T=min([ ( Trig(TrigCount) - Trig(1) )/Fss  (max(spet) - min(spet))/Fss]);
			Wo1=No1/T;
			Wo2=No2/T;
			taxis=(-N1:N2-1)/(Fs/DF);

			%Displaying STRF1
			subplot(211)
			pcolor(taxis,log2(faxis/500),Wo1/PP*fliplr(sum(STRF1,3))/No1*sqrt(PP))
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(No1) ' ( Spikes ) , Wo = ' num2str(Wo1,5) ' ( Spikes/Sec )'])

			%Displaying STRF2
			subplot(212)
			pcolor(taxis,log2(faxis/500),Wo2/PP*sum(STRF2,3)/No2*sqrt(PP))
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(No2) ' ( Spikes ) , Wo = ' num2str(Wo2,5) ' ( Spikes/Sec )'])
			pause(0)
		end
	end


	%Normalizing STRF According to Paper by Van Dijk
	taxis=(-N1:N2-1)/(Fs/DF);
	T=( max(spet) - min(spet) )/Fss;
	if ~( T==0 | isempty(T) )
		Wo1=No1/T;
		Wo2=No2/T;
	else
		No1=-9999;						%No Spikes
		No2=-9999;
	end
	for k=1:UF
		STRF1(:,:,k)=Wo1/PP*fliplr(STRF1(:,:,k))/No1;
	end
	STRF2=Wo2/PP*STRF2/No2;

	%Interpolating, Realigning, and adding the Waveforms
	for k=1:UF
		dT=taxis(3)-taxis(2);
		STRF1i(:,:,k)=interp1(taxis,STRF1(:,:,k)',(-N1*UF:N2*UF-1)*dT/UF+k*dT/UF,'cubic')';
		STRF2i(:,:,k)=interp1(taxis,STRF2(:,:,k)',(-N1*UF:N2*UF-1)*dT/UF-k*dT/UF+dT,'cubic')';
	end
	taxis=(-UF*N1:N2*UF-1)/(Fs/DF*UF);

	%Truncating Waveforms to Appropriate Size
	STRF1=sum(STRF1i(:,2*UF+1:length(taxis)-2*UF,:),3);
	STRF2=sum(STRF2i(:,2*UF+1:length(taxis)-2*UF,:),3);
	taxis=(-UF*(N1-2):(N2-2)*UF-1)/(Fs/DF*UF);

end

%Closing all opened files
fclose all

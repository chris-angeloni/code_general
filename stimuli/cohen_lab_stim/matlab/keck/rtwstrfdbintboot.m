%
%function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdbintboot(SpecFile,
%T1,T2,spet,Trig,Fss,SPL,MdB,ModType,Sound,NBlocks,UF,sprtype,NBoot)
%
%       FILE NAME       : RT WSTRF DB INT BOOTSTRAP
%       DESCRIPTION     : Real Time spectro-temporal receptive field
%			  Uses Lee/Schetzen Aproach via Specto-Temporal Envelope
%			  For dB Amplitude Sound distributions 
%			  Interpolates the STRF by a factor 
%			  BOOTSTRAPS the STRF 
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
%			  Default=='float'
%	NBoot		: Number of STRF Bootstrap samples
%	
%	RETURNED VALUES 
%
%	taxis		: Time Axis
%	faxis		: Frequency Axis (Hz)
%	STRF1 , STRF2	: Spectro-Temporal Receptive Field broken up into N
%                     time Segments
%	PP		: Power Level
%	Wo1, Wo2	: Zeroth-Order Kernels ( Average Number of Spikes / Sec )
%                 in each time segment
%	No1, No2	: Number of Spikes in each time segment
%	SPLN		: Sound Pressure Level per Frequency Band
%
%
%(C) Monty A. Escabi, Chen Chen (Edit October 2008)

function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdbintboot(SpecFile,T1,T2,spet,Trig,Fss,SPL,MdB,ModType,Sound,NBlocks,UF,sprtype,NBoot)

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
No1=zeros(1,NBoot);				%Number of Spikes for channel 1     Edited Chen/Escabi Oct. 2008
No2=zeros(1,NBoot);             %Number of Spikes for channel 2     Edited Chen/Escabi Oct. 2008
STRF1=zeros(NF,N1+N2,UF,NBoot);	%Receptive Field  for channel 1
STRF2=zeros(NF,N1+N2,UF,NBoot);	%Receptive Field  for channel 2
TBootBlock=(max(Trig)-min(Trig))/NBoot; 	%Bootstrap Interval

%Computing Spectro Temporal Receptive Fields - Checking for 'dB' or 'lin'
if strcmp(ModType,'dB')

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

	%Bootstrap Block Number
	NBS1=1;
	NBS2=1;

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

			%Advancing Bootstrap Block Counter
			if spet(index1(k))>min(Trig)+TBootBlock*NBS1;
				NBS1=NBS1+1;
			end

			%Averaging Pre-Event Spectral Profiles
			if L < N2
				STRF1(:,:,kk1,NBS1)=STRF1(:,:,kk1,NBS1) + MdB*[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP;
			elseif L+N1 > M
				STRF1(:,:,kk1,NBS1)=STRF1(:,:,kk1,NBS1) + MdB*[S2(:,L-N2+1:M) S3(:,1:N1-M+L)] - RMSP;
			else
				STRF1(:,:,kk1,NBS1)=STRF1(:,:,kk1,NBS1) + MdB*[S2(:,L-N2+1:L+N1)] - RMSP;
			end

			%Counting the number of Spikes averaged
			No1(NBS1)=No1(NBS1)+1;      %(Edit, Escabi/Chen Oct 2008)

		end

		%Finding Receptive Field for Channel 2
		for k=1:length(spettrig2)
	
			%Setting Spike Time and STRF length
			M=size(S1);,M=M(2);
			L=spettrig2(k);
			kk2=KK2(k);

			%Advancing Bootstrap Block Counter
			if spet(index2(k))<max(Trig)+mean(diff(Trig))-TBootBlock*NBS2;
				NBS2=NBS2+1;
			end

			%Averaging Pre-Event Spectral Profiles
			if L < N1
				STRF2(:,:,kk2,NBS2)=STRF2(:,:,kk2,NBS2) + MdB*[S1(:,M-(N1-L-1):M) S2(:,1:L+N2)] - RMSP;
			elseif L+N2 > M
				STRF2(:,:,kk2,NBS2)=STRF2(:,:,kk2,NBS2) + MdB*[S2(:,L-N1+1:M) S3(:,1:N2-M+L)] -RMSP;
			else
				STRF2(:,:,kk2,NBS2)=STRF2(:,:,kk2,NBS2) + MdB*[S2(:,L-N1+1:L+N2)] - RMSP;
			end

			%Counting the number of Spikes averaged
			No2(NBS2)=No2(NBS2)+1;          %(Edit, Escabi/Chen Oct 2008)

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
			taxis=(-N1:N2-1)/(Fs/DF);
			subplot(211)

			%Displaying STRF1
			pcolor(taxis,log2(faxis/500),fliplr(sum(sum(STRF1,4),3))/sqrt(PP)/T); %Edited Chen Oct. 2008
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(sum(No1)) ' ( Spikes ), Wo = ' num2str(sum(No1)/T,5) ' ( Spikes/Sec )'])

			%Displaying STRF2
			subplot(212)
			pcolor(taxis,log2(faxis/500),sum(sum(STRF2,4),3)/sqrt(PP)/T);   %Edited Chen Oct. 2008
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(sum(No2)) ' ( Spikes ) , Wo = ' num2str(sum(No2)/T,5) ' ( Spikes/Sec )'])
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
		Wo1=No1/(T/NBoot);              %Edited Chen Oct. 2008
		Wo2=No2/(T/NBoot);              %Edited Chen Oct. 2008
	else
		No1=-9999;						%No Spikes in SPET
		No2=-9999;
    end
    for k=1:UF
		for l=1:NBoot
			STRF1(:,:,k,l)=Wo1(l)/PP*fliplr(STRF1(:,:,k,l))/No1(l);     %Edit Chen/Escabi Oct 2008
            STRF2(:,:,k,l)=Wo2(l)/PP*STRF2(:,:,k,l)/No2(l);             %Edit Chen/Escabi Oct 2008
		end
    end


	%Interpolating, Realigning, and adding the Waveforms
if UF~=1
	for k=1:UF
		for l=1:NBoot
		dT=taxis(3)-taxis(2);
		STRF1i(:,:,k,l)=interp1(taxis,STRF1(:,:,k,l)',(-N1*UF:N2*UF-1)*dT/UF+k*dT/UF,'cubic')';
		STRF2i(:,:,k,l)=interp1(taxis,STRF2(:,:,k,l)',(-N1*UF:N2*UF-1)*dT/UF-k*dT/UF+dT,'cubic')';
		end
	end
end
	taxis=(-UF*N1:N2*UF-1)/(Fs/DF*UF);

if UF~=1
	%Truncating Waveforms to Appropriate Size
	STRF1=sum(STRF1i(:,2*UF+1:length(taxis)-2*UF,:,:),3);
	STRF2=sum(STRF2i(:,2*UF+1:length(taxis)-2*UF,:,:),3);
	taxis=(-UF*(N1-2):(N2-2)*UF-1)/(Fs/DF*UF);
end

elseif strcmp(ModType,'lin')

	%Fiding Mean Spectral Profile and RMS Power
        Po=2.2E-5;							% Threshold of Hearing at 1KHz in Pascals
        P= Po*10^(SPL/20);						% Pressure conversion
        PP=P*P/NF;							% Mean Power spectrum per frequency band
	SPLN=SPL-10*log10(NF);						% Normalized SPL per frequency band
	if strcmp(Sound,'RN')
%		a=10^(-MdB/10);
%		RMSP=(a-1)/log(a);                                      % RMS value of normalized Spectral Profile
%		MeanP=mean(10.^(MdB*fread(fid,1024*256,'float')/10));   % Same as RMSP but need to compute Numerically 
									% because Theoretical Slightly off
		a=10^(-MdB/20);
		RMSP=sqrt((a^2-1)/2/log(a)-((a-1)/log(a))^2);		% RMS value of normalized Spectral Profile
		MeanP=mean(10.^(MdB*fread(fid,1024*1024,'float')/20));  % Same as RMSP but need to compute Numerically 
									% because Theoretical Slightly off
	elseif strcmp(Sound,'MR')
		%dx=.01;
		%RMSP=1/2/pi*10^(-MdB/20);
		%RMSP=RMSP*dx*sum(10.^(MdB/20*sin(0:dx:2*pi)));          % RMS value of normalized Spectral Profile
		%MeanP=RMSP;
        
		RMSP=std(10.^(MdB*fread(fid,1024*1024,'float')/20));
		MeanP=mean(10.^(MdB*fread(fid,1024*1024,'float')/20));
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

	%Bootstrap Block Number
	NBS1=1;
	NBS2=1;

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

			%Advancing Bootstrap Block Counter
			if spet(index1(k))>min(Trig)+TBootBlock*NBS1;
				NBS1=NBS1+1;
			end

			%Averaging Pre-Event Spectral Profiles
			if L < N2
				STRF1(:,:,kk1,NBS1)=STRF1(:,:,kk1,NBS1)+ ( 10.^(MdB*[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)]/20) - MeanP ) / RMSP*sqrt(PP);
			elseif L+N1 > M
				STRF1(:,:,kk1,NBS1)=STRF1(:,:,kk1,NBS1)+ ( 10.^(MdB*[S2(:,L-N2+1:M) S3(:,1:N1-M+L)]/20) - MeanP ) / RMSP*sqrt(PP);
			else
				STRF1(:,:,kk1,NBS1)=STRF1(:,:,kk1,NBS1)+ ( 10.^(MdB*S2(:,L-N2+1:L+N1)/20) - MeanP ) / RMSP*sqrt(PP);
			end

			%Counting the number of Spikes averaged
			No1(NBS1)=No1(NBS1)+1;      %(Edit, Escabi/Chen Oct 2008)

		end

		%Finding Receptive Field for Channel 2
		for k=1:length(spettrig2)

			%Setting Spike Time and STRF length
			M=size(S1);M=M(2);
			L=spettrig2(k);
			kk2=KK2(k);

			%Advancing Bootstrap Block Counter
			if spet(index2(k))<max(Trig)+mean(diff(Trig))-TBootBlock*NBS2;
				NBS2=NBS2+1;
			end

			%Averaging Pre-Event Spectral Profiles
			if L < N1
				STRF2(:,:,kk2,NBS2)=STRF2(:,:,kk2,NBS2)+ ( 10.^(MdB*[S1(:,M-(N1-L-1):M) S2(:,1:L+N2)]/20) - MeanP ) / RMSP*sqrt(PP);
			elseif L+N2 > M
				STRF2(:,:,kk2,NBS2)=STRF2(:,:,kk2,NBS2)+ ( 10.^(MdB*[S2(:,L-N1+1:M) S3(:,1:N2-M+L)]/20) - MeanP ) / RMSP*sqrt(PP);
			else
				STRF2(:,:,kk2,NBS2)=STRF2(:,:,kk2,NBS2)+ ( 10.^(MdB*S2(:,L-N1+1:L+N2)/20) - MeanP ) / RMSP*sqrt(PP);
			end

			%Counting the number of Spikes averaged
			No2(NBS2)=No2(NBS2)+1;          %(Edit, Escabi/Chen Oct 2008)

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
			taxis=(-N1:N2-1)/(Fs/DF);
			subplot(211)

			%Displaying STRF1
			pcolor(taxis,log2(faxis/500),fliplr(sum(sum(STRF1,4),3))/sqrt(PP)/T); %Edited Chen Oct. 2008
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(sum(No1)) ' ( Spikes ), Wo = ' num2str(sum(No1)/T,5) ' ( Spikes/Sec )'])

			%Displaying STRF2
			subplot(212)
			pcolor(taxis,log2(faxis/500),sum(sum(STRF2,4),3)/sqrt(PP)/T);   %Edited Chen Oct. 2008
			shading flat,colormap jet,colorbar
			title(['No = ' int2str(sum(No2)) ' ( Spikes ) , Wo = ' num2str(sum(No2)/T,5) ' ( Spikes/Sec )'])
			pause(0)
		end
	end	


	%Normalizing STRF According to Paper by Van Dijk
	taxis=(-N1:N2-1)/(Fs/DF);
        if max(spet)>max(Trig)
                T=( max(Trig) - min(Trig) )/Fss;
        else
                T=( max(spet) - min(spet) )/Fss;
        end
	if ~( T==0 | isempty(T) )
		Wo1=No1/(T/NBoot);              %Edited Chen Oct. 2008
		Wo2=No2/(T/NBoot);              %Edited Chen Oct. 2008
	else
		No1=-9999;						%No Spikes
		No2=-9999;
	end
	for k=1:UF
		for l=1:NBoot
			STRF1(:,:,k,l)=Wo1(l)/PP*fliplr(STRF1(:,:,k,l))/No1(l);        %Edit Chen/Escabi Oct 2008
            STRF2(:,:,k,l)=Wo2(l)/PP*STRF2(:,:,k,l)/No2(l);                %Edit Chen/Escabi Oct 2008
		end
    end

if UF~=1
	%Interpolating, Realigning, and adding the Waveforms
	for k=1:UF
		for l=1:NBoot
		dT=taxis(3)-taxis(2);
		STRF1i(:,:,k,l)=interp1(taxis,STRF1(:,:,k,l)',(-N1*UF:N2*UF-1)*dT/UF+k*dT/UF,'cubic')';
		STRF2i(:,:,k,l)=interp1(taxis,STRF2(:,:,k,l)',(-N1*UF:N2*UF-1)*dT/UF-k*dT/UF+dT,'cubic')';
		end
	end
end
	taxis=(-UF*N1:N2*UF-1)/(Fs/DF*UF);

if UF~=1
	%Truncating Waveforms to Appropriate Size
	STRF1=sum(STRF1i(:,2*UF+1:length(taxis)-2*UF,:,:),3);
	STRF2=sum(STRF2i(:,2*UF+1:length(taxis)-2*UF,:,:),3);
	taxis=(-UF*(N1-2):(N2-2)*UF-1)/(Fs/DF*UF);
end

end

%Reshaping STRFs
N1=size(STRF1,1);
N2=size(STRF1,2);
N3=size(STRF1,3);
N4=size(STRF1,4);
STRF1=reshape(STRF1,N1,N2,N4,N3);
STRF2=reshape(STRF2,N1,N2,N4,N3);

%Closing all opened files
fclose all

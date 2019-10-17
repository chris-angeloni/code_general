%function [taxis,faxis,WSTRF,PP]=wstrfspec(infile,T1,T2,df,dch,spet,SPL,UT,UF,win,ATT)
%
%       FILE NAME       : WSTRF SPEC
%       DESCRIPTION     : 2nd order spectro-temporal Wiener Receptive Field
%			  Uses Lee/Schetzen Aproach via Spectogram Transform
%
%	infile		: Input file name
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%	df		: Frequency Resolution for Spectogram.
%			  Note that temporal resolution satisfies dt~=4/df/4/pi
%	dch		: Data Channel as given by DAT Recorder ( Stimulus )
%	spet		: Array of spike event times in sample number
%	SPL		: Signal RMS Sound Pressure Level
%
%	Optional Parameters
%	UT		: Temporal upsampling factor
%	UF		: Spectral upsampling factor
%	win		: Window to use for STFFT: 'sinc' or 'gauss'
%			  Default=='sinc'
%	ATT		: Window ATT if 'sinc' is choosen
%			  Default==60 dB
%	
function [taxis,faxis,WSTRF,PP]=wstrfspec(infile,T1,T2,df,dch,spet,SPL,UT,UF,win,ATT)

if nargin==7
	UT=1;
	UF=1;
	win='sinc';
	ATT=60;
elseif nargin==8
	UF=1;
	win='sinc';
	ATT=60;
elseif nargin==9
	win='sinc';
	ATT=60;
elseif nargin==10
	ATT=60;
end

%Preliminaries
more off;

%Finding File Information
[Fs,interleave] = dat_header(infile);
%Fs=48000;
%interleave=1;
nchannel=length(interleave);
dch=find(dch==interleave);

%Converting delay intervals to samples
N1=round(T1*Fs);
N2=round(T2*Fs);
N=length(spet);

%Opening Input File
fid=fopen(infile,'r');

%Finding Signal RMS Sound Pressure from SPL
Po=2.2E-5;		% Threshold of Hearing at 1KHz in Pascals
P= Po*10^(SPL/20);	% Pressure conversion
PP=P*P;			% Power spectrum

%Finding RMS value of the input signal ( X ) 
%Which is used for Sound Pressure Normalization
%Recall From Parsevals!!!
%	sum(mean(stft.*conj(stft)))*dt*Fs==sum(x.^2)==mean(XX)
M=1024*512;
for k=1:4
	%Reading a Data Chunk
	if feof(fid)!=1	%Checking for EOF
		X=fread(fid,M*nchannel,'int16');
	end
end
X=fread(fid,(N2-N1)*nchannel,'int16');
X=X(dch:nchannel:length(X));
[taxis,faxis]=stfft(X,Fs,df,UT,UF,win,'n',ATT);		%Getting taxis
XX=fft(X);
XX=real(XX.*conj(XX));
RMSP=sqrt(mean(XX)/taxis(2)/Fs/length(taxis));		%RMS Power
clear X XX;

%Computing Spectro Temporal REVCORR
clc
disp(['Evaluating STFT REVCORR: ' num2str(length(spet)) ' spikes'])
WSTRF=[];
for k=1:N
	if (spet(k)-N2-1)*nchannel > 1
		%Extracting Input Signal
		%Normalization is only aproximate!!!
		fseek(fid,2*((spet(k)-N2-1)*nchannel),-1);
		X=P/RMSP*fread(fid,(N2-N1)*nchannel,'int16');
		X=fliplr( X(dch:nchannel:length(X))' );

		%Computing Pre-Event Spectogram
		[taxis,faxis,stft]=stfft(X,Fs,df,UT,UF,win,'n',ATT);

		%Initialize if necesary
		if isempty(WSTRF)
			WSTRF=zeros(size(stft));
		end

		%Second Order Receptive Field Averaging
		WSTRF=WSTRF + stft.*conj(stft) / N;
	end

	%Percent Done
	clc
	disp(['Evaluating STFT REVCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
end
clear X stft;

%Computing Spectro Temporal Signal Power (PSTFT)
clc
disp(['Evaluating STFT XCORR: ' num2str(length(spet)) ' spikes'])
frewind(fid);
count=1;
PSTFT=zeros(size(WSTRF));
for k=1:N
	X=P/RMSP*fread(fid,(N2-N1)*nchannel,'int16');
	if ~feof(fid)==1
		%Extracting Input Signal
		X=fliplr( X(dch:nchannel:length(X))' );
		[taxis,faxis,stft]=stfft(X,Fs,df,UT,UF,win,'n',ATT);
	
		%Second Order Power Averaging
		PSTFT=PSTFT + stft.*conj(stft) ;
		count=count+1;
		
		%Percent Done
		clc
		disp(['Evaluating STFT XCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
	end
end
PSTFT=PSTFT/count;	%Converts sum to a mean 
clear X stft;

%Substracting Mean Power Level (PSTFT) from WSTRF
%And Normalizing According to Paper by Van Dijk
T=max(spet)/Fs;
No=N/T;
WSTRF=No/fact(2)/PP^2 * (WSTRF-PSTFT);

%Number of Spikes
clc
disp([num2str(N) ' Spikes Used']);

%Closing File
fclose(fid);


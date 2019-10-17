%function [taxis,faxis,WSTK]=wstk(infile,Fs,T1,T2,df,nchannel,dch,spet,SPL,UT,UF,win,ATT)
%
%       FILE NAME       : WSTK
%       DESCRIPTION     : 2nd order spectro-temporal Wiener Kernel
%			  Uses Lee/Schetzen Aproach via Spectogram Transform
%
%	infile		: Input file name
%	Fs		: Sampling Rate
%	T1, T2		: Evaluation delay interval for WSTK(F1,F2,T)
%	df		: Frequency Resolution for Spectogram.
%			  Note that temporal resolution dt~=4/df/4/pi
%	nchannel	: Number of channels
%	dch		: Data Channel ( Stimulus )
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
function [taxis,faxis,WSTK]=wstk(infile,Fs,T1,T2,df,nchannel,dch,spet,SPL,UT,UF,win,ATT)

if nargin==9
	UT=1;
	UF=1;
	win='sinc';
	ATT=60;
elseif nargin==10
	UF=1;
	win='sinc';
	ATT=60;
elseif nargin==11
	win='sinc';
	ATT=60;
elseif nargin==12
	ATT=60;
end

%Preliminaries
more off;

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
M=100;
for k=1:4
	%Reading a Data Chunk
	if feof(fid)!=1	%Checking for EOF
		X=fread(fid,M*nchannel,'int16');
	end
end
X=fread(fid,(N2-N1)*nchannel,'int16');
X=X(dch:nchannel:length(X));
[taxis,faxis,stft]=stfft(X,Fs,df,UT,UF,win,'n',ATT);
XX=fft(X);
XX=real(XX.*conj(XX));
RMSP=sqrt(mean(XX)/taxis(2)/Fs/length(taxis));

%Finding STK Dimmensions
frewind(fid);
X=fread(fid,(N2-N1)*nchannel,'int16');
X=X(dch:nchannel:length(X));
[taxis,faxis,stft]=stfft(X,Fs,df,UT,UF,win,'n',ATT);
Nt=length(taxis);
Nf=length(faxis);

%Computing Spectro Temporal REVCORR
clc
disp(['Evaluating STK REVCORR: ' num2str(length(spet)) ' spikes'])
WSTK=[];
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
		if isempty(WSTK)
			WSTK=zeros(Nf,Nf,Nt);
		end

		%Spectrotemporal Kernel Averaging
		for l=1:Nt
			WSTK(:,:,l)=WSTK(:,:,l)+stft(:,l)*stft(:,l)'/N;
		end

	end

	%Percent Done
	clc
	disp(['Evaluating STK REVCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
end

%Computing Spectro Temporal Signal Power (PSTFT)
clc
disp(['Evaluating STFT XCORR: ' num2str(length(spet)) ' spikes'])
frewind(fid);
count=1;
PSTK=zeros(size(WSTK));
for k=1:N
	X=P/RMSP*fread(fid,(N2-N1)*nchannel,'int16');
	if ~feof(fid)==1
		X=fliplr( X(dch:nchannel:length(X))' );
		[taxis,faxis,stft]=stfft(X,Fs,df,UT,UF,win,'n',ATT);

		%Spectrotemporal Power Averaging
                for l=1:Nt
			PSTK(:,:,l)=PSTK(:,:,l)+stft(:,l)*stft(:,l)';
                end
		count=count+1;
		
		%Percent Done
		clc
		disp(['Evaluating STK XCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
	end
end
PSTK=PSTK/count;

%Substracting Mean Power Level (PSTK) from WSTK
%And Normalizing According to Paper by Van Dijk
T=max(spet)/Fs;
No=N/T;
WSTK=No/2/PP^2*(WSTK-PSTK);

%Number of Spikes
clc
disp([num2str(N) ' Spikes Used']);

%Closing File
fclose(fid);


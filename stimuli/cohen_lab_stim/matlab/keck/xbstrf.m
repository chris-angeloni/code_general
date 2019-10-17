%function [taxis,faxis,XBSTRF]=xbstrf(infile,Fs,T1,T2,df,nchannel,dchC,dchI,spet,SPL,UT,UF,win,ATT)
%
%       FILE NAME       : XBSTRF 
%       DESCRIPTION     : 4th order binaural cross spectro-temporal Receptive Field
%			  Uses Lee/Schetzen Aproach via Spectogram Transform
%			  to calculate the binaural cross kernel between the 
%			  ipsilateral and contralateral channels
% 
%	infile		: Input file name
%	Fs		: Sampling Rate
%	T1, T2		: Evaluation delay interval for XBSTRF(T,F)
%			  T = [T1 T2] ( sec )
%	df		: Frequency Resolution for Spectogram.
%			  Note that temporal resolution dt~=4/df/4/pi
%	nchannel	: Number of channels
%	dchC,dchI	: Contra and Ipsi Data Channel ( Stimulus Set)
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
function [taxis,faxis,XBSTRF]=xbstrf(infile,Fs,T1,T2,df,nchannel,dchC,dchI,spet,SPL,UT,UF,win,ATT)

if nargin==10
	UT=1;
	UF=1;
	win='sinc';
	ATT=60;
elseif nargin==11
	UF=1;
	win='sinc';
	ATT=60;
elseif nargin==12
	win='sinc'
	ATT=60;
elseif nargin==13
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
for k=1:4
	%Reading a Data Chunk
	if feof(fid)!=1	%Checking for EOF
		X=fread(fid,M*nchannel,'int16');
	end
end
X=fread(fid,(N2-N1)*nchannel,'int16');
XC=X(dchC:nchannel:length(X));
XI=X(dchI:nchannel:length(X));
clear X;
[taxis,faxis]=stfft(XC,Fs,df,UT,UF,win,'n',ATT);	%Geting taxis
XXC=fft(XC);
XXI=fft(XI);
XXC=real(XXC.*conj(XXC));
XXI=real(XXI.*conj(XXI));
RMSPC=sqrt(mean(XXC)/taxis(2)/Fs/length(taxis));	%RMS Power 
RMSPI=sqrt(mean(XXI)/taxis(2)/Fs/length(taxis));
clear XXC XXI;

%Computing Spectro Temporal REVCORR
clc
disp(['Evaluating STFT REVCORR: ' num2str(length(spet)) ' spikes'])
XBSTRF=[];
for k=1:N
	if (spet(k)-N2-1)*nchannel > 1
		fseek(fid,2*((spet(k)-N2-1)*nchannel),-1);
		%Normalization is only aproximate!!!
		X=fread(fid,(N2-N1)*nchannel,'int16');
		XC=P/RMSPC*fliplr( X(dchC:nchannel:length(X))' );
		XI=P/RMSPI*fliplr( X(dchI:nchannel:length(X))' );
		[taxis,faxis,stftC]=stfft(XC,Fs,df,UT,UF,win,'n',ATT);
		[taxis,faxis,stftI]=stfft(XI,Fs,df,UT,UF,win,'n',ATT);
		if isempty(XBSTRF)
			XBSTRF=zeros(size(stftI));
		end
		XBSTRF=XBSTRF+real(stftC.*conj(stftC).*stftI.*conj(stftI))./N;
	end

	%Percent Done
	clc
	disp(['Evaluating XB STFT REVCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
end
clear X XC XI stftC stftI;

%Computing Spectro Temporal Signal Power (PSTFT)
clc
disp(['Evaluating STFT XCORR: ' num2str(length(spet)) ' spikes'])
frewind(fid);
count=1;
PSTFT=zeros(size(XBSTRF));
for k=1:N
	X=fread(fid,(N2-N1)*nchannel,'int16');
	if ~feof(fid)==1
		XC=P/RMSPC*fliplr( X(dchC:nchannel:length(X))' );
		XI=P/RMSPI*fliplr( X(dchI:nchannel:length(X))' );
		[taxis,faxis,stftC]=stfft(XC,Fs,df,UT,UF,win,'n',ATT);
		[taxis,faxis,stftI]=stfft(XI,Fs,df,UT,UF,win,'n',ATT);
		PSTFT=PSTFT+real(stftC.*conj(stftC).*stftI.*conj(stftI));
		count=count+1;
		
		%Percent Done
		clc
		disp(['Evaluating XB STFT XCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
	end
end
PSTFT=PSTFT/count;
clear X XC XI stftC stftI;

%Substracting Mean Power Level (PSTFT) from WSTRF
%And Normalizing According to Paper by Van Dijk
T=max(spet)/Fs;
No=N/T;
XBSTRF=No/fact(4)/PP^4*(XBSTRF-PSTFT);

%Number of Spikes
clc
disp([num2str(N) ' Spikes Used']);

%Closing File
fclose(fid);


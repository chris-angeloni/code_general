%
%function [taxis,faxis,WSTFT]=wstft(infile,Fs,T1,T2,df,nchannel,dch,spet)
%
%       FILE NAME       : WSTFT 
%       DESCRIPTION     : 1st Order Wiener Short Term Fourier Transform Kernel
%			  Uses Lee/Schetzen Aproach
%
%	infile		: Input file name
%	Fs		: Sampling Rate
%	T1, T2		: Evaluation delay interval for W1(T)
%			  T = [T1 T2] ( sec )
%	df		: Frequency Resolution for Spectogram
%	nchannel	: Number of channels
%	dch		: Data Channel ( Stimulus ) 
%	spet		: Array of spike event times
%
function [taxis,faxis,WSTFT]=wstft(infile,Fs,T1,T2,df,nchannel,dch,spet)

%Preliminaries
more off;

%Converting delay intervals to samples
N1=round(T1*Fs);
N2=round(T2*Fs);
N=length(spet);

%Opening Input File
fid=fopen(infile,'r');

%Computing 1st Order Kernel
clc
disp(['Evaluating STFT REVCORR: ' num2str(length(spet)) ' spikes'])
%WSTFT=zeros(1,N2-N1);
WSTFT=[];
for k=1:N
	if (spet(k)-N2-1)*nchannel > 1
		fseek(fid,2*((spet(k)-N2-1)*nchannel),-1);
		X=fread(fid,(N2-N1)*nchannel,'int16');
		X=fliplr( X(dch:nchannel:length(X))' );
		[taxis,faxis,stft]=stfft(X,Fs,df,1,1'sinc','n',60);
		if isempty(WSTFT)
			WSTFT=zeros(size(stft));
		end
		WSTFT=WSTFT+abs(stft).^2/N;
	end

	%Percent Done
	clc
	disp(['Evaluating STFT REVCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
end

%Computing Mean Signal STFT Power (PSTFT)
frewind(fid);
count=1;
PSTFT=zeros(size(WSTFT));
for k=1:N
	X=fread(fid,(N2-N1)*nchannel,'int16');
	if ~feof(fid)==1
		X=fliplr( X(dch:nchannel:length(X))' );
		[taxis,faxis,stft]=stfft(X,Fs,df,1,1,'sinc','n',60);
		PSTFT=PSTFT+abs(stft).^2;
		count=count+1;

	%Percent Done
	clc
	disp(['Evaluating STFT XCORR: ' num2str(k) ' Spikes of ' num2str(N)]);

	end
end
PSTFT=PSTFT/count;

%Substracting Mean Power Level (PSTFT) from WSTFT
WSTFT=WSTFT-PSTFT;

%Number of Spikes
clc
disp([num2str(N) ' Spikes Used']);

%Closing File
fclose(fid);


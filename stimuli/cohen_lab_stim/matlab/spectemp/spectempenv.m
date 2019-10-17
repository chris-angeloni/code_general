%
%function []=spectempenv(filename,f1,f2,df,UT,UF,Fs,win,ATT,TW,method,N,M)
%
%	FILE NAME 	: SPEC TEMP ENV
%	DESCRIPTION 	: Computes the Spectro-Temporal Envelope 
%			  of a Sound via detrended spectrogram
%			  Note: Sound is detrended prior to 
%			  performing spectrogram analysis
%			  Save file as .spg
%
%	filename	: Input File Name
%	f1		: Lower frequency used for analysis 
%	f2		: Upper frequency used for analysis 
%       df              : Frequency Window Resolution (Hz)
%                         Note that by uncertainty principle
%                         (Chui and Cohen Books)
%                         dt * df > 1/pi
%                         Equality holding for the gaussian case!!!
%       UT              : Temporal upsampling factor fo stfft
%                         Increases temporal sampling resolution.
%                         Must be a positive integer. 1 indicates
%                         no upsampling.
%       UF              : Frequncy upsampling factor stfft
%                         Increases spectral sampling resolution.
%                         Must be a positive integer. 1 indicates
%                         no upsampling.
%	Fs		: Sampling Rate
%	win             : 'sinc', 'sincfilt', 'gauss' : Optional Default=='sinc'
%       ATT             : Attenution / Sidelobe error in dB (Optional)
%                         Default == 100 dB, ignored if win=='gauss'
%	TW		: Filter Transition Width: If win=='sinc' or 'gauss'
%			  This value is set to zero
%       method          : Method used to determine spectral and temporal
%                         resolutions - dt and df
%                         '3dB'  - measures the 3dB cutoff frequency and
%                                  temporal bandwidth
%                         'chui' - uses the uncertainty principle
%                         Default == '3dB'
%	N		: Polynomial order for pre-whitening ( Default = 1 )
%	M		: Block size to compute STFFT
%			  Default: 1024*32
%			  Note that M/Fs is the time resolution f the 
%			  contrast distribution
%
function []=spectempenv(filename,f1,f2,df,UT,UF,Fs,win,ATT,TW,method,N,M)

%Input Arguments
if nargin <8
	win='sinc';
end
if nargin <9
	ATT=100;
end
if nargin<10
	TW=0.75*df;
end
if nargin<11
	method='3dB';
end
if nargin<12
	N=1;
end
if nargin<13
	M=1024*32;
end

%Pre-Whitening Input File - Saves as a 'float' file
tempfile='temp_prewhite.bin';
if exist(filename)
	f=['!rm ' tempfile];
	eval(f)
end
prewhitenfile(filename,tempfile,Fs,f1,f2,df,N,'int16',1024*256);

%Opening Temporary File and Output File
fid=fopen(tempfile);
index=findstr(filename,'.');
fidout=fopen([filename(1:index-1),...
'_DF' int2str(df) 'HzN' int2str(N) '.spg'  ],'w');

%Finding stft size and Filter Order
%To avoid edge effects
%This is necessary so that we choose M to be slightly bigger 
Y=rand(1,M);				%Dummy Signal
[t,f,stft,MF,Nt,Nf]=stfft(Y-mean(Y),Fs,df,UT,UF,win,ATT,method,'n',TW);
M=M+2*MF;				%The New Data Length
KK=ceil(MF/Nt);				%Number of samples to remove at edges

%Reading File and Finding Spectrotemporal envelope
flag=1;
count=0;
while ~feof(fid)

	%Displaying Output 
	clc
	disp(['Computing Spectro-temporal envelope: Block ' int2str(count+1)]);

	%Extracting M-Sample Segment From File
	Y=fread(fid,M,'float');

	if length(Y)>0

	    %Computing Short-Time Fourier Transform
	    [t,f,stft]=stfft(Y-mean(Y),Fs,df,UT,UF,win,ATT,method,'n',TW);

	    %Finding index for f1 and f2
	    dff=f(2)-f(1);
	    indexf1=ceil(f1/dff);
	    indexf2=floor(f2/dff);

	    %Selecting Spectrogram between f1-f2
	    stft=stft(indexf1:indexf2,:);
	    f=f(indexf1:indexf2);

	    %Finding Temporal Spectrogram Block
	    %Removing Temporal Blocks Near Edge To Avoid Edge Effects
	    stft=stft(:,KK+1:length(t)-KK);
	    t=t(KK+1:length(t)-KK);

	    %Computing Spectrogram
	    S=10*log10(real(stft.*conj(stft)));
	    if ~feof(fid)
		taxis=t;
		faxis=f;
	    	NF=length(f);
	    	NT=length(t);
	    	S=reshape(S,1,NT*NF);
	    else %So NT does not get overwritten by the size for last block
	    	NFF=length(f);
	    	NTT=length(t)
	    	S=reshape(S,1,NTT*NFF);
	    end
	
	    %Saving to output File
	    fwrite(fidout,S,'float');

	    %Incrementing count variable
	    count=count+1;

	    %Setting File Pointer
	    %Note that last several blocks may be read 
	    %although feof(fid)==1, because of overlap save method
	    fseek(fid,4*(count*M+1-count*2*Nt*KK),-1);

	end
end

%Saving Data
f=['save ' filename(1:index-1) '_DF' int2str(df) 'HzN' int2str(N) '_param NF NT N ATT TW df method Nt Nf MF taxis faxis '];
index=findstr(filename,'.');
if findstr(version,'5.')
	f=[f ' -v4'];
end
eval(f);

%Removing Temporary File
f=['!rm ' tempfile];
eval(f);

%Closing all Files
fclose('all');

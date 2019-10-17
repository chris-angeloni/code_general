%
%function []=wav2spr(filename,N,df,UT,UF,win,ATT,method)
%	
%	FILE NAME 	: WAV 2 SPR
%	DESCRIPTION 	: Computes the Spectogram of the data contained
%			  in "filename" and stores the spectogram as a 
%			  linear array 'float' file
%
%	filename	: Input "WAV" file
%	N		: Number of samples between triggers
%	df		: Frequency Window Resolution (Hz)
%
%Optional Parameters
%	UT		: Temporal upsampling factor.
%	UF		: Frequncy upsampling factor.
%	win		: 'sinc' or 'gauss' or 'sincfilt' : Optional Default=='sinc'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB, ignored if win=='gauss'
%	method          : Method used to determine spectral and temporal 
%			  resolutions - dt and df
%			  '3dB'  - measures the 3dB cutoff frequency and 
%			  temporal bandwidth
%			  'chui' - uses the uncertainty principle
%
function []=wav2spec(filename,N,df,UT,UF,win,ATT,method)

%Input Arguments
if nargin<4
	UT=1;
end
if nargin<5
	UF=1;
end
if nargin<6
	win='sinc';
end
if nargin<7
	ATT=60;
end
if nargin<8
	method='chui';
end

%Opening Input File and Output File
fidin=fopen(filename);
index=find(filename=='.');
filename=filename(1:index-1);
fidout=fopen([filename '.spr'],'w');	%spr==Spectral Profile

%Reading Header
fseek(fidin,24,-1);
Fs=fread(fidin,1,'ushort');
fseek(fidin,22,-1)
nchan=fread(fidin,1,'ushort');
fseek(fidin,34,-1);
bits=fread(fidin,1,'ushort')

%Finding Window Function and Necessary Parameters 
%Finding Windowing Function 
if strcmp(win,'gauss')
        %Finding Gausian / Gabor Window 
        dt=2/2/pi/df;   %Charles Chui Book - Uncertainty Principle 
        alpha=dt/2;
        M=round(5*alpha*Fs);
        taxis=(-M:M)/Fs;
        W=1/sqrt(4*pi*alpha^2)*exp(-(taxis).^2/4/alpha^2);
elseif strcmp(win,'sinc')
        %Finding Sinc(a,p) window as designed by Roark / Escabi
        if strcmp(method,'3dB')
                W=designw(df,ATT,Fs,'3dB');
        else
                W=designw(df,ATT,Fs,'chui');
        end
        M=(length(W)-1)/2;
elseif strcmp(win,'sincfilt')
        %Finding Sinc(a,p) filter as designed by Roark / Escabi
        W=lowpass(df/2,TW,Fs,ATT,'off');
        M=(length(W)-1)/2;
end     
dN=M;			%Number of Extra Samples for Edges 

%Reading Data and Computing Spectrogram
counter=1;
flag=0;		%Used to indicate last segment
while ~feof(fidin)

	if counter==1

		%Repositioning Pointer at End of Header
		fseek(fidin,22*2,-1);

		%Reading First Data Block
		X=fread(fidin,N+dN,'int16');
		X=[zeros(1,dN) X']';

	elseif ~feof(fidin)

		%Repositioning Pointer
		fseek(fidin,2*( 22+N*(counter-1)-dN ),-1);
		
		%Reading Intermediate Data Block
		X=fread(fidin,N+2*dN,'int16');

		%Appending Zeros to Last Block
		if length(X)~=N+2*dN
			X=[X' zeros(1,N+2*dN-length(X))]';
			flag=1;		%Last Segment
		end

	end

	%Computing Short-Time Fourier Transfrom
	[taxis,faxis,stft]=stfft(X,Fs,df,UT,UF,win,ATT,method);

	%Truncating Edges
	L=round( ( length(taxis)-N/Fs/taxis(2) )/2 );

	stft=stft(:,(L+1:length(taxis)-L));
	taxis=taxis(L+1:length(taxis)-L);
	taxis=taxis-min(taxis);

	%Finding Desired Spectrogram
	SpectroGram=real(stft.*conj(stft));

	%Saving to File
	NT=length(taxis);
	NF=length(faxis);
	fwrite(fidout,reshape(SpectroGram,1,NT*NF),'float');

	%Display
	clc
	disp(['Segment Number: ' int2str(counter)])

	%Updating Segment Counter
	counter=counter+1;
end

%Temporal Downsampling Factor
DF=Fs*(taxis(2));

%Saving Parameter File
ParamFile=[filename '_param.mat'];
f=['save ' ParamFile ' taxis faxis NT NF Fs DF'];
eval(f)

%Closing all files
fclose('all');

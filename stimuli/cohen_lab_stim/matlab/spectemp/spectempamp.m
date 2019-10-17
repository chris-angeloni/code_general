%
%function [Time,Amp,PDist]=spectempamp(filename,f1,f2,df,UT,UF,Fs,win,ATT,TW,method,N,M,Disp,Save)
%
%	FILE NAME 	: SPEC TEMP AMP
%	DESCRIPTION 	: Computes the Spectro-Temporal Modulation 
%			  Amplitude Distribution of a Sound at
%			  time intervals of DT
%			  Note: Sound is pre-whitened prior to 
%			  performing analysis
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
%	N		: Polynomial order for pre-whitening ( Default = 3 )
%	M		: Block size to compute STFFT
%			  Default: 1024*32
%			  Note that M/Fs is the time resolution f the 
%			  contrast distribution
%	Disp		: Display output window: 'y' or 'n' ( Default = 'n')
%	Save		: Save to File         : 'y' or 'n' ( Default = 'n')
%
%RETUERNED VARIABLES
%	Time		: Time Axis
%	Amp		: Amplitude Axis ( decibels )
%	PDist		: Time Dependent Probability Distribution of Amp
%
function [Time,Amp,PDist]=spectempamp(filename,f1,f2,df,UT,UF,Fs,win,ATT,TW,method,N,M,Disp,Save)

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
	N=3;
end
if nargin<13
	M=1024*32;
end
if nargin<14
	Disp='n';
end
if nargin<15
	Save='n';
end

%Pre-Whitening Input File - Saves as a 'float' file
tempfile='temp_prewhite.bin';
if exist(filename)
	f=['!rm ' tempfile];
	eval(f)
end
prewhitenfile(filename,tempfile,Fs,0,Fs/2,df,N,'int16',1024*512);

%Opening Temporary File
fid=fopen(tempfile);

%Generating Filters Used for stfft
%This is necessary so that we choose M to be slightly biger 
%so that no edge effects occur
%Finding Sinc(a,p) filter as designed by Roark / Escabi
W=lowpass(df/2,TW,Fs,ATT,'off');
MF=(length(W)-1)/2;			%Filter Order
M=M+2*MF;				%The New Data Length

%Reading File and Finding Amplitude Statistics
flag=1;
count=0;
PDist=[];
while flag

	%Extracting M-Sample Segment From File
	Y=fread(fid,M,'float');

	%Computing Distribution
	if length(Y)==M

		%Displaying Output 
		clc
		disp(['Computing Time Varying Contrast Distribution:  Block ' int2str(count+1)]);

		%Computing Short-Time Fourier Transform
		[t,f,stft]=stfft(Y-mean(Y),Fs,df,UT,UF,win,ATT,method,Disp,TW);

		%Finding index for f1 and f2
		dff=f(2)-f(1);
		indexf1=ceil(f1/dff);
		indexf2=floor(f2/dff);

		%Selecting Spectrogram between f1-f2
		stft=stft(indexf1:indexf2,:);
		f=f(indexf1:indexf2);

		%Finding Temporal Spectrogram Block Used to Compute Contrast
		%Removing Temporal Blocks Near Edge To Avoid Edge Effects
		MB=ceil(MF/(t(2)-t(1))/44100);
		if MB/2==floor(MB/2)
			stft=stft(:,MB/2+1:length(t)-MB/2);
			t=t(MB/2+1:length(t)-MB/2);
		else
			MB=MB-1;
			stft=stft(:,MB/2+2:length(t)-MB/2);
			t=t(MB/2+2:length(t)-MB/2);
		end

		%Computing Time Varying Distribution
		S=10*log10(real(stft.*conj(stft)));
		S=reshape(S,1,length(t)*length(f));
		[P,Amp]=hist(S,[-100:1:100]);
		PDist=[PDist P'/length(S)];
		Amp=Amp';

		%Incrementing count variable
		count=count+1;

		%Displaying output if desired
		if strcmp(Disp,'y')
			if count>1
				subplot(311)
				pcolor((count*length(Y))/Fs + t,f,10*log10(real(stft.*conj(stft))))
				shading flat, colormap jet
				subplot(312)
				plot((count*length(Y)+(0:length(Y)-1))/Fs,Y-mean(Y))
				axis([(count)*length(Y)/Fs,...
				((count+1)*length(Y)-1)/Fs min(Y-mean(Y)),...
			 	max(Y-mean(Y))])
				subplot(313)
				pcolor((1:size(PDist,2)),Amp,PDist)
				shading flat,colormap jet
				pause(0)
			end		
		end

	else
		flag=0;
	end

end

%Generating Time Axis
Time=(0:size(PDist,2)-1)*M/Fs;

%Saving Data if Desired
if strcmp(Save,'y')
	index=findstr(filename,'.');
	f=['save ' filename(1:index-1) '_ContDf' int2str(df) 'HzN' int2str(N) ' Time Amp PDist N W ATT TW df method'];
	if findstr(version,'5.')
		f=[f ' -v4'];
	end
	eval(f);
end

%Removing Temporary File
f=['!rm ' tempfile];
eval(f)

%Closing all Files
fclose('all')

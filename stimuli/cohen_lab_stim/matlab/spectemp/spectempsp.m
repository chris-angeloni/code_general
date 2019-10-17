%
%function [SS]=spectempsp(filename,f1,f2,df,UT,UF,Fs,win,ATT,N,M,Disp,Save)
%
%	FILE NAME 	: SPEC TEMP SP
%	DESCRIPTION 	: Computes the Spectro-Temporal Envelope
%			  Spectrum of a Sound
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
%	win             : 'sinc' or 'gauss' : Optional Default=='sinc'
%       ATT             : Attenution / Sidelobe error in dB (Optional)
%                         Default == 100 dB, ignored if win=='gauss'
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
function [SS]=spectempsp(filename,f1,f2,df,UT,UF,Fs,win,ATT,N,M,Disp,Save)

%Input Arguments
if nargin <8
	win='sinc';
end
if nargin <9
	ATT=100;
end
if nargin<10
	N=3;
end
if nargin<11
	M=1024*32;
end
if nargin<12
	Disp='n';
end
if nargin<13
	Save='n';
end

%Pre-Whitening Input File - Saves as a 'float' file
tempfile='/tmp/temp_prewhite.bin';
if exist(filename)
	f=['!rm ' tempfile];
	eval(f)
end
prewhitenfile(filename,tempfile,Fs,f1,f2,df,N,'int16',1024*32);

%Opening Temporary File
fid=fopen(tempfile);

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
		disp(['Computing Envelope Spectrum :  Block ' int2str(count+1)]);

		%Computing Short-Time Fourier Transform
		[t,f,stft]=stfft(Y-mean(Y),Fs,df,UT,UF,win,'n',ATT);

		%Finding index for f1 and f2
		dff=f(2)-f(1);
		indexf1=ceil(f1/dff);
		indexf2=floor(f2/dff);

		%Selecting Spectrogram between f1-f2
		stft=stft(indexf1:indexf2,:);
		f=f(indexf1:indexf2);

		%Computing Envelope Spectrum
		S=10*log10(real(stft.*conj(stft)));
		N1=2^nextpow2(size(S,1));
		N2=2^nextpow2(size(S,2));
		MeanS=mean(mean(S));
		if count==0
			SS=abs(fft2(S-MeanS,N1,N2)).^2 ;
		else
			SS=SS+abs(fft2(S-MeanS,N1,N2)).^2 ;
		end

		%Incrementing count variable
		count=count+1;

		%Displaying output if desired
		if strcmp(Disp,'y')
			if count>1
				subplot(211)
				pcolor(t,f,S)
				shading flat, colormap jet
				subplot(212)
				pcolor(fftshift(log10(SS)))
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
	f=['save ' filename(1:index-1) '_ContDf' int2str(df) 'Hz Time Amp PDist '];
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

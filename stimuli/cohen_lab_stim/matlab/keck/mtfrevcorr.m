%function [taxis,HMTF,PP]=mtfrevcorr(infile,T1,T2,dch,spet,SPL)
%
%       FILE NAME       : MTF REVCORR
%       DESCRIPTION     : Reverse Correlation Performed on the Hilbert
%			  Transform of a White Noise Modulated Carrier at 
%			  the Neuron CF - Gives the Neuron MTF
%
%	infile		: Input file name
%	T1, T2		: Evaluation delay interval for WSTRF(T,F)
%	dch		: Data Channel as given by DAT Recorder ( Stimulus )
%	spet		: Array of spike event times in sample number
%	SPL		: Signal RMS Sound Pressure Level
%
%	
function [taxis,HMTF,PP]=mtfrevcorr(infile,T1,T2,dch,spet,SPL)

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
M=1024*512;
for k=1:4
	%Reading a Data Chunk
	if feof(fid)!=1	%Checking for EOF
		X=fread(fid,M*nchannel,'int16');
	end
end
X=fread(fid,(N2-N1)*nchannel,'int16');
X=X(dch:nchannel:length(X));
XH=abs(hilbert(X));
RMSP=sqrt(mean(XH)/Fs);		%RMS Power

%Computing MTF REVCORR
clc
disp(['Evaluating MTF REVCORR: ' num2str(length(spet)) ' spikes'])
HMTF=[];
for k=1:N
	if (spet(k)-N2-1)*nchannel > 1
		%Extracting Input Signal
		%Normalization is only aproximate!!!
		fseek(fid,2*((spet(k)-N2-1)*nchannel),-1);
		X=P/RMSP*fread(fid,(N2-N1)*nchannel,'int16');
		X=fliplr( X(dch:nchannel:length(X))' );
		XH=abs(hilbert(X));

		%Initialize if necesary
		if isempty(HMTF)
			HMTF=zeros(1,length(XH));
		end

		%Second Order Receptive Field Averaging
		HMTF=HMTF + XH  / N;

	end

	%Percent Done
	clc
	disp(['Evaluating MTFT REVCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
end

%Computing MTF Signal Power (PSTFT)
clc
disp(['Evaluating MTF XCORR: ' num2str(length(spet)) ' spikes'])
frewind(fid);
count=1;
PMTF=zeros(1,length(HMTF));
for k=1:N
	X=P/RMSP*fread(fid,(N2-N1)*nchannel,'int16');
	if ~feof(fid)==1
		%Extracting Input Signal
		X=fliplr( X(dch:nchannel:length(X))' );
		XH=abs(hilbert(X));
	
		%Second Order Power Averaging
		PMTF=PMTF + XH ;
		count=count+1;
		
		%Percent Done
		clc
		disp(['Evaluating MTF XCORR: ' num2str(k) ' Spikes of ' num2str(N)]);
	end
end
PMTF=PMTF/count;	%Converts sum to a mean 

%Substracting Mean Power Level (PMTF) from HMTF
%And Normalizing According to Paper by Van Dijk
T=max(spet)/Fs;
No=N/T;
HMTF=No/fact(2)/PP^2 * (HMTF-PMTF);

%Time Axis
taxis=(1:length(HMTF))/Fs;

%Number of Spikes
clc
disp([num2str(N) ' Spikes Used']);

%Closing File
fclose(fid);


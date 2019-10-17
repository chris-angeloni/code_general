%
%function []=spkwaveform(spetfile,rawfile,dT,N,B)
%
%       FILE NAME       : SPK WAVE FORM
%       DESCRIPTION     : Finds N Spike Waveforms in a raw file 
%
%	spetfile	: SPET File
%	rawfile		: Raw File Name
%	dT		: Time to the Left and Right of Center (sec)
%			  Default = .002 sec
%	N		: Number of Waveforms to Save from each block 
%			  ( Default = 25 )
%	B		: Block Size ( Default = 10 )
%
function []=spkwaveform(spetfile,rawfile,dT,N,B)

%Preliminaries 
more off
if nargin<3
	dT=.002;
	N=25;
	B=10;
elseif nargin<4
	N=25;
	B=10;
elseif nargin<5
	B=10;
end

%Loading Spet File
f=['load ' spetfile];
eval(f);

%Finding Number of Models
i=0;
while exist(['spet' int2str(i)])
	i=i+1;
end
i=i/2;

for k=0:i-1

	%Finding Available Blocks
	index=findstr(rawfile,'.');
	Header=rawfile(1:index-2);
	f=(['List=dir(''' Header '*.raw'');']);
	eval(f)

	%Initializing Variables if Necessary
	if ~exist(['SpikeWave' int2str(k) ])
		f=['SpikeWave' int2str(k) '=[];'];
		eval(f)
	end

	%Extracting spikes from n-th block
	for n=1:length(List)
	
		%Renaming to Generic Variable
		f=['spet=spet' int2str(k) ';'];
		eval(f);
	
		%Opening Raw File
		fid=fopen(List(n).name);

		%Finding Spikes Inside the n-th Block
		index=find(spet<(n)*B*1024*1024 & spet>(n-1)*B*1024*1024);
		offset=(n-1)*B*1024*1024;
		spet=spet(index)-offset;

		%Choosing Randomly N Spikes
		if length(spet)<N
			spet=spet;
		else
			spet=spet( 1 + round( (length(spet)-1) * rand(1,N) ) );
		end

		%Finding L = Number of Samples to the left and Right of Center
		L=round(dT*Fs);

		%Extractin The Spikes
		ch=setstr(39);
		SpikeVar=['SpikeWave' int2str(k)];
		if ~isempty(spet)
			for l=1:length(spet)
				fseek(fid,(spet(l)-L)*2,-1);
				f=['SpikeWave' int2str(k) '=[ SpikeWave' int2str(k) ';fread(fid,2*L+1,' ch 'int16' ch ')''];'];
				eval(f);
			end
		end

		%Closing Files
		fclose(fid);
	end
end

%Saving File
index=find(spetfile=='.');
f=['save ' spetfile ' '];
for k=0:i-1
	f=[f ' SpikeWave' int2str(k)];
end
for k=0:2*i-1
	f=[f ' spet' int2str(k)];
end
if strcmp('4.2c',version)
	f=[f ' Fs'];
else
	f=[f ' Fs -v4'];
end
eval(f);


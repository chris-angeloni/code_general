%
%function []=filterbatch(SpikeChan,EegChan,Fs)
%
%       FILE NAME       : FILTER BATCH
%       DESCRIPTION     : Filters all downloaded files from a DAT tape.
%			  Every RAW file in the current directory is filtered
%			  with the desired EEG and/or Spike Filter
%
%	SpikeChan	: Array of desired chanel sequences to filter spikes
%                         eg., [1 2], [1], [2 5], etc.
%	EegChan		: Array of desired chanel sequences to filter EEG
%                         eg., [1 2], [1], [2 5], etc.
%	Fs		: Sampling Rate
%
function []=filterbatch(SpikeChan,EegChan,Fs)

%Generating List for Spike Files
if ~isempty(SpikeChan)
	f=['ls '];
	for k=1:length(SpikeChan)
		f=[f '*ch' int2str(SpikeChan(k)) '*.raw '];
	end
	[s,List]=unix(f);
	List=[setstr(10) List setstr(10)];
	returnindex=findstr(List,setstr(10));
	for l=1:length(returnindex)-1
		for k=1:30
			if k+returnindex(l)<returnindex(l+1)
				Lst(l,k)=List(returnindex(l)+k);
			else
				Lst(l,k)=setstr(32);
			end
		end
	end
	SpikeLst=Lst;
else
	SpikeLst=[];
end

%Generating List for Eeg Files
if ~isempty(EegChan)
	f=['ls '];
	for k=1:length(EegChan)
		f=[f '*ch' int2str(EegChan(k)) '*.raw '];
	end
	[s,List]=unix(f);
	List=[setstr(10) List setstr(10)];
	returnindex=findstr(List,setstr(10));
	for l=1:length(returnindex)-1
		for k=1:30
			if k+returnindex(l)<returnindex(l+1)
				Lst(l,k)=List(returnindex(l)+k);
			else
				Lst(l,k)=setstr(32);
			end
		end
	end
	EegLst=Lst;
else
	EegLst=[];
end

%Filtering Eeg Files
N=size(EegLst,1);
for k=1:N

	%Temporary File Name
	index=findstr(EegLst(k,:),'.raw');
	if ~isempty(index)
		xtractfile=EegLst(k,1:index+3);
	end

	%Filtering Blocked Data
	if exist(xtractfile)

		%Display 
		clc
		disp(['EEG Filtering: ' xtractfile ])

		%Lowpass Filtering Data - 0-150 Hz, TW=100 Hz
		if exist('/usr/local/bin/filtfilesw')
			f=['!filtfilesw ' xtractfile ' ' xtractfile '.tmp ' num2str(Fs) ' 0 150 100 40 262144 .8 '];
			eval(f);
		else
			filtfile(xtractfile,[xtractfile '.tmp'],0,150,100,40,Fs,1024*32,.8); 
		end

		%Decimating
		L=ceil(Fs/400);
		decimatefile([xtractfile '.tmp'],[xtractfile '.tmp2'],L);
		
		%Removing TMP File
		f=['!rm -f ' xtractfile '.tmp'];
		eval(f)	
			
		%Renaming TMP2 File as EEGFILE
		ii=findstr(xtractfile,'.raw');
		eegfile=[xtractfile(1:ii-1) '_eeg.raw'];
		f=['!mv ' xtractfile '.tmp2 ' eegfile];
		eval(f)
	end
	xtractfile='';

end

%Filtering Spike Files
N=size(SpikeLst,1);
for k=1:N

	%Temporary File Name
	index=findstr(SpikeLst(k,:),'.raw');
	if ~isempty(index)
		xtractfile=SpikeLst(k,1:index+3);
	end

	%Filtering Blocked Data
	if exist(xtractfile)
	
		%Display 
		clc
		disp(['Spike Filtering: ' xtractfile ])

		%Bandpass Filtering Data - 500Hz-10kHz, TW=300 Hz
		if exist('/usr/local/bin/filtfilesw')
			f=['!filtfilesw ' xtractfile ' ' xtractfile '.tmp ' num2str(Fs) ' 500 10000 300 60 262144 .8 '];
			eval(f);
		else
			filtfile(xtractfile,[xtractfile '.tmp'],500,10000,300,60,Fs,1024*32,.8);
		end
		f=['!mv -f ' xtractfile '.tmp ' xtractfile];
		eval(f);

	end
	xtractfile='';

end

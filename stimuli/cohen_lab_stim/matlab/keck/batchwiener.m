%
%function []=batchwiener(filename,dev,filenum,electch,dch,SPL,T1,T2,df,M,Throttle)
%
%       FILE NAME       : BATCH WIENER
%       DESCRIPTION     : Downloads the contents of a DAT tape and computes the
%			  spectro-temporal receptive fields for all files
%
%	filename	: Input file name
%	dev		: Tape Device 
%			  1: /dev/nrmt0h
%			  2: /dev/nrmt2h
%	filenum		: Array of filenumbers to download
%			  eg,. [0 5 8 9 10 18], etc.
%			  Note: Must be the same length as filenum
%	elctch		: Electrode channel (s). May be a multiple element array
%	dch		: Array with two elements for the acoustic stimulus 
%			  1st element=Contralateral channels as designated by the DAT Recorder 
%			  2nd element=Ipsilateral channels as designated by the DAT Recorder 
%
%	SPL		: Array of corresponding Sound Pressure Level values for all file
%			  eg,. [60 20 30 50 40 30], etc.
%	T1,T2           : Evaluation delay intervals for STRF
%       df              : Frequency resolution for spectogram.
%                         Note that temporal resolution satisfies dt~=4/df/4/pi
%
%OPTIONAL
%	M		: Buffer Length for download: Optional (128K Default)
%	Throttle	: Throttles the output 'y' or 'n', Default='n'
%
function []=batchwiener(filename,dev,filenum,electch,dch,SPL,T1,T2,df,M,Throttle)

%Checkin input arguments
if nargin<10
	M=1024*128;
	Throttle='n';
elseif nargin <11
	Throttle='n';
end
if dev==1
	dev='/dev/nrmt0h';
elseif dev==2
	dev='/dev/nrmt2h';
end

%Finding the local path to save file
path=pwd;
if isempty(findstr(path,'net'))
	path=['/net' path];
end

%Removing tmp_mnt
if ~isempty(findstr(path,'tmp_mnt'))
        index=findstr(path,'tmp_mnt');
        path=path(index+7:length(path));
end

%Rewinding and Advancing the Tape
clc
f=['!rsh keck "mt -f ' dev ' rewind"'];
disp(f)
eval(f);
f=['!rsh keck "cd ' path '; dd if=' dev ' of=dump files=1 ibs=65024 conv=sync"'];
disp(f)
eval(f);
!rm dump;
if filenum(1)>0
	f=['!rsh keck "cd ' path '; mt -f ' dev ' fsf ' num2str(filenum(1)) '"'];
	disp(f)
	eval(f)
end

%Downloading data from tape and Extracting desired channels
q=setstr(39);
for k=1:length(filenum)

	%Finding Filename
	if filenum(k)<10
		infile=[filename '_f0' num2str(filenum(k)) '.bin'];
	else
		infile=[filename '_f' num2str(filenum(k)) '.bin'];
	end

	%Throttleing dd if necessary
	if Throttle=='y'
		f=['!rsh keck "cd ' path '; throttle dd if=' dev  ' of=' infile ' files=1 ibs=65024 conv=sync"'];
	else
		f=['!rsh keck "cd ' path '; dd if=' dev  ' of=' infile ' files=1 ibs=65024 conv=sync"'];
	end
	disp(f);
	eval(f);

	%Calculating Wiener Kernels
	for l=1:length(electch)
		if filenum(k)<10
			spetfile=[filename '_f0' num2str(filenum(k)) '_ch' num2str(electch(l)) '.mat'];
		else
			spetfile=[filename '_f' num2str(filenum(k)) '_ch' num2str(electch(l)) '.mat'];
		end

		wienerbatch(spetfile,dch(1),dch(2),T1,T2,df,SPL(k),1,1);
	end

	%Removing File
	f=['!rm ' infile];
	disp(f);
	eval(f); 

	%Fast Forwarding tape if necesary
	if ~(k==length(filenum))
		if filenum(k+1)-filenum(k)>1
			f=['!rsh keck "cd ' path '; mt -f ' dev ' fsf ' num2str(filenum(k+1)-filenum(k)-1) '"'];
			disp(f);
			eval(f);
		end
	end
end

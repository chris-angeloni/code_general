%
%function []=printstrfbatch(Printer,Lag,Display,ModType,invert)
%
%       FILE NAME       : PRINT STRF BATCH
%       DESCRIPTION     : Print all STRF Files in working Directory
%	
%	Printer		: Printer name or 'None' for no print output
%	Lag		: Lag for PSTH
%	Display		: Desired Display Type
%			  1 : Display STRF Only 
%			  2 : Display SpikeAnal Only 
%			  3 : Display RTF
%			  3 : Display all
%	ModType		: Kernel Modulation type : 'dB' or 'lin'
%			  Default: 'dB'
%	invert		: Invert the Spike Waveform (Default=='n')
%
function []=printstrfbatch(Printer,Lag,Display,ModType,invert)

%Checking Input Arguments
if nargin < 3
	Display=1;
	ModType='both';
	invert='n';
elseif nargin < 4
	ModType='dB';
	invert='n';
elseif nargin<5
	invert='n';
end

%Preliminaries
more off

%Generating a File List
if strcmp(ModType,'both')
	[s,List]=unix('ls *_u*_dB.mat *_u*_Lin.mat');
elseif strcmp(ModType,'dB')
	[s,List]=unix('ls *_u*_dB.mat');
elseif strcmp(ModType,'lin')
	[s,List]=unix('ls *_u*_Lin.mat');
end
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

%Ploting Figures
N=size(Lst);
N=N(1);
clc
for k=1:N-1

	%Finding File
	strffile=Lst(k,:);
	index=findstr(Lst(k,:),'_u');
	spkanalfile=[Lst(k,1:index-1) '_SpkA.mat'];
	unit=str2num(Lst(k,index+2));

	%Ploting
	if Display==1 | Display==4
		figstrf=plotstrf(strffile,invert);
		disp(['Ploting: ' strffile])
	end

	if Display==2 | Display==4
		if exist(spkanalfile,'file')
			figspk=plotspikeanal(spkanalfile,unit,Lag);
			disp(['Ploting: ' spkanalfile])
		else
			disp(['File ' spkanalfile ' Does Not Exist !!!'])
			figspk=-9999;
		end
	end
	pause(0)

	if ~strcmp(Printer,'None')
		%Printing STRF 
		if Display==1 | Display==4 
			f=['figure(' int2str(figstrf) ')'];
			eval(f);
			print -dpsc /tmp/temp.ps
			f=['!lpr -P' Printer ' /tmp/temp.ps'];
			eval(f)
			!rm /tmp/temp.ps
			f=['close(' int2str(figstrf) ')'];
			eval(f)
		end
	
		%Printing Spk Anal
		if Display==2 | Display==4
			if figspk~=-9999
				f=['figure(' int2str(figspk) ')'];
        	        	eval(f);
				print -dpsc /tmp/temp.ps
        	        	f=['!lpr -P' Printer ' /tmp/strf.ps'];
               			eval(f)
       		        	!rm /tmp/temp.ps
				f=['close(' int2str(figspk) ')'];
				eval(f)
			end
		end

	else
		pause
		if Display==1 | Display==4
			f=['close(' int2str(figstrf) ')'];
			eval(f)
		elseif Display==2 | Display==4
			if figspk~=-9999
				f=['close(' int2str(figspk) ')'];
				eval(f)
			end
		elseif Display==3 | Display==4
			f=['close(' int2str(figrtf) ')'];
			eval(f)
		elseif Display ==4
			f=['close(' int2str(figstrf) ')'];
			eval(f)
			if figspk~=-9999
				f=['close(' int2str(figspk) ')'];
				eval(f)
			end
			f=['close(' int2str(figrtf) ')'];
			eval(f)
		end
	end

end



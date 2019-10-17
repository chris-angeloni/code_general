%
%function []=batchstrf2rtf(MaxFm,MaxRD,ModType,Disp)
%
%       FILE NAME       : BATCH STRF 2 RTF
%       DESCRIPTION     : Batch program for 'strf2rtffile'
%
%	MaxFm		: Maximum Modulation Rate for Experiment
%	MaxRD		: Maximum Ripple Density for Experiment
%	ModType		: Modulation Type used for STRF: 'dB or 'lin' 
%			  or 'SModType'
%			  Default: 'SModType'
%       Tresh           : Fraction of Maximum for second response peak
%                         Two Best RD and FM are choosen if the second
%                         maximum achieves the value Tresh*max(max(RTF))
%                         where Tresh E [0 1], Default = 0.5
%	Disp		: Displays : 'y' or 'n' , Default='n'
%
function []=batchstrf2rtf(MaxFm,MaxRD,ModType,Tresh,Disp)

%Preliminaries
more off

%Input Arguments
if nargin<3
	Disp='n';
	ModType='SModType';
elseif nargin<4
	Tresh=0.5;
elseif nargin<5
	Disp='n';
end

%Generating a File List
if findstr(ModType,'dB')
	f=['ls *dB.mat' ];
elseif findstr(ModType,'Lin')
	f=['ls *Lin.mat' ];
else
	f=['ls *Lin.mat *dB.mat'];
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


%Batching STRF2RTFFILE
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.mat');
	filename=[ Lst(k,1:index-1) '.mat'];
	if exist(filename)

		%Displaying Output 
		disp(['Converting ' filename])

		%Converting STRF to RTF
		strf2rtffile(filename,MaxFm,MaxRD,Tresh,Disp);

	end
end

%
%function []=spkoutlier(outfile)
%
%       FILE NAME       : SPK OUTLIER
%       DESCRIPTION     : Finding Outlier Ratios for all Spike
%			  Files in Directory
%
%	outfile		: Output File Name
%
function []=spkoutlier(outfile)

%Preliminaries
more off

%Finding files with 'ch1.mat' and 'ch2.mat' extension
[s,List]=unix('ls *ch1.mat *ch2.mat');
List=[setstr(10) List setstr(10)];
spkindex=findstr(List,'mat');
returnindex=findstr(List,setstr(10));

%Opening Output File Name
fid=fopen(outfile,'w');

%Finding all Outliers
for k=1:length(spkindex)

	%Loading Spike Files
	index=find(spkindex(k) > returnindex);
	startindex=returnindex(index(length(index)))+1;
	filename=List(startindex:spkindex(k)+2);
	f=['load ' filename];
	eval(f);

	%Finding Number of Spikes	
	count=0;
	while exist(['spet' int2str(count)])
 		count=count+1;	
	end
	N=count/2-1;

	%Finding Outlier Ratios
	for k=0:N

		%Finding Outlier Ratios
		f=['spet=spet' int2str(k) ';'];
		eval(f);
		f=['outlier=spet' int2str(k+N+1) ';'];
		eval(f);
		NS=length(spet);
		NO=length(outlier);
		f=[filename ' :Unit ' int2str(k) '-> Num Spikes: ',...
		int2str(NS) '   Num Outliers: '  int2str(NO) ' -> ',...
		num2str(NO/(NS+NO)*100,2) ' % '];

		%Writing to File
		fwrite(fid,f,'char')
		fwrite(fid,setstr(10),'char')
	end

	%Clearing All Spikes
	for k=0:2*N+1
		f=['clear spet' int2str(k)];
		eval(f); 
	end


end


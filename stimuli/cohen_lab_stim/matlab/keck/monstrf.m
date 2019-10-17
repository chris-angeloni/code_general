%
%function []=monstrf(infile,dch,T1,T2,df,SPL,UT,UF)
%
%       FILE NAME       : MON STRF
%       DESCRIPTION     : Calculates Monaural STRF for a 'spet' file 
%
%       infile          : Input 'spet' File
%       dch            : Contra-Lateral Data channel to calculate kerneles
%	T1,T2		: Evaluation delay intervals for STRF
%	df		: Frequency resolution for spectogram.
%			  Note that temporal resolution satisfies dt~=4/df/4/pi
%	SPL		: Input Sound Preasure Level
%	UT		: Temporal Upsampling Factor
%	UF		: Frequency Upsampling Factor
%
function []=monstrf(infile,dch,T1,T2,df,SPL,UT,UF)

%Loading SPET file
f=['load ' infile ';'];
eval(f);
index=find(infile=='_');
index2=find(infile=='.');
datafile=[infile(1:index(2)-1) '.bin']

%Finding Spike Event Variables and Discarding Outliers
k=0;
q=setstr(39);
f=['exist(' q 'spet' num2str(k) q ')'];
while eval(f)
	k=k+1;
	f=['exist(' q 'spet' num2str(k) q ')'];
end
if k>=1
	N=ceil(k/2-1);	%Number of Spike Event Variables
else
	N=0;
end

%Calculating Kernels on spikesorted sequences
for i=0:N
	
	%Spike Event Times
	variable=['spet' num2str(i)];
	f=['spet=' variable ';'];	
	eval(f);

	%Evaluating All Kernels
	if ~isempty(spet)
		%Calculating Kernels
		[W0]=wo(spet,20);

		%Second Order Time Frequency Receptive Fiels
		[taxis,faxis,WSTRF2,PP]=wstrf(datafile,T1,T2,df,dch,spet,SPL,UT,UF,'gauss',60);

		%Saving Files
		if strcmp(version,'4.2c')
			f=['save ' infile(1:index2-1) '_u' num2str(i) ' taxis faxis WSTRF2 W0 PP ;'];
		else
			f=['save ' infile(1:index2-1) '_u' num2str(i) ' taxis faxis WSTRF2 W0 PP -v4;'];
		end
		eval(f);
		clear WSTRF2 W0 PP taxis faxis;
	else
		%Saving if no data exists
		NoData=1;
		if strcmp(version,'4.2c')
			f=['save ' infile(1:index2-1) '_dch' num2str(dch) '_u' num2str(i) ' NoData ;'];
		else
			f=['save ' infile(1:index2-1) '_dch' num2str(dch) '_u' num2str(i) ' NoData -v4;'];

		end
		eval(f);
	end

end

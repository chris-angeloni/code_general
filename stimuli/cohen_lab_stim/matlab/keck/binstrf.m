%
%function []=binstrf(infile,dchC,dchI,T1,T2,df,SPL,UT,UF)
%
%       FILE NAME       : BIN STRF
%       DESCRIPTION     : Calculates Binaural STRF for a 'spet' file 
%
%       infile          : Input 'spet' File
%       dchC            : Contra-Lateral Data channel to calculate kerneles
%       dchI            : Ipsi-Lateral Data channel to calculate kerneles
%	T1,T2		: Evaluation delay intervals for STRF
%	df		: Frequency resolution for spectogram.
%			  Note that temporal resolution satisfies dt~=4/df/4/pi
%	SPL		: Input Sound Preasure Level
%	UT		: Temporal Upsampling Factor
%	UF		: Frequency Upsampling Factor
%
function []=binstrf(infile,dchC,dchI,T1,T2,df,SPL,UT,UF)

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

		%Second Order Contra and Ipsi Receptive Fiels
		[taxis,faxis,WSTRFC2,PPC]=wstrf(datafile,T1,T2,df,dchC,spet,SPL,UT,UF,'gauss',60);
		[taxis,faxis,WSTRFI2,PPI]=wstrf(datafile,T1,T2,df,dchI,spet,SPL,UT,UF,'gauss',60);
	
		%Binaural Cross Kernel
%		[taxis,faxis,XBSTRF]=xbstrf(datafile,Fs,T1,T2,df,nchannel,dchC,dchI,spet,SPL,UT,UF,'gauss',60);

		%Saving Files
%		f=['save ' infile(1:index2-1) '_u' num2str(i) ' taxis faxis WSTRFC2 WSTRFI2 XBSTRF W0 PPC PPI -v4;'];
		if strcmp(version,'4.2c')
			f=['save ' infile(1:index2-1) '_u' num2str(i) ' taxis faxis WSTRFC2 WSTRFI2 W0 PPC PPI ;'];
		else
			f=['save ' infile(1:index2-1) '_u' num2str(i) ' taxis faxis WSTRFC2 WSTRFI2 W0 PPC PPI -v4;'];
		end	
		eval(f);
		clear WSTRFC WSTRFI XBSTRF W0 PPC PPI taxis faxis;
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

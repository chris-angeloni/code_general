%
%function [Time,Amp,PDist]=spgampdist(filename,f1,f2,ND,Save,Disp)
%
%	FILE NAME 	: SPG AMP DIST
%	DESCRIPTION 	: Computes the Time Dependent Spectro-Temporal 
%			  Amplitude Distribution of a Sound from 
%			  the SPG "spectrogram" file
%
%	filename	: Input SPG File Name
%	f1		: Lower Frequency for Analysis
%	f2		: Upper Frequency for Analysis
%	ND		: Polynomial Order: Detrends the local spectrum
%			  by fiting a polynomial of order ND. The fitted 
%			  trend is then removed. If ND==0 then no detrending
%			  is performed. Default==0 (No detrending)
%	Disp		: Display output window: 'y' or 'n' ( Default = 'n')
%	Save		: Save to File         : 'y' or 'n' ( Default = 'n')
%
%RETUERNED VARIABLES
%	Time		: Time Axis
%	Amp		: Amplitude Axis ( decibels )
%	PDist		: Time Dependent Probability Distribution of Amp
%
function [Time,Amp,PDist]=spgampdist(filename,f1,f2,ND,Save,Disp)

%Input Arguments
if nargin<4
	ND=0;
end
if nargin<5
	Save='n';
end
if nargin<6
	Disp='n';
end

%Loading Param File
index=findstr(filename,'.');
paramfile=[filename(1:index-1) '_param.mat'];
f=['load ' paramfile];
eval(f);

%Opening Input File
fid=fopen(filename);

%Opening Temporary File
if exist('temp.out')
	!rm temp.out
end
fidt=fopen('temp.out','w');

%Reading First Input Data Block
S=fread(fid,NF*NT,'float');

%Reading Data and Computing Amplitude Distreibution
PP=[];
count=0;
while ~feof(fid) & length(S)==NT*NF

	%Concatenating 100 blocks at a time 
	count2=0;
	PP=[];
	while count2<100 & ~feof(fid) & length(S)==NT*NF

		%Display Output
		clc
		disp(['Finding Amp Dist for Block: ' num2str(count)])

		%Finding index for f1 and f2
		dff=faxis(2)-faxis(1);
		indexf1=max(1,ceil(f1/dff));
		indexf2=min(floor(f2/dff),length(faxis));

		%Reshape and Selecting Spectrogram between f1-f2
		S=reshape(S,NF,NT);
		S=S(indexf1:indexf2,:);
		f=faxis(indexf1:indexf2);

		%Detrending Local Spectrum If Desired
		if ND>0
			[p,s]=polyfit(f,mean(S'),ND); 
			[Sfit]=polyval(p,f,s)';
			MeanS=mean(mean(S'));
			for l=1:size(S,2)
				S(:,l)=S(:,l)-Sfit+MeanS;	
			end
		end

		%Computing Time Varying Distribution
		S=reshape(S,1,size(S,1)*size(S,2));
		[P,Amp]=hist(S,[-100:1:100]);
		PP=[PP P'/length(S)];
		Amp=Amp';

		%Incrementing count variable
		count=count+1;
		count2=count2+1;
	
		%Reading Input Data Array
		S=fread(fid,NF*NT,'float');

		%Displaying output if desired
		if strcmp(Disp,'y')
			if count>1
				pcolor((1:size(PDist,2)),Amp,PDist)
				caxis([0 max(max(PDist))])
				shading flat,colormap jet
				pause(0)
			end		
		end

	end

	%Saving 100 Block Segments
	fwrite(fidt,reshape(PP,1,size(PP,1)*size(PP,2)),'float');

end

%Reloading PP and Concatenating to PDist
fclose(fidt);
fidt=fopen('temp.out');
PDist=[];
PP=fread(fid,100*length(Amp),'float');
PP=reshape(PP,length(Amp),length(PP)/length(Amp));
while ~feof(fidt)
	PDist=[PDist PP];
	PP=fread(fidt,100*length(Amp),'float');
	PP=reshape(PP,length(Amp),length(PP)/length(Amp));
end
if size(PP,2)>1
	PDist=[PDist PP];
end

%Removing Mean Value - so that PDist is zero mean
Amp=Amp-mean(PDist'*Amp);

%Generating Time Axis
Time=(0:size(PDist,2)-1)*NT*(taxis(2)-taxis(1));

%Finding Mean, Std, and Kurtosis Trajectories
[Time,StddB,MeandB,KurtdB]=ampstdmean(Time,Amp,PDist);

%Saving Data if Desired
if strcmp(Save,'y') & ND==0

	index=findstr(filename,'.');
	f=['save ' filename(1:index-1) '_Cont Time Amp PDist StddB MeandB KurtdB MF NF NT N ATT TW df method'];
	if findstr(version,'5.')
		f=[f ' -v4'];
	end
	eval(f);
elseif strcmp(Save,'y') & ND>0

	index=findstr(filename,'.');
	f=['save ' filename(1:index-1) '_ContND' int2str(ND) ' Time Amp PDist StddB MeandB KurtdB MF NF NT N ATT TW df method'];
	if findstr(version,'5.')
		f=[f ' -v4'];
	end
	eval(f);
end

%Closing all Files
fclose('all');

%Deleting Temporary File
!rm temp.out

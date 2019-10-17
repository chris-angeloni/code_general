%
%function []=classbatch(Header,BatchFile)
%
%
%	FILE NAME       : CLASS BATCH
%	DESCRIPTION     : Uses a batch file to spike sort across recordings
%			  using the desired models as designated by the batch
%			  file - Batch File Will Generally Have the Name
%			  "SpikeSortDetails.txt"
%
%	Header		: Experiment Name, e.g. IC97QJE3
%	BatchFile	: Spike Sort Batch File - "SpikeSortDetails.txt" 
%
%
%Example Batch File - * and ** designate STATE Files to use for classification
%
%SpikeFiles              CH1                             CH2
%----------------------------------------------------------------
%IC97QJE3t1_f00          BAD                             BAD
%IC97QJE3t1_f01          B2  - OK                        *B1  - OK
%IC97QJE3t1_f02          *B10 - OK                       B10 - OK
%IC97QJE3t1_f03          B1  - OK                        B1  - OK
%IC97QJE3t1_f04          **B1  - OK                      B1  - OK
%IC97QJE3t1_f05          B1  - OK                        **B1  - OK
%IC97QJE3t1_f06          B5  - OK                        B1  - OK
%----------------------------------------------------------------
%
function []=classbatch(Header,BatchFile)

%Preliminaries
more off
SortCh1=[];
SortCh2=[];
%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
count=1;
for k=1:length(returnindex)-1
	CurrentList=setstr(List(returnindex(k)+1:returnindex(k+1)-1));
	if length(findstr(CurrentList,'----'))>1
		Separator(count)=k;
		count=count+1;
	end
end

%Making Directories
!mkdir Cross1
!mkdir Cross2
!mkdir Cross3

%Finding Sta Files for Each Corresponding Channel
for k=1:length(Separator)-1

	%Finding Sta Files
	for l=Separator(k)+1:Separator(k+1)-1;

		%Retreaving List
		CurrentList=setstr(List(returnindex(l)+1:returnindex(l+1)-1));

		%Finding STA Model Files for Ch1 and Ch2
		if min(findstr(CurrentList,'*'))<35 %% Changed by B. Liu 07/30/03 (It was 25 before)
			SortCh1=[SortCh1 l];
 		end
		if max(findstr(CurrentList,'*'))>35 %% Changed by B. Liu 07/30/03 (It was 25 before)
			SortCh2=[SortCh2 l];
 		end
	end
end
%Classifying Raw Files
%%fidbatch=fopen([Header 'ClassBatCross.bat'],'w'); By B. Liu
for j=1:length(Separator)-1

	%Finding STA Files for Ch1 and Ch2 for the first BLOCK
	index1=find(SortCh1>Separator(j) & SortCh1<Separator(j+1))
	index2=find(SortCh2>Separator(j) & SortCh2<Separator(j+1))

	%Spike Sorting Channel 1
	for k=1:length(index1)
		for l=Separator(j)+1:Separator(j+1)-1;

			%Retreaving List Number
			L=length(Header)+5;
			CurrentFile=[setstr(List(returnindex(l)+1:returnindex(l)+1+L)) '_ch1_b1.raw'];

			%Running ClassBatCross
			if exist(CurrentFile)

				%Finding FileNumber and TapeNumber
				index=findstr('_f',CurrentFile);
				FileNum=str2num(CurrentFile(index+2:index+3));
				index=findstr('t',CurrentFile);
				TapeNum=str2num(CurrentFile(index(1)+1));

				%Finding State File
				i=SortCh1(index1(k));
				StateFile=setstr(List(returnindex(i)+1:returnindex(i)+1+L));
				[s,StateFile]=unix(['ls ' StateFile '_ch1_b*.sta']);
				index=findstr(StateFile,'.sta');
				StateFile=[StateFile(1:index) 'sta']

				%Running ClassBatCross
				f=['classbatcross(' int2str(TapeNum) ',' int2str(FileNum) ',1,''' StateFile ''');']
				eval(f);
				fidbatch=fopen([Header 'ClassBatCross.bat'],'a')
				fwrite(fidbatch,[f setstr(10)],'uchar');
			end
		end
		fidbatch=fopen([Header 'ClassBatCross.bat'],'a');
		fwrite(fidbatch,[setstr(10)],'uchar');

		%Moving Spk and Mdl Files to corresponding Directory
		if k==1
			!mv *spk Cross1
			!mv *mdl Cross1
		elseif k==2
			!mv *spk Cross2
			!mv *mdl Cross2
		else
			!mv *spk Cross3
			!mv *mdl Cross3
		end

	end	

	%Spike Sorting Channel 2
	for k=1:length(index2)
		for l=Separator(j)+1:Separator(j+1)-1;
			%Retreaving List Number
			L=length(Header)+5;
			CurrentFile=[setstr(List(returnindex(l)+1:returnindex(l)+1+L)) '_ch2_b1.raw'];
		
			%Running ClassBatCross
			if exist(CurrentFile)
			
				%Finding FileNumber and TapeNumber
				index=findstr('_f',CurrentFile);
				FileNum=str2num(CurrentFile(index+2:index+3));
				index=findstr('t',CurrentFile);
				TapeNum=str2num(CurrentFile(index(1)+1));

				%Finding State File
				i=SortCh2(index2(k));
				StateFile=setstr(List(returnindex(i)+1:returnindex(i)+1+L));
				[s,StateFile]=unix(['ls ' StateFile '_ch2_b*.sta']);
				index=findstr(StateFile,'.sta');
				StateFile=[StateFile(1:index) 'sta'];

				%Running ClassBatCross
				f=['classbatcross(' int2str(TapeNum) ',' int2str(FileNum) ',2,''' StateFile ''');'];
				eval(f);
				fidbatch=fopen([Header 'ClassBatCross.bat'],'a');
				fwrite(fidbatch,[f setstr(10)],'uchar');
			end
		end	
		fidbatch=fopen([Header 'ClassBatCross.bat'],'a');
		fwrite(fidbatch,[setstr(10)],'uchar');

		%Moving Spk and Mdl Files to corresponding Directory
		if k==1
			!mv *spk Cross1
			!mv *mdl Cross1
		elseif k==2
			!mv *spk Cross2
			!mv *mdl Cross2
		else
			!mv *spk Cross3
			!mv *mdl Cross3
		end
	end	

end

%Closing All Opened Files
fclose('all');

%Removing Batch File
!rm /tmp/temp.bat

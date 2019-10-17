%
%function []=batchstrfintsprboot(MRFile,RNFile,BatchFile,T1,T2,UFMR,UFRN,ModType,NBoot)
%
%       FILE NAME       : BATCH STRF INT SPR
%       DESCRIPTION     : Batch Mode RTWSTRFDBINT and RTWSTRFLININT
%			  Computes STRF on all Files using the Stimulus 
%			  SPR File - Interpolated by a factor
%			  Work with sequential presentations - "Shift Predictor"
%       MRFile		: Moving Ripple Spectral Profile File
%       RNFile		: Ripple Noise Spectral Profile File
%	BatchFile	: Contains Experiment Data for all Sound
%			  Presentations
%       T1, T2          : Evaluation delay interval for WSTRF(T,F)
%                         T E [- T1 , T2 ] : Note that T1 and T2 > 0
%	UFMR		: Ripple Noise upsampling factor ( Default==1 )
%	UFRN		: Moving Ripple upsampling factor ( Default==1 )
%       ModType         : Kernel modulation type : 'lin' , 'dB' , or 'SModType'
%			  Default: 'SModType', Uses same dimmension for kernel
%			  computation as sound.
%	NBoot		: Number of bootstrap STRF (Default == 8)
%
%	Batch File should be tab delimited and arranged colum-wise 
%	with the Following information
%
%	tapenum	filenum	SPL	MdB	Sound	SModType  Experiment
%-----------------------------------------------------------------
%Eg.	3	23	60	30	RN	dB	    RF
%	4	12	50	30	MR	lin	    RF
%	2	23	40	40	MR		    PRE
%	5	12	55		RN		    ALL
%	4	15	50				    TC
%	4	17					    BAD
%
function []=batchstrfintsprboot(MRFile,RNFile,BatchFile,T1,T2,UFMR,UFRN,ModType,NBoot)

%Input Arguments
if nargin<6
	UFMR=1;
end
if nargin<7
	UFRN=1;
end
if nargin<8
	ModType='SModType';
end
if nargin<9
	NBoot=8;
end

%Preliminaries
more off

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
for l=1:length(returnindex)-1

	%Extracting File Data from Batch File
	CurrentList=List(returnindex(l)+1:returnindex(l+1)-1);
	tabindex=find(CurrentList==9);
	Param=setstr(ones(7,5)*32);
	if length(tabindex)==6
		for k=1:7
			if k==1
				n=1:tabindex(k)-1;
				Param(k,n)=CurrentList(n);
			elseif k==7
				n=tabindex(k-1):length(CurrentList);
				Param(k,1:length(n))=CurrentList(n);
			else
				n=tabindex(k-1)+1:tabindex(k)-1;
				Param(k,1:length(n))=CurrentList(n);
			end
		end
	end

	%Checking for Kernel Modulation Type
	if findstr(ModType,'SModType')
		if findstr('dB',Param(6,:))
			Mod='dB';	
		else
			Mod='lin';
		end
	else
		Mod=ModType;
	end

	%Running BATCHRTWSTRFINT and BATCHRTWSTRFINT2
	if length(tabindex)==6 & ~isempty(findstr('RF2',Param(7,:)))
		if findstr(Param(5,:),'MR') & findstr(Param(6,:),'dB')
			f=['batchrtwstrfint2boot(' ch MRFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'MR' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'dB' ch   ',' int2str(NBoot) ')'];
		elseif findstr(Param(5,:),'MR') & findstr(Param(6,:),'lin')
			f=['batchrtwstrfint2boot(' ch MRFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'MR' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'lin' ch   ',' int2str(NBoot) ')'];
		elseif findstr(Param(5,:),'RN') & findstr(Param(6,:),'dB')
			f=['batchrtwstrfint2boot(' ch RNFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'RN' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'dB' ch   ',' int2str(NBoot) ')'];
		elseif findstr(Param(5,:),'RN') & findstr(Param(6,:),'lin')
			f=['batchrtwstrfint2boot(' ch RNFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'RN' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'lin' ch   ',' int2str(NBoot) ')'];
		end

		disp(f)
		eval(f);

	elseif length(tabindex)==6 & ~isempty(findstr('RF',Param(7,:)))
		if findstr(Param(5,:),'MR') & findstr(Param(6,:),'dB')
			f=['batchrtwstrfintboot(' ch MRFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'MR' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'dB' ch   ',' int2str(NBoot) ')'];
		elseif findstr(Param(5,:),'MR') & findstr(Param(6,:),'lin')
			f=['batchrtwstrfintboot(' ch MRFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'MR' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'lin' ch   ',' int2str(NBoot) ')'];
		elseif findstr(Param(5,:),'RN') & findstr(Param(6,:),'dB')
			f=['batchrtwstrfintboot(' ch RNFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'RN' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'dB' ch   ',' int2str(NBoot) ')'];
		elseif findstr(Param(5,:),'RN') & findstr(Param(6,:),'lin')
			f=['batchrtwstrfintboot(' ch RNFile ch ',' num2str(T1) ',' num2str(T2) ',' Param(1,:) ',' Param(2,:) ',' Param(3,:) ',' Param(4,:) ',' ch 'RN' ch ',' ch Mod ch ',UFMR,UFRN,' ch 'lin' ch   ',' int2str(NBoot) ')'];
		end

		disp(f)
		eval(f);
	end

end

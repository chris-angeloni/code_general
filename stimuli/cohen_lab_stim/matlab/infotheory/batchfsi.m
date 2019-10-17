%
%function [fsiMR1,fsiMR2,fsiRN1,fsiRN2]=batchfsi(BatchFile,Header)
%
%	FILE NAME       : BATCH FSI
%	DESCRIPTION     : Uses a batch file to compute the Feature 
%			  Selectivity Index (FSI) directly from the
%			  dBvar or LinVar File
%
%	BatchFile	: Batch file containing corresponding STRFs for 
%			  moving ripple and ripple noise
%	Header		: Experiment Header 
%
%RETURNED VARIABLES
%
%	fsiMR1		: Feature Selectivity Index Matrix for MR STRF Ch1
%	fsiRN1		: Feature Selectivity Index Matrix for RN STRF Ch1
%	fsiMR2		: Feature Selectivity Index Matrix for MR STRF Ch2
%	fsiRN2		: Feature Selectivity Index Matrix for RN STRF Ch2
%
%	FORMAT: For all returned variables 10+p designates no STRF was
%		available. All matrices have 3 columns:
%
%		Column 1 : FSI for STRF
%		Column 2 : FSI for Excitatory STRF
%		Column 3 : FSI for Inhibitory STRF
%
%Example Batch File
%
%MRFILE          SPIKES  RNFILE          SPIKES  SOUNDCH SPIKE   TYPE
%-----------------------------------------------------------------------
%
%t2_f36_ch2      0       t2_f39_ch2      ---     2       LARGE   F
%t2_f36_ch2      1       t2_f39_ch2      0       2       MED     L
%t3_f07_ch1      0       t3_f11_ch1      ---     1       LARGE   F
%t3_f17_ch1      0+2     t3_f18_ch1      0       1       LARGE   F
%t3_f17_ch1      1       t3_f18_ch1      0+1     1       LARGE   F
%
function [fsiMR1,fsiMR2,fsiRN1,fsiRN2]=batchfsi(BatchFile,Header)

%Preliminaries
more off

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
DataList=zeros(length(returnindex)-1,100);
for k=1:length(returnindex)-1

	CurrentList=setstr(List(returnindex(k)+1:returnindex(k+1)-1));
	DataList(k,1:length(CurrentList))=CurrentList;

end
DataList=setstr(DataList);

%Finding Corresponding Files and Computing Correlation Coefficients
Tab=setstr(9);
count=1;
LL=30;
MRList=setstr(32*ones(length(returnindex)-1,5*LL));
RNList=setstr(32*ones(length(returnindex)-1,5*LL));
for k=1:length(returnindex)-1

	if DataList(k,1)=='t';

		%Finding Tape Number, File Number, Unit Numbers, Sound Channel
		tabindex=findstr(DataList(k,:),Tab);
		TapeMR=DataList(k,1:tabindex(1)-1);
		TapeRN=DataList(k,tabindex(2)+1:tabindex(3)-1);
		UnitsMR=DataList(k,tabindex(1)+1:tabindex(2)-1);
		UnitsRN=DataList(k,tabindex(3)+1:tabindex(4)-1);
		Channel=DataList(k,tabindex(4)+1:tabindex(5)-1);

		%Finding STRFs for UnitMR
		for l=1:length(UnitsMR)

			if ~strcmp(UnitsMR(l),'+') & ~strcmp(UnitsMR(l),'-')

				%Possible Var Files - Lin or dB
				fileMRLin=[Header TapeMR '_u' UnitsMR(l) '_LinVar.mat'];
				fileMRdB=[Header TapeMR '_u' UnitsMR(l) '_dBVar.mat'];

				%Checking to see if sound is Lin or dB
				if exist(fileMRLin)

					%Loading File for Lin Sound
					f=['load ' fileMRLin];
					eval(f);
					disp(f);

					%Adding to MR List
					MRList(count,(l-1)*LL+(1:length(fileMRLin)))=fileMRLin;

					%Finding FSI
					fsiMR1(count,1)=fsi(p1,p1r);
					fsiMR2(count,1)=fsi(p2,p2r);
					fsiMR1(count,2)=fsi(p1e,p1er);
					fsiMR2(count,2)=fsi(p2e,p2er);
					fsiMR1(count,3)=fsi(p1i,p1ir);
					fsiMR2(count,3)=fsi(p2i,p2ir);

				elseif exist(fileMRdB)

					%Loading File for dB Sound
					f=['load ' fileMRdB];
					eval(f);
					disp(f)

					%Adding to MR List
					MRList(count,(l-1)*LL+(1:length(fileMRdB)))=fileMRdB;

					%Finding FSI
					fsiMR1(count,1)=fsi(p1,p1r);
					fsiMR2(count,1)=fsi(p2,p2r);
					fsiMR1(count,2)=fsi(p1e,p1er);
					fsiMR2(count,2)=fsi(p2e,p2er);
					fsiMR1(count,3)=fsi(p1i,p1ir);
					fsiMR2(count,3)=fsi(p2i,p2ir);

				end

			elseif strcmp(UnitsMR(l),'-')

				%Adding to MR List
				MRList(count,1:3)='---';

				%Finding FSI
				fsiMR1(count,1:3)=[0 0 0];
				fsiMR2(count,1:3)=[0 0 0];
			end
		end

		%Finding STRFs for UnitRN
		for l=1:length(UnitsRN)

			if ~strcmp(UnitsRN(l),'+') & ~strcmp(UnitsRN(l),'-')

				%Possible STRF Files - Lin or dB
				fileRNLin=[Header TapeRN '_u' UnitsRN(l) '_LinVar.mat'];
				fileRNdB=[Header TapeRN '_u' UnitsRN(l) '_dBVar.mat'];

				%Checking to see if sound is Lin or dB
				if exist(fileRNLin)

					%Loading File for Lin Sound
					f=['load ' fileRNLin];
					eval(f);
					disp(f);
					disp(setstr(10));

					%Adding to RN List
					RNList(count,(l-1)*LL+(1:length(fileRNLin)))=fileRNLin;
	
					%Finding FSI
					fsiRN1(count,1)=fsi(p1,p1r);
					fsiRN2(count,1)=fsi(p2,p2r);
					fsiRN1(count,2)=fsi(p1e,p1er);
					fsiRN2(count,2)=fsi(p2e,p2er);
					fsiRN1(count,3)=fsi(p1i,p1ir);
					fsiRN2(count,3)=fsi(p2i,p2ir);

				elseif exist(fileRNdB)

					%Loading File for Lin Sound
					f=['load ' fileRNdB];
					eval(f);
					disp(f);
					disp(setstr(10));

					%Adding to RN List
					RNList(count,(l-1)*LL+(1:length(fileRNdB)))=fileRNdB;

					%Finding FSI
					fsiRN1(count,1)=fsi(p1,p1r);
					fsiRN2(count,1)=fsi(p2,p2r);
					fsiRN1(count,2)=fsi(p1e,p1er);
					fsiRN2(count,2)=fsi(p2e,p2er);
					fsiRN1(count,3)=fsi(p1i,p1ir);
					fsiRN2(count,3)=fsi(p2i,p2ir);

				end

			elseif strcmp(UnitsRN(l),'-')

				%Adding to RN List
				RNList(count,1:3)='---';
			
				%Finding FSI
				fsiRN1(count,1:3)=[0 0 0];
				fsiRN2(count,1:3)=[0 0 0];
			end
		end

		if length(Channel)>1
			
		elseif str2num(Channel)==1
			fsiRN2(count,:)=10+fsiRN2(count,:);
			fsiMR2(count,:)=10+fsiMR2(count,:);
		elseif str2num(Channel)==2
			fsiRN1(count,:)=10+fsiRN1(count,:);
			fsiMR1(count,:)=10+fsiMR1(count,:);
		end                

		%Incrementing Counter
		count=count+1;

	end
end

%Truncating the MRList and RNList
RNList=RNList(1:count-1,:);
MRList=MRList(1:count-1,:);


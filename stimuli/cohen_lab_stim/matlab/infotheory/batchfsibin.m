%
%function [fsiMR,fsiRN,WoMR,WoRN,stdMR,stdRN,ppMR,ppRN,MRList,RNList]=batchfsibin(BatchFile,Header)
%
%	FILE NAME       : BATCH FSI BIN
%	DESCRIPTION     : Uses a batch file to compute the Binaural
%			  Feature Selectivity Index (FSI) directly
%			  from the dBvar or LinVar File
%
%	BatchFile	: Batch file containing corresponding STRFs for 
%			  moving ripple and ripple noise
%	Header		: Experiment Header 
%
%RETURNED VARIABLES
%
%	fsiMR		: Feature Selectivity Index Matrix for MR
%	fsiRN		: Feature Selectivity Index Matrix for RN
%
%	FORMAT: For all returned variables 10+p designates no STRF was
%		available. All matrices have 3 columns:
%
%		Column 1 : FSI for STRF
%		Column 2 : FSI for Excitatory STRF
%		Column 3 : FSI for Inhibitory STRF
%		Column 4 : FSI for STRF assuming Independent Contra and Ipsi
%
%	WoMR		: Firing Rate Matrix for MR
%	WoRN		: Firing Rate Matrix for RN
%	stdMR		: STRF Energy Matrix for MR
%	stdRN		: STRF Energy Matrix for RN
%	ppMR		: MR Peak-to-Peak STRF Magnitude (spikes/sec)
%	ppRN		: RN Peak-to-Peak STRF Magnitude (spikes/sec)
%	MRList		: Filename List for Moving Ripple
%	RNList		: Filename List for Ripple Noise
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
function [fsiMR,fsiRN,WoMR,WoRN,stdMR,stdRN,ppMR,ppRN,MRList,RNList]=batchfsibin(BatchFile,Header)

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
					fsiMR(count,1)=fsibin(p1,p2,p1r,p2r,spindex1,spindex2);
					fsiMR(count,2)=fsibin(p1e,p2e,p1er,p2er,spindex1,spindex2);
					fsiMR(count,3)=fsibin(p1i,p2i,p1ir,p2ir,spindex1,spindex2);
					fsiMR(count,4)=fsibinind(p1,p2,p1r,p2r);

					%Loading STRF File and Extracting Firing
					%Rate and STRF STD
					i=findstr(fileMRLin,'.mat');
					f=['load ' fileMRLin(1:i-4)];
					eval(f)
					WoMR(count)=Wo1;
					stdMR(count)=strfstd(STRF1s,STRF2s,PP,1/(taxis(2)-taxis(1)));
					ppMR(count)=( max(max([STRF1s STRF2s]))-min(min([STRF1s STRF2s])) )*sqrt(PP);

				elseif exist(fileMRdB)

					%Loading File for dB Sound
					f=['load ' fileMRdB];
					eval(f);
					disp(f)

					%Adding to MR List
					MRList(count,(l-1)*LL+(1:length(fileMRdB)))=fileMRdB;

					%Finding FSI
					fsiMR(count,1)=fsibin(p1,p2,p1r,p2r,spindex1,spindex2);
					fsiMR(count,2)=fsibin(p1e,p2e,p1er,p2er,spindex1,spindex2);
					fsiMR(count,3)=fsibin(p1i,p2i,p1ir,p2ir,spindex1,spindex2);
					fsiMR(count,4)=fsibinind(p1,p2,p1r,p2r);

					%Loading STRF File and Extracting Firing
					%Rate and STRF STD
					i=findstr(fileMRdB,'.mat');
					f=['load ' fileMRdB(1:i-4)];
					eval(f)
					WoMR(count)=Wo1;
					stdMR(count)=strfstd(STRF1s,STRF2s,PP,1/(taxis(2)-taxis(1)));
					ppMR(count)=( max(max([STRF1s STRF2s]))-min(min([STRF1s STRF2s])) )*sqrt(PP);
				end

			elseif strcmp(UnitsMR(l),'-')

				%Adding to MR List
				MRList(count,1:3)='---';

				%Finding FSI
				fsiMR(count,1:4)=[0 0 0 0];
				fsiMR(count,1:4)=[0 0 0 0];
				WoMR(count)=-9999;
				stdMR(count)=-9999;
				ppMR(count)=-9999;
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
					fsiRN(count,1)=fsibin(p1,p2,p1r,p2r,spindex1,spindex2);
					fsiRN(count,2)=fsibin(p1e,p2e,p1er,p2er,spindex1,spindex2);
					fsiRN(count,3)=fsibin(p1i,p2i,p1ir,p2ir,spindex1,spindex2);
					fsiRN(count,4)=fsibinind(p1,p2,p1r,p2r);

					%Loading STRF File and Extracting Firing
					%Rate and STRF STD
					i=findstr(fileRNLin,'.mat');
					f=['load ' fileRNLin(1:i-4)];
					eval(f)
					WoRN(count)=Wo1;
					stdRN(count)=strfstd(STRF1s,STRF2s,PP,1/(taxis(2)-taxis(1)));
					ppRN(count)=( max(max([STRF1s STRF2s]))-min(min([STRF1s STRF2s])) )*sqrt(PP);
				elseif exist(fileRNdB)

					%Loading File for Lin Sound
					f=['load ' fileRNdB];
					eval(f);
					disp(f);
					disp(setstr(10));

					%Adding to RN List
					RNList(count,(l-1)*LL+(1:length(fileRNdB)))=fileRNdB;

					%Finding FSI
					fsiRN(count,1)=fsibin(p1,p2,p1r,p2r,spindex1,spindex2);
					fsiRN(count,2)=fsibin(p1e,p2e,p1er,p2er,spindex1,spindex2);
					fsiRN(count,3)=fsibin(p1i,p2i,p1ir,p2ir,spindex1,spindex2);
					fsiRN(count,4)=fsibinind(p1,p2,p1r,p2r);

					%Loading STRF File and Extracting Firing
					%Rate and STRF STD
					i=findstr(fileRNdB,'.mat');
					f=['load ' fileRNdB(1:i-4)];
					eval(f)
					WoRN(count)=Wo1;
					stdRN(count)=strfstd(STRF1s,STRF2s,PP,1/(taxis(2)-taxis(1)));
					ppRN(count)=( max(max([STRF1s STRF2s]))-min(min([STRF1s STRF2s])) )*sqrt(PP);
				end

			elseif strcmp(UnitsRN(l),'-')

				%Adding to RN List
				RNList(count,1:3)='---';
			
				%Finding FSI
				fsiRN(count,1:4)=[0 0 0 0];
				fsiRN(count,1:4)=[0 0 0 0];
				WoRN(count)=-9999;
				stdRN(count)=-9999;
				ppRN(count)=-9999;
			end
		end

		%Incrementing Counter
		count=count+1;

	end
end

%Truncating the MRList and RNList
RNList=RNList(1:count-1,:);
MRList=MRList(1:count-1,:);


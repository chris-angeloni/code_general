%
%function []=converttankdata(ExcelFile,Month)
%
%       FILE NAME   : CONVERT TANK DATA
%       DESCRIPTION : Extracts the data from the rabbit experiments in a
%                     given tank. Uses an excel spread sheet to sort
%                     through all of the recordings.
%
%       ExcelFile   : Input excel spread sheet file name
%       Month       : Month to extract (e.g. 'Oct','Nov')
%       Year        : Year, e.g. 2010
%
%RETURNED VALUE
%       
% (C) Monty A. Escabi, October 2010
%
function []=converttankdata(ExcelFile,Month,Year)

%Read Excel Information and determine if month is present
try
    [num,txt,raw] = xlsread(ExcelFile,[Month num2str(Year)]);
    flag=1;
catch
    flag=0;
    Data=0;
end

%Convert Data if month is present
if flag==1
    
    %Extracting Data
    for k=1:size(raw,1)

        %Data Fields
        AnimalNumber=cell2mat(raw(k,1));
        Date=cell2mat(raw(k,2));
        Time=cell2mat(raw(k,3));
        Tank=cell2mat(raw(k,4));
        BlockNumber=cell2mat(raw(k,5));
        ChannelNumber=cell2mat(raw(k,6));
        if isempty(ChannelNumber) | isnan(ChannelNumber)
           ChannelNumber=1;
        end
        SiteNumber=cell2mat(raw(k,7));
        Sound=cell2mat(raw(k,8));
        Status=cell2mat(raw(k,9));
        ATT=cell2mat(raw(k,10));
        Sort=cell2mat(raw(k,11));
        CF=cell2mat(raw(k,12));
        Notes=cell2mat(raw(k,13));
        Depth=cell2mat(raw(k,14));
        AP=cell2mat(raw(k,15));
        ML=cell2mat(raw(k,16));

        %Output File Name
        OutFile=['Data' AnimalNumber 'Site' int2strconvert(SiteNumber,4) Month 'Tank' num2str(Tank) 'Block' num2str(BlockNumber)];
        
        if ~isstr(BlockNumber) & ~isnan(BlockNumber) & ~strcmp(Status,'BAD') & ~exist(OutFile,'file')

            %Datae and Year informatoin
            Month=datestr(Date,'mmm');
            Year=datestr(Date,'yyyy');
            TankFileName=['Rabbit' AnimalNumber Month num2str(Year) 'Tank' num2str(Tank)];
          
            %Add data fields to structure
            Data.AnimalNumber=AnimalNumber;
            Data.TankFileName=TankFileName;
            Data.Date=Date;
            Data.Time=Time;
            Data.Tank=Tank;
            Data.BlockNumber=BlockNumber;
            Data.ChannelNumber=ChannelNumber;
            Data.SiteNumber=SiteNumber;
            Data.Sound=Sound;
            Data.Status=Status;
            Data.ATT=ATT;
            Data.Sort=Sort;
            Data.CF=CF;
            Data.Notes=Notes;
            Data.Depth=Depth;
            Data.AP=AP;
            Data.ML=ML;

            %Reading Tank and saving data on an external matalab session;
            %this avoids memory allocation problems when reading large
            %recording blocks
            save TempVariable.mat Data
            %!matlab -nodesktop -nosplash -r load('TempVariable.mat');converttankdatasub(Data);exit;
            !matlab -nodesktop -nosplash -r load('TempVariable.mat');p=pathdef;matlabpath(p);converttankdatasub(Data);exit;
        end
    end

end
!del TempVariable.mat
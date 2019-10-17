%
%function [METAData] = xls2metadata(Header,Save)
%	
%	FILE NAME   : XLS 2 META DATA
%	DESCRIPTION : Converts XLS file containing sound database to a
%                 matlab data structure
%
%   Header      : Sound CD Header
%	Save        : optional -> 'y' or 'n'
%                 default  -> 'n'
%
%RETURNED VARIABLES
%
%   METAData    : Data structure containg sound database information   
%
%       .Header       - 
%       .Track        - CD Track number
%       .Type.Voiced  - 
%       .Type.Textire -
%
%
% (C) Monty A. Escabi, January 2013
%
function [METAData]=xls2metadata(Header,Save)

%Input Arg
if nargin<2
    Save='n';
end

[NUMERIC,TXT,RAW]=xlsread([Header '.xls']);


offset=4;
for k=1:size(NUMERIC,1)-offset
    
    METAData(k).Header=Header;
    METAData(k).Track=cell2mat(RAW(k+offset,1));
    METAData(k).Type.Voiced=cell2mat(RAW(k+offset,2));
    METAData(k).Type.Texture=cell2mat(RAW(k+offset,3));
    METAData(k).Species.Birds.Song=cell2mat(RAW(k+offset,4));
    METAData(k).Species.Birds.Predatory=cell2mat(RAW(k+offset,5));
    METAData(k).Species.Birds.Parrots=cell2mat(RAW(k+offset,6));
    METAData(k).Species.Birds.Others=cell2mat(RAW(k+offset,7));
    METAData(k).Species.Amphibians.Frogs=cell2mat(RAW(k+offset,8));
    METAData(k).Species.Amphibians.Toad=cell2mat(RAW(k+offset,9));
    METAData(k).Species.Amphibians.Others=cell2mat(RAW(k+offset,10));
    METAData(k).Species.Mammals.Humans=cell2mat(RAW(k+offset,11));
    METAData(k).Species.Mammals.Primates.OldWorld=cell2mat(RAW(k+offset,12));
    METAData(k).Species.Mammals.Primates.NewWorld=cell2mat(RAW(k+offset,13));
    METAData(k).Species.Mammals.Others=cell2mat(RAW(k+offset,14));
    METAData(k).Species.Fish=cell2mat(RAW(k+offset,15));
    METAData(k).Species.Insects=cell2mat(RAW(k+offset,16));
    METAData(k).Background.Birds=cell2mat(RAW(k+offset,17));
    METAData(k).Background.Insects=cell2mat(RAW(k+offset,18));
    METAData(k).Background.Others=cell2mat(RAW(k+offset,19));
    METAData(k).Background.Mechanical.Movement=cell2mat(RAW(k+offset,20));
    METAData(k).Background.Mechanical.Machine=cell2mat(RAW(k+offset,21));
    METAData(k).Comment=cell2mat(RAW(k+offset,22));
    METAData(k).BeginEnd=[cell2mat(RAW(k+offset,26)) cell2mat(RAW(k+offset,27))];
    METAData(k).Segment1=[cell2mat(RAW(k+offset,28)) cell2mat(RAW(k+offset,29))];
    METAData(k).Segment2=[cell2mat(RAW(k+offset,30)) cell2mat(RAW(k+offset,31))];
    METAData(k).Segment3=[cell2mat(RAW(k+offset,32)) cell2mat(RAW(k+offset,33))];
    METAData(k).Segment4=[cell2mat(RAW(k+offset,34)) cell2mat(RAW(k+offset,35))];
    METAData(k).Soundscape1=[cell2mat(RAW(k+offset,36)) cell2mat(RAW(k+offset,37))];
    METAData(k).Soundscape2=[cell2mat(RAW(k+offset,38)) cell2mat(RAW(k+offset,39))];
    
end

%Saving Meta Data
if strcmp(Save,'y')
    %Saving META File
    save([Header '_META.mat'],'METAData');
end

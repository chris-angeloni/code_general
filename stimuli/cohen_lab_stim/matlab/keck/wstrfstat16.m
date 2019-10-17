%
%function [STRFData16s]=wstrfstat16(STRFData16,p,MdB,ModType,Sound,SModType)
%
%       FILE NAME       : WSTRF STAT 16
%       DESCRIPTION     : Finds the significant STRFs for a 16 channel data
%                         STRF structure
%
%	STRFData16      : Spectro-Temporal Receptive Field
%	p               : Significance Probability
%	MdB             : Modulation depth
%	ModType         : Modulation type used to construct Receptive Field 
%	Sound           : Sound Type
%                         Moving Ripple : 'MR' ( Default )
%                         Ripple Noise  : 'RN'
%	SModType        : Sound Modulation Type : 'lin' or 'dB'
%
%RETURNED VALUES
%	STRFData16s     : Significant STRF Data structure at a significance prob.
%                         of p
%
% (C) Monty A. Escabi, Dec 2005
%
function [STRFData16s]=wstrfstat16(STRFData16,p,MdB,ModType,Sound,SModType)

%Initializing
STRFData16s=STRFData16;

%Computing Significant STRFs
for k=1:length(STRFData16)
   
    [STRF,Tresh]=wstrfstat(STRFData16(k).STRF1,p,STRFData16(k).No1,STRFData16(k).Wo1,STRFData16(k).PP,MdB,ModType,Sound,SModType);
    STRFData16s(k).STRF1=STRF;
    [STRF,Tresh]=wstrfstat(STRFData16(k).STRF2,p,STRFData16(k).No2,STRFData16(k).Wo2,STRFData16(k).PP,MdB,ModType,Sound,SModType);
    STRFData16s(k).STRF2=STRF;
    
end
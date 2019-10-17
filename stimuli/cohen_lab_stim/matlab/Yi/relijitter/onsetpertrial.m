function [RASonset]=onsetpertrial(RASspet)
for i=1:180
    in=find(RASspet(i).spet/RASspet(i).Fs<0.02);
    if isempty(in)
        RASonset(i).spet=nan(1);
    else
        RASonset(i).spet=RASspet(i).spet(in);
    end
    RASonset(i).T=0.2;
    RASonset(i).Fs=RASspet(i).Fs;
end
function [amps, db] = makeDRCAmps_scaled(n,Mu,Sd,nTones,blockSamps,baseAmp,seed)

%% function [amps, db] = makeDRCAmps(n,Mu,Sd,nTones,blockSamps,baseAmp)
% generates noise patterns of different contrasts, drawn from
% two uniform distributions
amps = [];
db = [];
if exist('seed','var')
    rng(seed);
end
for j = 1:n
    % make some dB and amplitude values per frequency
    MU = Mu;
    SD = Sd(mod(j-1,length(Sd))+1);
    dBs = unifrnd(-1,1,nTones,blockSamps(j));
    dBs = (dBs*Sd) + MU;
    db = [db dBs];
    a = baseAmp .* 10 .^ ((dBs-70)./20);
    amps = [amps a];
end

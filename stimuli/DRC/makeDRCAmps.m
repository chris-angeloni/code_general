function [amps, db] = makeDRCAmps(n,Mu,Sd,nTones,blockSamps,baseAmp)

%% function [amps, db] = makeDRCAmps(n,Mu,Sd,nTones,blockSamps,baseAmp)
% generates noise patterns of different contrasts, drawn from
% two uniform distributions
amps = [];
db = [];
for j = 1:n
    % make some dB and amplitude values per frequency
    MU = Mu;
    SD = Sd(mod(j-1,length(Sd))+1);
    dBs = unifrnd(MU-SD,MU+SD,nTones,blockSamps(j));
    db = [db dBs];
    a = baseAmp .* 10 .^ ((dBs-70)./20);
    amps = [amps a];
end

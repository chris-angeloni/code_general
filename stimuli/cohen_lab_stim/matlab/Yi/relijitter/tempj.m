function [MTFJall,SIGall]=tempj(MTFJall,SIGall,RASTER,FMAxis)

for i=127:127
    close all
    [MTFJd]=mtfrelijitter(RASTER(i,:),FMAxis,'rel');
    MTFJall(i,:)=MTFJd;
    % [RASsh]=shuffleras(RASTER(i,:),FMAxis,'duration',1);
    % [MTFJ]=mtfrelijittergau(RASsh,FMAxis,'rel');
    % [SIG]=sigtestp([MTFJd(1,:).Rpeak],[MTFJ(1,:).Rpeak],[MTFJd(1,:).sepeak],[MTFJ(1,:).sepeak],0.05,FMAxis);
    % SIGall(i,:)=SIG;
end


% function [P]=tempj(P,MTFJ,FMAxis)
% % refractory period from Raa

% for i=140:140
% [M,refp]=refperiod(MTFJ(i,:),FMAxis);
% P(i)=M;
% en
more off;
tank=['MG1100L09F'];
for block=[19]

figure;
[FTC]=onlineftc2(tank,[block],10,40)

FTC2=FTC(2)
[FTCt]=ftcthreshold(FTC2,0.05);
close;
figure;
ftcplot(FTCt);
[FTCStats]=ftccentroid(FTCt);
FTCLevelnew=[FTC(1).Level'];
hold on;
plot(FTCStats.Mean(6:9)/1000,FTCLevelnew(6:9),'ko');
plot(FTCStats.Mean(6:9)/1000,FTCLevelnew(6:9),'m.','markersize',14);

FTCcentroids=[FTCStats.Mean(6:9)/1000,round(FTCLevelnew(6:9)+6)]
CF=[sum(FTCcentroids(:,1))/4];
filename=[tank 'block_' num2str(block)]
title([tank 'block ' num2str(block)])
f=['save ' tank 'block_' num2str(block)]

eval(f);

f=['print -djpeg ' tank 'block_' num2str(block)];
eval(f);

end


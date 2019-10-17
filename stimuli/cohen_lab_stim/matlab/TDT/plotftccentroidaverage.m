
more off;
%tank=['MG0001L09F'];
%for block=[9 19 25 28 31]   
%for block=[32 34]
%tank=['MG1100L09F'];
%for block=[1 4 7 10 16 23 28 31]
%for block=[13 19]
%tank=['MG1010L10F'];
%for block=[1 3 7 18 24 27 33 36]
%tank=['MG1011L09F'];
%for block=[1 4 8 23 27 35 38 50]
%tank=['MG1000L10F'];
%for block=[1 7 9 11 19 21 27]
tank=['MG1001L06F'];
for block=[4]

figure;
[FTC]=onlineftc(tank,[4:5],10,40);
[FTCt]=ftcthreshold(FTC,0.05);
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
filename=[tank 'block' num2str(block)];    
%P=['C:\Documents and Settings\nate\Desktop\Tuning\'];
%how do do this
title([filename]);

f=['save ' tank 'block_' num2str(block)];

eval(f);

f=['print -djpeg ' tank 'block_' num2str(block)];
eval(f);

end


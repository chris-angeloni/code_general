series=[15 17 202 211 212];
str1='E:\projects\AM\data\July1106\site'
str2='ftc.mat'
for i=1:length(series)
  load([str1 num2str(series(i)) str2]);
  [FTChist] = ftchistgenerateboot(Data,0,300,500);
  FTCst=ftcstats(FTChist);
  cf(1,i)=FTCst.CF;
end
%  01 02 021 022 03 052 06 09 091 
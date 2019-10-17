function batchtetrodesub

load temp.mat
[Tetrode]=tdt2tetrode(TankFileName,BlockNumber,TetrodeNumber,ServerName);
filename = [TankFileName 'Block' int2str(BlockNumber) 'Tetrode' int2str(TetrodeNumber)];
save ([OutPath '\' filename], 'Tetrode'); 

exit
load temp.mat


if ~exist(tetrodedatafilename,'file')
    s=['load ' path '/' filename];
    eval(s)
    covfn=[outpath '/' filename(1:length(filename)-4) 'Cov.mat'];
    if exist(covfn,'file')
        eval(['load ' covfn ';']);
        [TetrodeData]=tetrodespikedetect(Tetrode,C,Thresh,T,fl,fh,US,DeadTime,AlignWindow,'y');
    else
        [TetrodeData]=tetrodespikedetect(Tetrode,-9999,Thresh,T,fl,fh,US,DeadTime,AlignWindow,'y');
    end
    C=TetrodeData.C;
    save(covfn,'C');
    save(tetrodedatafilename,'TetrodeData');
    close all
    clear Tetrode TetrodeData;
end

exit
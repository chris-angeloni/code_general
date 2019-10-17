% batch tetrodedata into matlab format from tdt tank files

function batchtetrode(excelfn,sheetname,OutPath)

if nargin<3
    OutPath='C:\MATLAB74\work\Chen\TetrodeAnalysis\Data';
end
[A,B]=xlsread(excelfn,sheetname);

for i=1:size(A,1)
    TankFileName=char(B(i,1));
    BlockNumber=A(i,1);
        for TetrodeNumber=1:4
            save temp.mat TankFileName BlockNumber TetrodeNumber OutPath
            !matlab -r batchtetrodesub
        end

end
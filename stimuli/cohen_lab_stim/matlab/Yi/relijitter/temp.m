function [MTFJall]=tempj(MTFJall,RASTER,FMAxis)

for i=1:4
    [MTFJ]=mtfrelijitter(RASTER(i,:),FMAxis,'abs')
    MTFJall(i,:)=MTFJ;
end

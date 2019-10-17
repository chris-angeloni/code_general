function histoAccept

INCLUDE_DEFS;

[hobj, hfig] = gcbo;

global selectedHistos

putNewAttribute(PK1PK, selectedHistos(1));
putNewAttribute(PK1END, selectedHistos(2));
putNewAttribute(PK2START, selectedHistos(3));
putNewAttribute(PK2END, selectedHistos(4));

set(gcbo, 'backgroundcolor', NORMBUTTONCOLOR);

return

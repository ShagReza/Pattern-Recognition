function scr2= ComparisionThreshold(t,c,MAD,MED,scr)

scr=(scr-MED)/(c*MAD);
B  = ones(size(scr,1),size(scr,2)) + exp(-1*(scr-repmat(t,size(scr,1),size(scr,2))));
W  = ones(size(scr,1),size(scr,2))./B;
Z=scr-repmat(t,size(scr,1),size(scr,2));
scr2 = sum(W.*Z,1)./sum(W,1);

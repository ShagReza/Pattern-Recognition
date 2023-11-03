function scr= ComparisionThershod_t1(t1,sigma,backend_scr)
scr=backend_scr;

if sigma == 0
    sigma=0.01;
end

B  = ones(size(scr,1),size(scr,2)) + exp(-1*(scr-repmat(t1,size(scr,1),size(scr,2)))/sigma);
A  = ones(size(scr,1),size(scr,2))./B;

for i=1:size(scr,1)
    for j=1:size(scr,2)
        if A(i,j)==0
            A(i,j)=0.0001;
        end
    end
end

scr = sum(scr.*A,1)./sum(A,1);


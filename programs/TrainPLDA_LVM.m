
function PLDAModel=TrainPLDA_LVM(DataPLDA,classTest,N_ITER,Ny,Nx)

%------------------
ID=zeros(length(classTest),max(classTest));
for i=1:length(classTest)
    ID(i,classTest(i))=1;
end
ID=sparse(ID);
%------------------
data=zeros(size(DataPLDA,1),size(DataPLDA,2));
J=size(DataPLDA,3);
for j=1:J
    data(:,:)=DataPLDA(:,:,j);
    PLDAModel(j) = PLDA_Train(data',ID, N_ITER,Ny,Nx);
end
%------------------

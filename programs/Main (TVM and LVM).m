

%------------------- IVECTOR --------------------------
%---
pathstates=ProgramsInputs;
load( [pathstates,'\Methods'] );
load( [pathstates,'\Path']);
load( [pathstates,'\Param'] );
%---
kerneltype=Param.kerneltype;
c=Param.c;
g=Param.g;
ny=Param.ny;
Norm_ivector=Param.Norm_ivector;
NAPivector_Dim=Param.NAPivector_Dim;
LDA_ivector=Param.LDA_ivector;
NAP_ivector=Param.NAP_ivector;
WCCN_ivector=Param.WCCN_ivector;
TrainMethod=Param.TrainMethod;
NormScrs_target=Param.NormScrs_target;
NormScrs=Param.NormScrs;
art_data=Param.art_data;
LDAdim=Param.LDAdim;
OneVersusRest=1;
LDAmodel=[];
P_NAP=[];
B_WCCN=[];
FS=8000;
MethodName='IvectorSvm';
IvectorSvmpath=[Path.Prog,'\',MethodName];
mkdir(IvectorSvmpath);
SVM_Matlab=0;
MatlabSVM_train=[];
mkdir([Path.Prog,'\ResultIvector']);
method=Param.trainmethod;
RealTestData=Param.RealTestData;
method= str2num(method);
%------------------------  Train TVM  ----------------------------------
segmentation_train=0;
FeatureLabelExtraction_ivector2(pathstates,IvectorSvmpath,segmentation_train);
ModelTrainingUBM(pathstates,IvectorSvmpath);
y=TrainT2(pathstates,IvectorSvmpath,ny,TrainMethod);
[ivector_train,classIvectTrain]=IvectorExtract3_2(pathstates,IvectorSvmpath,1);
ivector_train=ApplyNormLdaWccnNap(ivector_train,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN);

Path.PLDA =Path.LDA;
save( [pathstates,'\Methods'] ,'Methods');
save( [pathstates,'\Path'] ,'Path');
save( [pathstates,'\Param'] ,'Param');
JFA_eigen_lists='ivector_Plda';
[DataPLDA,classTest]=ivecExt(pathstates,IvectorSvmpath,JFA_eigen_lists);
DataPLDA=ApplyNormLdaWccnNap(DataPLDA,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN);
%TrainPLDA
N_ITER = 10; Ny=80; Nx=20;
PLDAModel=TrainPLDA(DataPLDA,classTest,N_ITER,Ny,Nx);
save([Path.Prog,'\ResultIvector\PLDAModel'], 'PLDAModel');
%--------------------------------------------------------------------------


%-----------------------   Test TVM   -------------------------------------
JFA_eigen_lists='ivector_test';

[DataTestSvm_test,ivector_test,classTest_test,CLASS_test,NumOfSegments_test,NumOfTest_test]=TestIvector2(pathstates,IvectorSvmpath,JFA_eigen_lists);
JFA_eigen_lists='ivector_imptest';

[DataIImpSvm,ivector_imp,classTest_imp,CLASS_imp,NumOfSegments_imp,NumOfTest_imp]=ImposterIvector2(pathstates,IvectorSvmpath,JFA_eigen_lists);
%---
ivector_test=ApplyNormLdaWccnNap(ivector_test,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN);
ivector_imp=ApplyNormLdaWccnNap(ivector_imp,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN);
%----
for i=1:size(ivector_train,1)
    for j=1:size(ivector_test,1)
        SCORE_test(i,j)= PLDA_Identification(PLDAModel, ivector_test(j,:)', ivector_train(i,:)');
    end
end
for i=1:size(ivector_train,1)
    for j=1:size(ivector_imp,1)
        SCORE_imp(i,j)= PLDA_Identification(PLDAModel, ivector_imp(j,:)', ivector_train(i,:)');
    end
end
%----
%Thhshold Finding:
[Results,meanE]=ThrFinding_mean_OneParam(NumOfSegments_test,NumOfTest_test,SCORE_test,NumOfSegments_imp,SCORE_imp);
%--------------------------------------------------------------------------





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LVM method %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------Train---------------------------------
% Train LVM:
[vLVM,CSV,J]=Train_LVMmatrix(pathstates,IvectorSvmpath,J);
%Lvector Extraction from train data:
[Lvector_train,classLvectTrain]=LvectorExtract(pathstates,IvectorSvmpath,vLVM,CSV,J);
%Lvector Extraction from PLDA data:
JFA_eigen_lists='ivector_Plda';
[DataPLDA,classTest]=LvecExt_PLDA(pathstates,IvectorSvmpath,JFA_eigen_lists,vLVM,CSV,J);
%TrainPLDA
N_ITER = 10; Ny=80; Nx=20;
PLDAModel=TrainPLDA_LVM(DataPLDA,classTest,N_ITER,Ny,Nx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------Test---------------------------------
%Extracting tests and impostor Lvectors:
JFA_eigen_lists='ivector_test';
[DataTestSvm_test,ivector_test,classTest_test,CLASS_test,NumOfSegments_test,NumOfTest_test]=TestIvector_LVM(pathstates,IvectorSvmpath,JFA_eigen_lists,vLVM,CSV,J);
JFA_eigen_lists='ivector_imptest';
[DataIImpSvm,ivector_imp,classTest_imp,CLASS_imp,NumOfSegments_imp,NumOfTest_imp]=ImposterIvector_LVM(pathstates,IvectorSvmpath,JFA_eigen_lists,vLVM,CSV,J);
%TestPLDA (target test data)
SCORE_test=zeros(size(Lvector_train,1),size(DataTestSvm_test,1));
for i=1:size(Lvector_train,1)
    for j=1:size(DataTestSvm_test,1)
        SCORE_test(i,j)=0;
        for k=1:J
            L1(1:256)= Lvector_train(i,:,k);
            L2(1:256)= DataTestSvm_test(j,:,k);
            SCORE_test(i,j)= SCORE_test(i,j)+PLDA_Identification(PLDAModel(k), L1',L2');
        end
         SCORE_test(i,j)= SCORE_test(i,j)/J;
    end
end
%TestPLDA (impostor test data)
SCORE_imp=zeros(size(Lvector_train,1),size(DataIImpSvm,1));
for i=1:size(Lvector_train,1)
    for j=1:size(DataIImpSvm,1)
        SCORE_imp(i,j)=0;
        for k=1:J
            L1(1:256)= Lvector_train(i,:,k);
            L2(1:256)= DataIImpSvm(j,:,k);
            SCORE_imp(i,j)= SCORE_imp(i,j)+PLDA_Identification(PLDAModel(k), L1',L2');
        end
         SCORE_imp(i,j)= SCORE_imp(i,j)/J;
    end
end
%Thhshold Finding:
[Results,meanE]=ThrFinding_mean_OneParam(NumOfSegments_test,NumOfTest_test,SCORE_test,NumOfSegments_imp,SCORE_imp);


















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test:
function [DataTestSvm,SCORE,classTest,CLASS,NumOfSegments,NumOfTest]=TestIvector(pathstates,IvectorSvmpath,JFA_eigen_lists,OneVersusRest,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN,NormScrs,NormScrs_target)
iter=10;
load(pathstates);
NumOfSegments=[]; %number of segments
FS=8000;
%________________
task='test';
FaSvmpath=IvectorSvmpath;
new=[IvectorSvmpath,'\',task];
mkdir(new);
mkdir([new,'\Waves'          ]);
mkdir([new,'\EnhancedWaves'  ]);
mkdir([new,'\Models']);
mkdir([new,'\Features']);
mkdir([new,'\Labels']);
%________________
PathModels=[IvectorSvmpath,'\Models'];
copyfile([PathModels,'\UBM.gmm'],[FaSvmpath,'\',task,'\Models\UBM.gmm'])
copyfile([PathModels,'\UBMinit.gmm'],[FaSvmpath,'\',task,'\Models\UBMinit.gmm'])
[MSV,CSV,W] = readALZgmm([PathModels,'\UBM.gmm']);
Dim=length(MSV)/length(W);
%________________
DataTestSvm=[]; NumOfTest=[];
classTest=[]; class=[]; CLASS=[];
WW=0;
TargetSpeakers=dir(Path.TargetSpeakers_Test);
for nl = 3:size(TargetSpeakers)
    PathWaves  = dir([Path.TargetSpeakers_Test,'\',TargetSpeakers(nl).name, '\*.wav']); % waves path of language nl
    NumOfTest(nl-2) = length(PathWaves); % number of wave files in language nl folder
    for j = 1:NumOfTest(nl-2)
        nl
        rmdir([new,'\Waves\'          ],'s'); mkdir([new,'\Waves\'          ]);
        rmdir([new,'\EnhancedWaves\'  ],'s'); mkdir([new,'\EnhancedWaves\'  ]);
        rmdir([new,'\Features\'       ],'s'); mkdir([new,'\Features\'       ]);
        rmdir([new,'\Labels\'       ],'s'); mkdir([new,'\Labels\'       ]);
        
        TestPath = [Path.TargetSpeakers_Test,'\',TargetSpeakers(nl).name, '\',PathWaves(j,1).name];
        [I, NS]=Segmentation_Gsl(j,Param.SegLen,FS,Param.LapLen,TestPath,new,TargetSpeakers(nl).name);
        FeatureLabelExtraction_ivectorTest(pathstates,new);
        %_________________________________________________________________%
        %         if lda==1 || lda==2
        %             EnhSegmentsPath   = dir([new,'\Features\*.ftr']);
        %             for b2 = 1:length(EnhSegmentsPath)
        %                 TestPath      = [new,'\Features\',EnhSegmentsPath(b2).name];
        %                 ApplingHLDA(TestPath,A,lda);
        %             end
        %         end
        %________________________________________________________________%
        EnhSegmentsPath   = dir([new,'\Waves\*.wav']);
        class=[]; NumEmpty=0; kk=0;
        for b2 = 1:length(EnhSegmentsPath)
            WavPath      = [new,'\Waves\',EnhSegmentsPath(b2).name];
            W_nam=EnhSegmentsPath(b2).name; W_nam(end-3:end) = [];
            [AA,B,C,D,Scrs] = textread([new,'\Labels\',W_nam,'.lbl'],'%s %s %s %s %f');
            if isempty(AA)==1
                NumEmpty=NumEmpty+1;
            else
                kk=kk+1;
                class(kk)=nl-2;
            end
        end
        %___
        JFA_s_lists       =[Path.Prog,'\lists\'];    mkdir(JFA_s_lists);
        fid_List = fopen([JFA_s_lists  JFA_eigen_lists  ,'.lst'],'w');
        Label1 ='MIX04_';
        Label2 ='_f=';
        Label3 ='data/Features/';

        dirFiles=dir([new,'\Labels\'       ]);
        for jj=3:length(dirFiles)
            dirFiles(jj).name(end-3:end)=[];
            VV = readHTK([new,'\Features\', dirFiles(jj).name,'.ftr'],0);
            save (['data\Features\', dirFiles(jj).name,'.ascii'],'VV','-ASCII');
            fprintf(fid_List,'%s\n' ,[Label1 TargetSpeakers(nl).name  Label2 Label3 dirFiles(jj).name]);
        end
        fclose (fid_List);
        make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],JFA_eigen_lists);
        
        tst=load(['data/stats/' JFA_eigen_lists]);
        m             = load('models/ubm_means');
        E             = load('models/ubm_variances');
        v_matrix_file = ['optimum_output/' ['v_opt_' num2str(iter) ]];
        load(v_matrix_file);
        ny = size(v, 1);
        tst.spk_ids = (1:size(tst.N,1))';
        n_speakers=max(tst.spk_ids);
        n_sessions=size(tst.spk_ids,1);
        
        tst.y=zeros(n_speakers,ny);
        tst.z=zeros(n_speakers,size(tst.F,2));    
        [tst.y]=estimate_y_and_v(tst.F, tst.N, 0, m, E, 0, v, 0, tst.z, tst.y, zeros(n_sessions,1), tst.spk_ids);
        %________________________________________________________________%
        NumOfSegments=[NumOfSegments,NS-NumEmpty];
        DataTestSvm=[DataTestSvm;tst.y];
        classTest=[classTest,class];
        WW=WW+1;
        CLASS(WW)=nl-2;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%____
%Norm:
if (Norm_ivector==1)
    for i=1:size(DataTestSvm,1)
        DataTestSvm(i,:)=DataTestSvm(i,:)./norm(DataTestSvm(i,:));
    end
end
%____
%LDA:
if (LDA_ivector==1)
    DataTestSvm=linproj(DataTestSvm', LDAmodel)';
end
%---
%NAP:
if (NAP_ivector==1)
    DataTestSvm=(P_NAP*DataTestSvm')';
end
%---
%WCCN:
if (WCCN_ivector==1)
    DataTestSvm=(B_WCCN*DataTestSvm')';
end
%---
MatlabSVM_train=[];
if OneVersusRest==1
    SCORE=TestSVM_OneVersusRest(pathstates,DataTestSvm,classTest,Path.Prog,Path.TargetSpeakers_Train,MatlabSVM_train,'test',NormScrs,NormScrs_target);
else
    SVM='LibSVM_train.libsvm';
    DatFile_SVM(DataTestSvm,classTest,Path.Prog,'test');
    dos(['svm-predict.exe  -b 1 SVM_test.txt  ',SVM,'  SVM-test-OUT.txt']);
    SCORE=ReadingSVMOutputFile(DataTestSvm,Path.TargetSpeakers_Train,'SVM-test-OUT.txt');
    %SCORE=(ApplyLLR(SCORE))';
    SCORE=(ApplyLLR2(SCORE))';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




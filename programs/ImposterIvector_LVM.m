

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test:
function [DataTestSvm,ivector_imp,classTest,CLASS,NumOfSegments,NumOfTest]=ImposterIvector_LVM(pathstates,IvectorSvmpath,JFA_eigen_lists,vLVM,CSV,J)
iter=10;
load( [pathstates,'\Methods'] );
load( [pathstates,'\Path']);
load( [pathstates,'\Param'] );
NumOfSegments=[]; %number of segments
FS=8000;
%________________
task='imposter';
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
Dim=39;
%________________
DataTestSvm=[]; NumOfTest=[];
classTest=[]; class=[]; CLASS=[];
WW=0;
ImpSpeakers=dir(Path.Impostors_Test);
for nl = 3:size(ImpSpeakers)
    NumOfTest(nl-2) = length(ImpSpeakers); 
    rmdir([new,'\Waves\'          ],'s'); mkdir([new,'\Waves\'          ]);
    rmdir([new,'\EnhancedWaves\'  ],'s'); mkdir([new,'\EnhancedWaves\'  ]);
    rmdir([new,'\Features\'       ],'s'); mkdir([new,'\Features\'       ]);
    rmdir([new,'\Labels\'       ],'s'); mkdir([new,'\Labels\'       ]);
    
    TestPath = [Path.Impostors_Test,'\',ImpSpeakers(nl).name];
    NN=ImpSpeakers(nl).name; NN(end-3:end)=[];
    [I, NS]=Segmentation_Gsl(1,Param.SegLen,FS,Param.LapLen,TestPath,new,NN);
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
        fprintf(fid_List,'%s\n' ,[Label1 ImpSpeakers(nl).name  Label2 Label3 dirFiles(jj).name]);
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
    tst.y=estimateLvector(tst.N,tst.F,vLVM,CSV,J);
        
        %v1=v(1:200,:);v2=v(201:400,:); v3=v(401:600,:);
        %[tst.y1]=estimate_y_and_v(tst.F, tst.N, 0, m, E, 0, v1, 0, tst.z, tst.y, zeros(n_sessions,1), tst.spk_ids);
        %[tst.y2]=estimate_y_and_v(tst.F, tst.N, 0, m, E, 0, v2, 0, tst.z, tst.y, zeros(n_sessions,1), tst.spk_ids);
        %[tst.y3]=estimate_y_and_v(tst.F, tst.N, 0, m, E, 0, v3, 0, tst.z, tst.y, zeros(n_sessions,1), tst.spk_ids); 
        %tst.y=[tst.y1,tst.y2,tst.y3];
    %________________________________________________________________%
    NumOfSegments=[NumOfSegments,NS-NumEmpty];
    DataTestSvm=[DataTestSvm;tst.y];
    classTest=[classTest,class];
    WW=WW+1;
    CLASS(WW)=nl-2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ivector_imp=DataTestSvm;
















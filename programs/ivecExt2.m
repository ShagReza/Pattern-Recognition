

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DataPLDA,classTest]=ivecExt2(pathstates,IvectorSvmpath,JFA_eigen_lists)
%________________
iter=10;
load(pathstates);
task='PLdaData';
new=[IvectorSvmpath,'\',task];
mkdir(new);
mkdir([new,'\Waves'          ]);
mkdir([new,'\EnhancedWaves'  ]);
mkdir([new,'\Models']);
mkdir([new,'\Features']);
mkdir([new,'\Labels']);
%________________
DataPLDA=[]; 
classTest=[]; 
PathSpks  = dir(Path.PLDA); % waves path of language nl
for j = 1:(length(PathSpks)-2)
    'sh:',j
    pathWavs=dir([Path.PLDA,'\',PathSpks(j+2).name,'\*.wav']);
    rmdir([new,'\Waves\'          ],'s'); mkdir([new,'\Waves\'          ]);
    rmdir([new,'\EnhancedWaves\'  ],'s'); mkdir([new,'\EnhancedWaves\'  ]);
    rmdir([new,'\Features\'       ],'s'); mkdir([new,'\Features\'       ]);
    rmdir([new,'\Labels\'       ],'s'); mkdir([new,'\Labels\'       ]);
    
    for i=1:length(pathWavs)
        TestPath = [Path.PLDA,'\',PathSpks(j+2).name, '\',pathWavs(i,1).name];      
        copyfile(TestPath,[new,'\Waves\',pathWavs(i,1).name]);
    end
    %FeatureLabelExtraction_ivectorTest(pathstates,new);
    FeatureLabelExtraction_ivectorTest3(pathstates,new);
    %___
    JFA_s_lists       =[Path.Prog,'\lists\'];    mkdir(JFA_s_lists);
    fid_List = fopen([JFA_s_lists  JFA_eigen_lists  ,'.lst'],'w');
    Label1 ='MIX04_';
    Label2 ='_f=';
    Label3 ='data/Features/';
    mkdir([Path.Prog,'\data\Features']);
    mkdir([Path.Prog,'\data\stats']);
    
    dirFiles=dir([new,'\Labels\'       ]);
    class=[];  kk=0;
    for jj=6:length(dirFiles)
        dirFiles(jj).name(end-3:end)=[];
        VV=[];
        VV = readHTK([new,'\Features\', dirFiles(jj).name,'.ftr'],0);
        [st,en,lab]=textread([new,'\Labels\', dirFiles(jj).name,'.lbl'],'%f %f %s');
        if isempty(st)==0
            FF=[];
            for hh=1:length(st)
                FF=[FF,VV(:,st(hh)*100:en(hh)*100)];
            end
            %save (['data\Features\', dirFiles(jj).name,'.ascii'],'VV','-ASCII');
            save (['data\Features\', dirFiles(jj).name,'.ascii'],'FF','-ASCII');
            fprintf(fid_List,'%s\n' ,[Label1 'lda'  Label2 Label3 dirFiles(jj).name]);
            kk=kk+1;
            class(kk)=j;
        end
    end
    fclose (fid_List);

    make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],JFA_eigen_lists);
    %___
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
    DataPLDA=[DataPLDA;tst.y];
    classTest=[classTest,class];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
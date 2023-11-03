
%Test With C program:

%---------------------------------------------------------
%---------------------------------------------------------
fid1=fopen('list3.txt','w');
A=dir('G:\Bistoon-Ph1AndIvector\Data\DataAmali_mobile10spks\Waves-for-Test\sh\Test\spk_04');
for i=1:(length(A)-2)
    B=A(i+2).name; B(end-3:end)=[];
    fprintf(fid1,'%s %s\n','G:\Bistoon-Ph1AndIvector\Data\DataAmali_mobile10spks\Waves-for-Test\sh\Test\spk_04', B);
end
A=dir('G:\Bistoon-Ph1AndIvector\Data\DataAmali_mobile10spks\Waves-for-Test\sh\Imp');
for i=1:(length(A)-2)
    B=A(i+2).name; B(end-3:end)=[];
    fprintf(fid1,'%s %s\n','G:\Bistoon-Ph1AndIvector\Data\DataAmali_mobile10spks\Waves-for-Test\sh\Imp', B);
end
fclose (fid1);
%---------------------------------------------------------
%---------------------------------------------------------


I=1;
new='G:\Bistoon-Ph1AndIvector\prog_sh\bistoon_run\prog_dataamali\TestC2';
mkdir([new,'\Waves\'          ]);
mkdir([new,'\EnhancedWaves\'  ]);
mkdir([new,'\Features\'       ]);
mkdir([new,'\Labels\'       ]);
mkdir([new,'\Diarization\']);
Path.SADmodels='G:\Bistoon-Ph1AndIvector\prog_sh\bistoon_run\prog_dataamali\models';
Param.SegLen=30;FS=8000;Param.LapLen=15;
[as,bs]=textread('list3.txt','%s %s');
for j=4:length(as)
     fid=fopen('res3.txt','a');

    TestPath=[as{j,1},'\',bs{j,1},'.wav'];
    wavname=[bs{j,1},'.wav'];
    dos(['SADLibTest.exe -Diarization ',TestPath,' ', [new,'\Diarization\'],' 0']);
    filename=[bs{j,1},'_List.txt'];
    SpkNames=textread([new,'\Diarization\',filename],'%s');
    scr=[];
    scr(1:length(SpkNames))=-10;
    for i=1:length(SpkNames)
        name=SpkNames{i,1}; name(end-3:end)=[];  SpkNames{i,1}=name;
        InputWaveFile=[new,'\Diarization\',SpkNames{i,1},'.wav'];
        OutputLabelFile=[new,'\Diarization\',SpkNames{i,1},'.lbl'];
        existFlag= exist(InputWaveFile); NS=0;
        if existFlag==2
            [s,fs]=wavread(InputWaveFile);
            if length(s)>fs*60*10 %10 min
                s(fs*60*10:end)=[];
            end
            wavwrite(s,fs,InputWaveFile);
            dos(['SADLibTest.exe -SAD ',InputWaveFile,' ', OutputLabelFile,' ', Path.SADmodels,'   Temp 1 Energy.txt 0  10  10 0.05 0.73 100']);
            dos(['Clip-VOICE.exe ' , InputWaveFile,' ',OutputLabelFile, ' ', 'a.wav']);
            AA=0; BB=0;
            [AA,BB,CC] = textread(OutputLabelFile,'%f %f %s');
            if sum(BB-AA)>5 %5 second                
                %dos(['MFCC.exe ',InputWaveFile,' ',[new,'\Diarization\',SpkNames{i,1},'.ftr'] ]);
                [xx,fs] = wavread('a.wav');
                s = 0.99* resample(xx,8000,fs);
                wavwrite(s,8000,'a.wav');
                dos(['Add-Noise.exe ' , 'a.wav b.wav 0.32767']);     
                dos(['MFCCWhitSAD.exe ','b.wav',' ',[new,'\Diarization\',SpkNames{i,1},'.ftr'] ]);
                %dos(['MFCC.exe ','b.wav',' ',[new,'\Diarization\',SpkNames{i,1},'.ftr'] ]);
                dos(['VAD.exe ','b.wav ',OutputLabelFile,' 0 -1 -1  0  SNR.txt 0 ']);
                
                ftrpath=[new,'\Diarization']; lblpath=[new,'\Diarization']; OutPath=[new,'\Diarization']; TestName=SpkNames{i,1};
                modelpath='G:\Bistoon-Ph1AndIvector\prog_sh\bistoon_run\prog_dataamali\modelsSpk_10Amali';
                dos(['TestIvector3.exe CfgIvecSpk_2048_2.txt ',ftrpath,' ',lblpath,' ',modelpath,' ',TestName,' ',OutPath,' Test.lst UBM 1024 Thr10Spk.txt']);
                A=textread([new,'\Diarization\',SpkNames{i,1},'.emt'],'%s');
                scr(i)=str2num(A{2,1});
            end
        end
    end
    maxscr=max(scr);
    
    if maxscr>0.5
        fprintf(fid,'%s:%s\n',wavname,'accept');  
    elseif maxscr==-10
         fprintf(fid,'%s:%s\n',wavname,'empty');  
    else
        fprintf(fid,'%s:%s\n',wavname,'reject');  
    end

end
fclose (fid);
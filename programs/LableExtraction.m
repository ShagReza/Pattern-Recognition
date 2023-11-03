function LableExtraction (new,VAD)
MedFiltLen = 5;          % VAD-SPEECH.exe program's parammeter: median filter length
MinThr     = 10;         % VAD-SPEECH.exe program's parammeter: minimum thershold
InitThr    = 10;         % VAD-SPEECH.exe program's parammeter: maximum thershold
VAD_parameter = 0.03;

EnhSegmentsPath   = dir([new,'\EnhancedWaves\*.wav']);
for b3=1:length(EnhSegmentsPath)
    InputWaveFile = [new,'\EnhancedWaves\',EnhSegmentsPath(b3,1).name];
    K = EnhSegmentsPath(b3,1).name; K(end-3:end)=[];
    OutputLabelFile = [new,'\Labels\',K,'.lbl'];
    if VAD==0
        s_vad = ['VAD-NF-0.9975.exe ',InputWaveFile,' ',OutputLabelFile,' ',num2str(MedFiltLen),' ',num2str(MinThr),' ',num2str(InitThr)];
        dos(s_vad);
    end

    if VAD==1
        s_vad = ['VAD.exe ',InputWaveFile,' ',OutputLabelFile,' ',num2str(MedFiltLen),' ',num2str(MinThr),' ',num2str(InitThr),' 1  SNR.txt ',num2str(VAD_parameter)];
        dos(s_vad);
    end
end
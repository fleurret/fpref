function response = WhispSegFile(audio_file_path)

audio_file_path=char(audio_file_path)
%%Paramters
options.sr = 44100;
options.num_trials = 5;
options.eps = 0.02;
options.channel_id = 0;
options.min_frequency=100;
options.min_segment_length=0.005 ;%min segment length in seconds (default: 0.005)
options.adobe_audition_compatible=0;
options.spec_time_step=0.0010   ;
%service_address="http://169.230.191.152:8051/segment";
%service_address="http://127.0.0.1:8050/segment";
service_address='http://169.230.191.127:8056/segment';
min_int=5;
min_dur=10;
sm_win=20;
threshold=1e-2;
filename=audio_file_path;


  if (filename(end-3:end)=='.wav')
               %break

               audio_file_path=[filename];
               [data Fs]=audioread(filename);
              % options.sr=44100;
               options.sr=Fs;
              
               response = callWhisperSegService(audio_file_path, service_address, options);
%#               Fs=44100;
            elseif filename(end-4:end)=='.cbin'  
            %    keyboard
              %  options.sr=44100;
                audio_file_path=[filename];
               % afp=audio_file_path;
                [data Fs]=ReadCbinFile(filename);                    
                data=data(:,1);
                audiowrite('tmp/1.wav',data./32768,Fs);
                response = callWhisperSegService('tmp/1.wav', service_address, options);
                %audio_file_path=("tmp/1.wav");
                options.sr=Fs;  
                %Fs=44100;
            elseif (filename~=NaN)   
               audio_file_path=filename;
               [data Fs]=audioread(audio_file_path);
               options.sr=Fs %44100;                
               response = callWhisperSegService(audio_file_path, service_address, options);
            else
                response=[]
                return;
                %return [];
               %Fs=44100;
            end
                
%                   break

        response = callWhisperSegService(audio_file_path, service_address, options);
       
        onsets=response.onset*1000;
        offsets=response.offset*1000;
        labels=repmat('o', [1, length(onsets)]); 
        WhispLabel=response.cluster; 
        %labels=[response.cluster{:}]

        %idx=find(strcmp(lower(string(WhispLabel)),'call')==1);
        %#labels(idx)='c';                    

        fname=audio_file_path;
        save(fname+".not.mat",'min_int','min_dur','labels',"offsets","onsets","sm_win","Fs","threshold","WhispLabel",'fname');                    
        disp(fname+".not.mat")

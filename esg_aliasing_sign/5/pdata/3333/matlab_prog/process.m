function status=process(spectrum,procno_out,varargin)

qf_value_fnmode=1;
qseq_value_fnmode=2;
tppi_value_fnmode=3;
states_value_fnmode=4;
states_tppi_value_fnmode=5;
ea_value_fnmode=6;
fcor=0.5;
status=1;%to return OK - set to zero to state error
when_output_exists_overwrite=1;
%%set options
xfb=0;
xf1=0;
cosft=0;

proc_seed=spectrum.procno;% may be changed...
for k = 1:length(varargin)
    if strcmpi(varargin{k},'xfb')% look for next available procno
        xfb=1;
    end
    if strcmpi(varargin{k},'cosft')% look for next available procno
        cosft=1;
    end
    if strcmpi(varargin{k},'xf1')% look for next available procno
        xf1=1;
    end
    if strcmpi(varargin{k},'dont_overwrite_when_already_exists')% look for next available procno
        when_output_exists_overwrite=0;
    end
    if strcmpi(varargin{k},'fcor')%for marta's cos mod spectra
        fcor = varargin{k+1};
    end
    if strcmpi(varargin{k},'proc_seed')%for marta's cos mod spectra
        proc_seed = varargin{k+1};
    end
end
disp(['>>>>>>>>>>>>>>>Fcor (first point of ft multiplied by ...) : ' num2str(fcor)])
%     if strcmpi(varargin{k},'move_up_and_sym')%for marta's cos mod spectra
%         move_up_and_sym=1;
%         variant = varargin{k+1};
%         nk(k:k+1) = [];
%     end
%     if strcmpi(varargin{k},'shift_up')%for marta's cos mod spectra
%         shift_up=1;
%         nb_up = varargin{k+1};
%         nk(k:k+1) = [];
%     end
% k
% num_arg
% size(list_arg)
% list_arg(k:k+num_arg) = [];
% end

%% check input exists and reads it
acqu_path=spectrum.path;%[super_base exp_name '/' num2str(expno) '/'];
path_in=[acqu_path num2str(spectrum.acquno) '/pdata/' num2str(proc_seed)];
path_out=[acqu_path num2str(spectrum.acquno) '/pdata/' num2str(procno_out) '/'];

if exist_folder_display_problem(path_in)
    % prepare target folder
    if when_output_exists_overwrite
        if exist(path_out,'dir')
            disp(['deleting existing folder : ' path_out]);
            rmdir(path_out,'s');
        end
    else
        for test_procno=procno_out:1e6
            path_out=[acqu_path '/pdata/' num2str(test_procno) '/'];
            if ~exist(path_out,'dir')
                procno_out=test_procno;
                break
            end
            
            
        end
    end
    % main copy command
    disp(['copying  : ' path_in]);
    disp(['to       : ' path_out]);
    copyfile(path_in,path_out);
    wrote_new_file=0;
    % generate 2rr files...
    if xfb%%% NOT IMPLEMENTED !!!!!!!!!!!!!!!!!!!!!!!!!
        error('not implemented yet...')
        if ~isfield(spectrum,'ser')%if not alread object of spectrum, reads it...
            path_ser=[acqu_path num2str(spectrum.acquno) '/ser' ];
            if exist(path_ser,'file')
                file_id=fopen(path_ser);
                
                ser=zeros(spectrum.td1,spectrum.td2);
                disp('read...');
                for loptd=1:spectrum.td1
                    in = fread(file_id ,spectrum.td2,'int');
                    ser(loptd,:)=in;
                end
                %here process....
                %here process....
                %here process....
                %here process....
                %here process....
                
            else
                error('No ser file to read')
            end
        end
        [ST,I] = dbstack;
        add_to_title(path_out,['Processed using matlab function ' ST.name ]);
        add_to_title(path_out,['With option xfb from procno = ' num2str(proc_seed) ]);
        add_to_title(path_out,[date]);    end
    if cosft
        if isfield(spectrum,'xf2data')%woks on xf2 processed data
            si=size(spectrum.xf2data,1);
            
            xf2data_work(1:2:si,:)=real(spectrum.xf2data(1:2:si,:));
            xf2data_work(2:2:si,:)=imag(spectrum.xf2data(1:2:si,:));
            
            
            disp('apply FT (only working for states-tppi data)')
            % prepare for FT
            working_dim=1;
            xf2data_work(1,:)=xf2data_work(1,:)*0.5;
            %out=fft(xf2data_work,[],working_dim);out=flipud(out);%not totally correct see demo 1D
            out=ifft(xf2data_work,[],working_dim);%this is correct....
            out=fftshift(out,working_dim);
            out=out*size(out,1);%rescale according to difference between fft and ifft
            
            % % %             %optional display
            % % %             figure(13);clf;
            % % %             contour(real(out),max(max(real(out)))*[0.8 0.4 0.2 0.1 0.05 -0.8 -0.4 -0.2 -0.1 -0.05]);
            disp('rescale Y')
            [out, new_nc_proc, min_out, max_out]=rescale_bruker_spectrum(out);
            disp('writing 2rr file')
            
            file_outz =fopen([path_out '2rr'],'w');
            for loop = 1:size(out,1)
                fwrite(file_outz,out(loop,:),'int');
            end
            %fix procs files
            disp('fix proc files')
            procfile_to_change=[path_out '/procs'];
            setbrukerparam(procfile_to_change,'NC_proc',num2str(new_nc_proc));
            setbrukerparam(procfile_to_change,'YMAX_p',num2str(round(max_out-0.5)));
            setbrukerparam(procfile_to_change,'YMIN_p',num2str(round(min_out+0.5)));
            %fix proc2s files
            procfile_to_change=[path_out '/proc2s'];
            setbrukerparam(procfile_to_change,'SI',num2str(size(out,1)));
            setbrukerparam(procfile_to_change,'YMAX_p',num2str(round(max_out-0.5)));
            setbrukerparam(procfile_to_change,'YMIN_p',num2str(round(min_out+0.5)));
            warning('data in target folder cannot be phased... 2ir 2ri 2ii were not generated')
            wrote_new_file=1;
            disp('done...')
            [ST,I] = dbstack;
            add_to_title(path_out,['Processed using matlab function ' ST.name ]);
            add_to_title(path_out,['With option cosft from procno = ' num2str(proc_seed) ]);
            add_to_title(path_out,[date]);
            
        else
            error('No xf2data for this spectrum. Topspin processing should be done with using xf2.')
        end
    end
    if xf1
        if isfield(spectrum,'xf2data')
            %         path_in=[acqu_path num2str(spectrum.acquno) '/pdata/' num2str(spectrum.procno) '/2rr'];
            %         if exist(path_in,'file')
            %             file_id=fopen(path_in);
            %
            %             xf2data=zeros(spectrum.td1,spectrum.si2);%this will do zero filling
            %             disp('read...');
            %             for loptd=1:spectrum.td1/2
            %                 inr= fread(file_id ,spectrum.si2,'int');%read real
            %                 ini= fread(file_id ,spectrum.si2,'int');%real imag
            %                 xf2data(loptd,:)=(inr+1i*ini)/spectrum.nc_proc;
            %             end
            working_dim=1;
            
            xf2data_work=spectrum.xf2data;
            
            if spectrum.fnmode==tppi_value_fnmode
                disp('Processing with TPPI');
                               % xf2data_work=make_complex(xf2data_work);

                % apply phase correction
                %  xf2data_work=phase_correct(xf2data_work,spectrum.phc01_proc2,spectrum.phc11_proc2,1);
                % apply window function
                xf2data_work=apply_window_function(xf2data_work,spectrum.wdw1,spectrum.ssb1,1);
                % prepare for FT
                xf2data_work(1,:)=xf2data_work(1,:)*fcor;
                 out=ifft(xf2data_work,spectrum.si1_request,working_dim); out=out*size(out,1);%this is correct....
                 out=out(1:(size(out,1)/2),:);%take half
             %   out=flipud(out);
              %  out=fftshift(out,working_dim);
                out=phase_correct(out,spectrum.phc01_proc2,spectrum.phc11_proc2,1);%phase correction %%%% NOT FULLY IMPLEMENTED !!!!!!!!!!!!!
                
            elseif spectrum.fnmode==states_tppi_value_fnmode
                % this should not work... but it does. as long as phase is not first
                % order...
                disp('Processing with States_TPPI');
                xf2data_work=make_complex(xf2data_work);
               
                % apply window function
                xf2data_work=apply_window_function(xf2data_work,spectrum.wdw1,spectrum.ssb1,1);%window function  %%%% NOT FULLY IMPLEMENTED !!!!!!!!!!!!!
                % prepare for FT
                xf2data_work(1,:)=xf2data_work(1,:)*fcor;
               % out=fft(xf2data_work,spectrum.si1_request,working_dim);out=flipud(out);%not totally correct see demo 1D
                 out=ifft(xf2data_work,spectrum.si1_request,working_dim); out=-out*size(out,1);%this is correct....
                out=phase_correct(out,spectrum.phc01_proc2,spectrum.phc11_proc2,1);%phase correction %%%% NOT FULLY IMPLEMENTED !!!!!!!!!!!!!
                
            elseif (spectrum.fnmode==states_value_fnmode) || (spectrum.fnmode==ea_value_fnmode)
                
                disp('Processing with States');
                xf2data_work=make_complex(xf2data_work);
                % apply window function
                xf2data_work=apply_window_function(xf2data_work,spectrum.wdw1,spectrum.ssb1,1);%window function  %%%% NOT FULLY IMPLEMENTED !!!!!!!!!!!!!
                % prepare for FT
                xf2data_work(1,:)=xf2data_work(1,:)*fcor;
                %  out=fft(xf2data_work,spectrum.si1_request,working_dim);out=fftshift(out,1);out=flipud(out);%not totally correct see demo 1D
                out=ifft(xf2data_work,spectrum.si1_request,working_dim);out=fftshift(out,1); out=out*size(out,1);%this is correct....
                                % apply phase correction
                out=phase_correct(out,spectrum.phc01_proc2,spectrum.phc11_proc2,1);%phase correction %%%% NOT FULLY IMPLEMENTED !!!!!!!!!!!!!
                if (spectrum.fnmode==ea_value_fnmode)
                    out=-out;
                end
                %
                %
                
            end
            
            % % %             %optional display
            % % %             figure(13);clf;
            % % %             contour(real(out),max(max(real(out)))*[0.8 0.4 0.2 0.1 0.05 -0.8 -0.4 -0.2 -0.1 -0.05]);
            disp('rescale Y')
            [out, new_nc_proc, min_out, max_out]=rescale_bruker_spectrum(out);
            disp('writing 2rr file')
            
            file_outz =fopen([path_out '2rr'],'w');
            for loop = 1:size(out,1)
                fwrite(file_outz,out(loop,:),'int');
            end
            %fix procs files
            disp('fix proc files')
            
            procfile_to_change=[path_out '/procs'];
            setbrukerparam(procfile_to_change,'NC_proc',num2str(new_nc_proc));
            setbrukerparam(procfile_to_change,'YMAX_p',num2str(round(max_out-0.5)));
            setbrukerparam(procfile_to_change,'YMIN_p',num2str(round(min_out+0.5)));
            %fix proc2s files
            procfile_to_change=[path_out '/proc2s'];
            setbrukerparam(procfile_to_change,'SI',num2str(size(out,1)));
            setbrukerparam(procfile_to_change,'YMAX_p',num2str(round(max_out-0.5)));
            setbrukerparam(procfile_to_change,'YMIN_p',num2str(round(min_out+0.5)));
            warning('data in target folder cannot be phased... 2ir 2ri 2ii were not generated')
            wrote_new_file=1;
            
            [ST,I] = dbstack;
        add_to_title(path_out,['Processed using matlab function ' ST.name ]);
        add_to_title(path_out,['With option xf1 from procno = ' num2str(proc_seed) ]);
        add_to_title(path_out,[date]);    
            
            disp('done...')
        else
            error('No xf2data for this spectrum. Topspin processing should be done with using xf2.')
        end
        
    end
    if wrote_new_file
        procfile_to_change=[path_out '/proc2s'];setbrukerparam(procfile_to_change,'XDIM',num2str(1));%in case xdim was used
    end
    %         %% example 2 from Eduard
    %         reconstruction=....
    %           setbrukerparam(procfile_to_change,'SI',num2str(reconstruction.points_F1)); %function to overwrite the data in proc2s
    %         setbrukerparam(procfile_to_change,'OFFSET',num2str(reconstruction.chemical_shift(1,reconstruction.points_F1)));
    %         setbrukerparam(procfile_to_change,'SW_p',num2str(SW_F1*data.bf2));
    %
else
    status=0;%problem with file
end


end

%% demo ft in F1 using xf2 dataset
%% in proc 1: normal spectrum
%% in proc 2: spectrum after xf2
%% in proc 3: spectrum after xfb, but without window function... not line pred (for comparision with matlab processed data).
clear all

%% create and manage archive
create_archive=1;
if create_archive
    pack_vers='1.0';package_name=[mfilename '_package_folder_' pack_vers '/'];
    location_package=['./' package_name];
    if ~exist(location_package,'dir')
        disp('copy the following functions in the archive folder:')
        mkdir (location_package);
        [fList,pList] = matlab.codetools.requiredFilesAndProducts(mfilename);
        for i=1:size(fList,2)
            disp(fList{1,i});
            copyfile(which(fList{1,i}),location_package)
        end
    else
        [list_out]=dir(['./' mfilename '_package_folder_' pack_vers '/*.m']);
        fList=list_out;
        disp('Update the following functions in the archive folder:')
        for i=1:size(fList)
            disp(fList(i).name);
            copyfile(which(fList(i).name),location_package)
        end
    end
end

% define input
test=0;
if test
    super_base=get_super_base('500_3','brucka');%this should automatically determine the correct path to the data. Ask DJ if you get errors with the get_super_base function
    exp_name='mb_fluorene';
    list_acquno=242;
else
    super_base=get_super_base('300b','sistare');%this should automatically determine the correct path to the data. Ask DJ if you get errors with the get_super_base function
    exp_name='esg_aliasing_sign';
    list_acquno=[2:5 7:10];
    % list_acquno=10;
end
procno=2;

% define output
procno_out=3333;

for expno=list_acquno
    % check... to avoid deleting source file..
    if procno==procno_out
        error('target should not be equal to source')
    end
    
    % read the source spectrum
    spectrum=read_data_bruker([super_base exp_name '/'],expno,procno);
    
    % write modified spectra
    process(spectrum,procno_out,'xf1','proc_seed',3,'fcor',spectrum.fcor1);% middle point twice
    
    %% for archives
    %copy matlab files in brukder folders
    disp('Copy matlab functions to processed data folder:')
    disp('Copy matlab functions to processed data folder:')
    where_store=[super_base exp_name '/' num2str(expno) '/pdata/' num2str(procno_out) '/matlab_prog/'];
    disp(where_store)
    mkdir(where_store);
    copyfile(location_package,where_store);
    
    %create archived with matlab functions and spectral files
    if create_archive
        %Save matlab files and spectra
        place_to_save_package_with_spectra='/Volumes/san256/users_for_mac_system_macPro/jeannerat/Dropbox/full_archived_for_github/';
        if exist(place_to_save_package_with_spectra,'dir')
            copyfile(location_package,[place_to_save_package_with_spectra package_name]);
            mkdir([place_to_save_package_with_spectra package_name '/' exp_name])
            copyfile([super_base exp_name '/' num2str(expno)],[place_to_save_package_with_spectra package_name exp_name '/' num2str(expno)]);
        end
    end
end

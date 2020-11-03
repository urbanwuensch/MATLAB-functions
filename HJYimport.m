function [DS,DSb] = HJYimport(path,options)
% (c) Urban Wünsch
% Function to import AquaLog fluorescence tripletts.
% Apologies for the lack of a documentation. This function is still under development.
% Please contact Urban @ urbw@dtu.dk for guidance on this function.

if strcmp(path,'options')
    options=defaultoptions;
    if strcmp(path,'options')
        DS=options;
        return
    end
end

%% File discovery and diagnosis (ensures smooth procedure later on)
if not(exist(path,'dir'))
    error('Path not found.')
end
disp('  ')
disp('  ')
disp('  ')
disp('Scanning for files...')
disp('  ')
patterns=options.patterns;
files=cell(numel(patterns),1);
fnames=cell(numel(patterns),1);
for n=1:numel(patterns)
    files{n}=dir([path,filesep,patterns{n}]);
    if numel(files{n})==0
        patherror=strrep(pwd,filesep,[filesep filesep]);
        error(sprintf([' Pattern: ' patterns{n} ' \n '...
            'Folder: ' patherror '\n ' ...
            'Error: Could not find ANY files with that pattern']))
    end
    temp={files{n}(:).name}';
    temp=erase(temp,patterns{n}(2:end)); % Exclude the *
    temp=cellfun(@(x) strsplit(x,' ('),temp,'UniformOutput',false);
    fnames{n}=cellfun(@(x) x{1} , temp,'UniformOutput',false);
end
uniquefnames=unique([unique(fnames{1});unique(fnames{2});unique(fnames{3})]);
disp(['Found ',num2str(numel(uniquefnames)),' unique file identifiers. Checking for complete triplets...'])
disp('  ')
abso=false(numel(uniquefnames),1);
blan=false(numel(uniquefnames),1);
samp=false(numel(uniquefnames),1);

for n=1:numel(uniquefnames)
    abso(n,1)=any(strcmp(uniquefnames{n},fnames{1}));
    blan(n,1)=any(strcmp(uniquefnames{n},fnames{2}));
    samp(n,1)=any(strcmp(uniquefnames{n},fnames{3}));
end

importnames=uniquefnames(abso&blan&samp);

if numel(importnames)==0
    troubleshoot=table;
    troubleshoot.uniquefnames=uniquefnames;
    troubleshoot.(patterns{1})=abso;
    troubleshoot.(patterns{2})=blan;
    troubleshoot.(patterns{3})=samp;
    disp(troubleshoot)
    error('It seems as if there are NO files to import with the specified name patterns.')
end
blafiles=files{2}(contains(fnames{2},importnames));
samfiles=files{3}(contains(fnames{3},importnames));
absfiles=files{1}(contains(fnames{1},importnames));


if numel(blafiles)
end
for n=1:3
    miss=files{n}(~contains(fnames{n},importnames));
    for i=1:numel(miss)
        disp(['This existing file is missing another reqired one and will not be loaded: ',miss(i).name])
    end
end

%% Detect EEM and Abs spectra size
disp('  ')
disp('Detecting EEM and absorbance spectra size...')
disp('  ')
nfiles=numel(importnames);


% EEMs
ref=importdata([path,filesep,blafiles(1).name]);

try
    switch options.style
        case 'HJYexport'
            [eemrefdat,emref,exref] = HJYexport_fl(ref);
        case 'sampleQ'
            [eemrefdat,emref,exref] = sampleQ_fl(ref);
    end
catch
    error('Fatal error during first file import (fluorescence). Fatal because we need it to import to determine settings.')
end

if issorted(emref)
    emflip=false;
else
    emflip=true;
    emref=flipud(emref);
    eemrefdat=flipud(eemrefdat);
end

if issorted(exref)
    exflip=false;
else
    exflip=true;
    exref=flipud(exref);
    eemrefdat=fliplr(eemrefdat);
end
szeem=size(eemrefdat);



% Absorbance
% Scan for "--" in absorbance files.
for n=1:numel(absfiles)
    repairHJYabsfiles(absfiles(n).name,path)
end
try
    ref=importdata([path,filesep,absfiles(1).name]);
    switch options.style
        case 'HJYexport'
            [absdat,waveref] = HJYexport_abs(ref);
        case 'sampleQ'
            [absdat,waveref] = sampleQ_abs(ref);
    end
catch
    error('Fatal error during first file import (absorbance). Fatal because we need it to import to determine settings.')
end
if issorted(waveref)
    waveflip=false;
else
    waveflip=true;
    waveref=flipud(waveref);
end
szabs=size(absdat);

%% Import data
disp('Importing...')
disp('  ')
Xb=nan(nfiles,szeem(1),szeem(2));
Xs=nan(nfiles,szeem(1),szeem(2));
A=nan(nfiles,szabs(1));
filelist=cell(nfiles,1);
cnt=0;
del=false(nfiles,1);
hwb=waitbar(0,'Importing...');
for k=1:nfiles
    % EEM
    try
        eemdata{1}=importdata([path,filesep,blafiles(k).name]);
    catch
        disp(['File ',blafiles(k).name,' Could not be loaded. Skipped entirely...'])
        del(k,1)=true;
        continue
    end
    hwb=waitbar(k/nfiles,hwb,blafiles(k).name);
    
    try
        eemdata{2}=importdata([path,filesep,samfiles(k).name]);
    catch
        disp(['File ',samfiles(k).name,' Could not be loaded. Skipped entirely...'])
        del(k,1)=true;
        continue
    end
    hwb=waitbar(k/nfiles,hwb,samfiles(k).name);
    
    eemdat=cell(2,1);
    em=cell(2,1);
    ex=cell(2,1);
    for n=1:2
        if n==1
            fn=blafiles(k).name;
        else
            fn=samfiles(k).name;
        end

        switch options.style
            case 'HJYexport'
                [eemdat{n},em{n},ex{n}] = HJYexport_fl(eemdata{n});
            case 'sampleQ'
                [eemdat{n},em{n},ex{n}] = sampleQ_fl(eemdata{n});
        end

        % Flip wavelengths first if needed (for checks)
        if emflip
            eemdat{n}=flipud(eemdat{n});
            em{n}=flipud(em{n});
        end
        if exflip
            eemdat{n}=fliplr(eemdat{n});
            ex{n}=flipud(ex{n});
        end
        % Checks (dimensions and wavelengths)
        if ~isequal(em{n},emref)
            warning(['File ',fn,' Emission wavelength missmatch. Skipped entirely...'])
            del(k,1)=true;
            continue
        elseif ~isequal(ex{n},exref)
            warning(['File ',fn,' Excitation wavelength missmatch. Skipped entirely...'])
            del(k,1)=true;
            continue
        end
        if any(size(eemdat{n})~=szeem)
            warning(['File ',fn,' EEM size missmatch. Skipped...'])
            del(k,1)=true;
            continue
        end

    end
    if del(k,1)
        continue
    end
    Xb(k,:,:)=eemdat{1};
    Xs(k,:,:)=eemdat{2};
    
    % Absorbance
    try
        absdata=importdata([path,filesep,absfiles(k).name]);
    catch
        disp(['File ',absfiles(k).name,' Could not be loaded. Skipped entirely...'])
        del(k,1)=true;
        continue
    end
    hwb=waitbar(k/nfiles,hwb,absfiles(k).name);

    switch options.style
        case 'HJYexport'
            [absdat,wave] = HJYexport_abs(absdata);
        case 'sampleQ'
            [absdat,wave] = sampleQ_abs(absdata);
    end

    if waveflip
        absdat=flipud(absdat);
        wave=flipud(wave);
    end
    
    if ~isequal(wave,waveref)
            warning(['File ',absfiles(k).name,' Absorbance wavelength missmatch. Skipped...'])
            del(k,1)=true;
            continue
    end

    A(k,:)=absdat;
    filelist{k,1}=importnames{k};
    cnt=cnt+1;
end
close(hwb)
Xb(del,:,:)=[];
Xs(del,:,:)=[];
A(del,:,:)=[];
filelist(del)=[];
disp(['Import completed. ',num2str(cnt),' of ',num2str(nfiles),' discovered blank + sample EEMs & absorbance spectra imported.'])
disp('  ')
%% Allocate dataset & blank dataset
disp('Creating & validating the drEEM dataset structures...')
disp('  ')

DSb.X=Xb;
DSb.Ex=exref;
DSb.Em=emref;
DSb.nEx=numel(exref);
DSb.nEm=numel(emref);
DSb.nSample=size(Xb,1);
DSb.filelist=filelist;
DSb.i=(1:size(Xs,1))';
DSb.Xunit='Arbitrary fluorometer counts.';
if exist('checkdataset','file')>0
    checkdataset(DSb,'output',false)
end

DS.X=Xs;
DS.Abs=A;
DS.Ex=exref;
DS.Em=emref;
DS.nEx=numel(exref);
DS.nEm=numel(emref);
DS.Abs_wave=waveref;
DS.nSample=size(Xs,1);
DS.filelist=filelist;
DS.i=(1:size(Xs,1))';
DS.Xunit='Arbitrary fluorometer counts.';
DS.Xife='No correction by drEEM';

if exist('checkdataset','file')>0
    checkdataset(DS,'output',false)
end
disp('Data import complete.')
disp('  ')
end




function [vout] = rcvec(v,rc)
% Make row or column vector
% v: vector
% rc: either 'row' ([1:5])or 'column' ([1:5]')
sz=size(v);
if ~any(sz==1)
    error('Input is not a vector')
end

switch rc
    case 'row'
        if ~(sz(1)<sz(2))
            vout=v';
        else
            vout=v;
        end
    case 'column'
        if ~(sz(1)>sz(2))
            vout=v';
        else
            vout=v;
        end
    otherwise
            error('Input ''rc'' not recognized. Options are: ''row'' and ''column''.')
end


end

function [eem,em,ex] = HJYexport_fl(data)

if not(contains(data.textdata{2},'nm'))
    start=2;
elseif contains(data.textdata{2},'nm')
    start=3;
end
eem=data.data(start:end,1:end);
em=rcvec(cell2mat(cellfun(@(x) str2num(x),data.rowheaders,'UniformOutput',false)),'column'); %#ok<ST2NM>
ex=rcvec(data.data(1,:),'column');
end


function [absdat,wave] = HJYexport_abs(data)
absdat=data.data(:,10);
wave=data.data(:,1);
end

function [eem,em,ex] = sampleQ_fl(data)
eem=data.data(2:end,1:end);
em=rcvec(cell2mat(cellfun(@(x) str2num(x),data.rowheaders,'UniformOutput',false)),'column'); %#ok<ST2NM>
ex=rcvec(data.data(1,:),'column');
end


function [absdat,wave] = sampleQ_abs(data)
absdat=data(:,2);
wave=data(:,1);
end

function options=defaultoptions
options.patterns={'* Abs Spectra Graphs.dat';...
    '* Waterfall Plot Blank.dat';...
    '* Waterfall Plot Sample.dat'};
options.style='HJYexport';
end


function repairHJYabsfiles(file,path)
% back up old file
temp=strsplit(file,'.dat');
destination=[temp{1},'_unchanged','.dat'];

% Fix the absorbance if -- is in the file.
A = fscanf(fopen([path,filesep,file]),'%c');fclose all;
idx=strfind(A,'--');
if ~(isempty(idx))
    for n=1:numel(idx)
        A(idx(n):idx(n)+1)='  ';
    end
    copyfile([path,filesep,file],[path,filesep,destination]);
    fileID=fopen([path,filesep,file],'w');
    fprintf(fileID,'%c',A);
    fclose(fileID);
end
end

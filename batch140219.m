% PEEP
% Post processing script
% Author: Ken Hwang
% Last Updated: 2/19/2014
% Documentation here

p = mfilename('fullpath');
rootDir = fileparts(p);

outDir = [rootDir filesep 'out'];

% Parsing pertinent data
[clientF,clientP] = uigetfile('*.xlsx',rootDir); % Pull rating data
clientData = xlsread([clientP clientF]); % clientData = rating data

idCol = 1; % Column for subject ID in rating data
subj = clientData(:,idCol); % Generate subject vector

rateCol = 24:31; % Rating columns
rate = clientData(:,rateCol); % Rating data

[clientF2,clientP2] = uigetfile('*.xlsx',rootDir); % Pull filename conversion data
[clientData2num,clientData2str] = xlsread([clientP2 clientF2]); % clientData = subject ID to diary conversion

dateStringCol = 5; % Column for diary date string
dateString = clientData2str(:,dateStringCol); % Generate date string vector
dateString = dateString(2:end); % Remove headers

idCol2 = 2; % Column for subject ID
subj2 = clientData2str(:,idCol2); % Generate subject vector
subj2 = subj2(2:end); % Remove headers
subj2 = cellfun(@(y)(regexp(y,'\d{4,4}','match')),subj2); % Parse string
subj2 = cellfun(@str2double,subj2); % Convert
subj2_unique = unique(subj2);

runOrderColStr = 7; % For string values
runOrderStr = clientData2str(2:end,runOrderColStr); % Excluding headers
runOrderStr = cellfun(@str2double,runOrderStr);
runOrderColNum = 5; % Due to shifted columns in numeric data
runOrderNum = clientData2num(1:end,runOrderColNum);
runOrderNum(~isnan(runOrderStr)) = runOrderStr(~isnan(runOrderStr));
runOrder = runOrderNum;

missRating = setdiff(subj2_unique,subj); % Missing from rating sheet
missConversion = setdiff(subj,subj2_unique); % Missing from conversion sheet
availSubj = intersect(subj,subj2_unique); % First-pass filter on subject set

dataDir = uigetdir(rootDir);

[~,d] = system(['dir /a-h/b ' dataDir filesep '*.txt']);
d = regexp(d(1:end-1),'\n','split');

% CAR1_AS	CAR2_AS	CAR3_AS	CAR4_AS	CHR1_HS	CHR2_HS	CHR3_HS	CHR4_HS

% Pre-allocate by-row from conversion sheet (without missRating
% subjects; also will ignore any in missConversion);

outCell = cell([length(subj2) 8]); % 1: Subject, 2: Date string, 3: Ang text data, 4: Ang order, 5: Ang ordered rating data, 6: Hap text data, 7: Hap order, 8: Hap ordered rating data

skip = zeros([length(subj2) 1]); % Track skips
for missRate_index = 1:length(missRating)
    skip(subj2==missRating(i)) = 1;
end

% Only 2 conditions that have ratings
ang = 'ang';
hap = 'hap';

% From peep_matlab/get_peep_cond_list.m
angOrderIndex = 1:4;
hapOrderIndex = 5:8;

for i = 1:length(subj2)
    if ~skip(i) % Skip non-applicable subjects
        outCell{i,1} = subj2(i);
        tempDateString = dateString{i};
        outCell{i,2} = tempDateString;
        
        tempFiles = d(~cellfun(@isempty,cellfun(@(y)(regexp(y,tempDateString)),d,'UniformOutput',false))); % Find files by individual diary string
        tempFiles = {tempFiles{~cellfun(@isempty,cellfun(@(y)(regexp(y,ang)),tempFiles,'UniformOutput',false))}, ...
            tempFiles{~cellfun(@isempty,cellfun(@(y)(regexp(y,hap)),tempFiles,'UniformOutput',false))}}; % Grab only 2 file names, angry first, happy second
        
        outCell{i,3} = importdata([dataDir filesep tempFiles{1}]); % 1 for ang
        
        % From peep_matlab/get_peep_cond_list.m
        switch runOrder(i)
            case 0          % Default, plays in order with 15 pauses
                cond_list = [ 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 ];
            case 1
                cond_list = [ 00 09 00 06 00 03 00 10 00 07 00 04 00 11 00 08 00 01 00 12 00 05 00 02 00 09 00 ];
            case 2
                cond_list = [ 00 10 00 07 00 04	00 11 00 08 00 01 00 12 00 05 00 02 00 09 00 06 00 03 00 10 00 ];
            case 3
                cond_list = [ 00 11	00 08 00 01 00 12 00 05 00 02 00 09 00 06 00 03 00 10 00 07 00 04 00 11 00 ];
            case 4
                cond_list = [ 00 12 00 05 00 02 00 09 00 06 00 03 00 10 00 07 00 04 00 11 00 08 00 01 00 12 00 ];
            case 5
                cond_list = [ 00 09 00 02 00 07 00 10 00 03 00 08 00 11 00 04 00 05 00 12 00 01 00 06 00 09 00 ];
            case 6
                cond_list = [ 00 10 00 03 00 08 00 11 00 04 00 05 00 12 00 01 00 06 00 09 00 02 00 07 00 10 00 ];
            case 7
                cond_list = [ 00 11 00 04 00 05 00 12 00 01 00 06 00 09 00 02 00 07 00 10 00 03 00 08 00 11 00 ];
            case 8
                cond_list = [ 00 12 00 01 00 06 00 09 00 02 00 07 00 10 00 03 00 08 00 11 00 04 00 05 00 12 00 ];
            otherwise
                cond_list = [ 1 0 2 0 ];
        end % switch group
       
        [~,IA,~] = intersect(cond_list,angOrderIndex); % IA is index at which the angOrderIndex values are found
        [~,outCell{i,4}] = sort(IA); % Output sorts as: the value (from angOrderIndex) is in order in which it appeared (index) .  Read as: "[Value] (condition number) appeared at [index] (ordinal)"
        
        [~,IA2,~] = intersect(cond_list,hapOrderIndex); % IA2 is index at which the hapOrderIndex values are found
        %         [~,J2] = sort(IA2); % Output sorts as: the item (unconverted) is in order in which it appeared (index).  Read as: "[Item] (condition number unconverted) appeared at [index] (ordinal)"
        %         outCell{i,7} = hapOrderIndex(J2); % The item value converted into the actual value (from hapOrderIndex, 1=5,2=6,3=7,4=8).  Don't need to convert.  Just need index order.
        [~,outCell{i,7}] = sort(IA2);
        
        
    end
end
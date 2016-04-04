% this m-file will count up the total numbers of drops for the whole folder

dropDir = '/Volumes/RR1513_ASIRI_1/FCTD/DROP/';
dropFiles = dir([dropDir 'FCTD*.mat']);

dropMark = [];
for i = 1:numel(dropFiles)
    disp(dropFiles(i).name);
    load([dropDir dropFiles(i).name]);
    drop(drop<0) = 0;
    d_drop = diff(drop);
    d_drop(end+1) = d_drop(end);
    d_drop(d_drop<0) = 0;
    
    d_drop = sign(d_drop);
    dropMark = [dropMark; d_drop];
end

fprintf(1,'Total drop count since the begining of cruise is %d\r\n',sum(dropMark));

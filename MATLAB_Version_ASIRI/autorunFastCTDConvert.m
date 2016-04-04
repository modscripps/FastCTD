%% automation to convert ASCII 

% rawDir = '/Volumes/EquatorFlexA/FCTD/';
% rawDirAway = '/Volumes/EquatorFlexB/FCTD/RAW/';
% matDir = '/Volumes/EquatorFlexB/FCTD/MAT/';
% matDirAway = '/Volumes/scienceparty_share/FCTD/MAT/';
% pdfDir = '/Volumes/EquatorFlexB/FCTD/PDF/';
% pdfDirAway = '/Volumes/scienceparty_share/FCTD/PDF/';
% jpgDir = '/Volumes/EquatorFlexB/FCTD/JPG/';
% jpgDirAway = '/Volumes/scienceparty_share/FCTD/JPG/';
% pngDir = '/Volumes/EquatorFlexB/FCTD/PNG/';
% pngDirAway = '/Volumes/scienceparty_share/FCTD/PNG/';
% dirs = {rawDir; rawDirAway; matDir};


rawDir = '/Volumes/FCTD/RAW/';
rawDirAway = '/Volumes/RR1513_ASIRI_1/FCTD/RAW/';
matDir = '/Volumes/RR1513_ASIRI_1/FCTD/MAT/';

dirs = {rawDir; rawDirAway; matDir};

FastCTDConvert_timer = timer;
FastCTDConvert_timer_Stop = false;

FastCTDConvert_timer.StartFcn = 'disp(''Conversion of FCTD Data begins now!'');';
FastCTDConvert_timer.TimerFcn = [...
    'if FastCTDConvert_timer_Stop, '...
    'stop(FastCTDConvert_timer); '...
    'delete(FastCTDConvert_timer); '...
    'else, '...
    'disp([datestr(now) '': Coverting FCTD data...!'']); '...
    'try, '...
    'FastCTD_MakeMatFromRaw(dirs,''noGrid''); '...
    'catch err, '...
    'disp(err); '...
    'end; '...
    ...%'unix(sprintf(''/usr/bin/rsync -av %s %s'',matDir,matDirAway)); '...
    ...%'unix(sprintf(''/usr/bin/rsync -av %s %s'',pdfDir,pdfDirAway)); '...
    ...%'unix(sprintf(''/usr/bin/rsync -av %s %s'',jpgDir,jpgDirAway)); '...
    ...%'unix(sprintf(''/usr/bin/rsync -av %s %s'',pngDir,pngDirAway)); '...
    'end;'];
FastCTDConvert_timer.Period = 1;
FastCTDConvert_timer.BusyMode = 'drop';
FastCTDConvert_timer.Name = 'FastCTDConvert_timer';
FastCTDConvert_timer.Tag = 'FastCTDConvert_timer';
FastCTDConvert_timer.StopFcn = 'clear(''rawDir'',''rawDirAway'',''matDir''); disp([datestr(now) '': Stopped FastCTDConvert_timer'']);';
FastCTDConvert_timer.ExecutionMode = 'fixedSpacing';
% FastCTDConvert_timer.ExecutionMode = 'singleShot';
FastCTDConvert_timer.TasksToExecute = Inf;
FastCTDConvert_timer.ErrorFcn = 'disp(''%%%%%%%%%%%%% Error %%%%%%%%%%%%%'');';

start(FastCTDConvert_timer);
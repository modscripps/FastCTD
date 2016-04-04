clear

matDir = '/Volumes/RR1513_ASIRI_1/FCTD/MAT/';
dropDir = '/Volumes/RR1513_ASIRI_1/FCTD/DROP/';

matFiles = dir([matDir '/FCTD*.mat']);


% i = rand(1);
% i = round(i*(numel(matFiles)-1) + 1);
for i = 1:numel(matFiles)
    base = matFiles(i).name(1:end-4);
    dropFile = dir([dropDir base '.mat']);
    
    % if the MAT files are older than the data files, they will be retranslated
    if ((~isempty(dropFile) && datenum(matFiles(i).date)>datenum(dropFile.date))||isempty(dropFile))
        fprintf(1,'Calculating drop %s%s\r\n',dropDir,base);
        try            
            load([matDir matFiles(i).name]);
            
            FCTD1 = FastCTD_FindCasts(FCTD,'threshold',0.025,'downcast');
            
            if isfield(FCTD1,'drop')
                drop = FCTD1.drop;
            else
                drop = 0*FCTD1.time;
            end
            FCTD1 = FastCTD_FindCasts(FCTD,'threshold',0.025,'upcast');
            if isfield(FCTD1,'drop')
                drop = drop-FCTD1.drop;
            end
            
            if ~isempty(drop)
                if ~isempty(drop)
                    drop(end-2:end) = drop(end-3);
                end
                save([dropDir  base '.mat'],'drop');
                clear drop;
                fprintf(1,'%s: Wrote  %s\r\n',datestr(now,'YY.mm.dd HH:MM:SS'), [dropDir  base '.mat']);
            end;
            clear FCTD;
        catch err
            disp(['So... this is the error for retranlating file ' matFiles(i).name]);
            disp(err);
            for j = 1:length(err.stack)
                disp([num2str(j) ' ' err.stack(j).name ' ' num2str(err.stack(j).line)]);
            end
            break
        end
    end;
end

%%
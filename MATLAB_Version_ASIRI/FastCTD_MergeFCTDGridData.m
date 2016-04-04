function FCTD = FastCTD_MergeFCTDGridData(FCTD1, FCTD2)
%  FCTD = FastCTDMergeFCTD(FCTD1,FCTD2)
%   Merges two FCTD structures together keeping all data
%   This also assumes that both FCTD1 and FCTD2 has the same structure in
%   the organization. If not, then an error will be produced and will not
%   be warranted by the code written
%
%   FCTD1 or FCTD2 is empty then FCTD takes the form of the other one
%
%  Written by San Nguyen 2011/07/01

if nargin ~= 2
    error('Must pass in two FCTD structures to merge');
end

if isempty(FCTD1)
    FCTD = FCTD2;
    return;
end

if isempty(FCTD2)
    FCTD = FCTD1;
    return;
end

fNames = fieldnames(FCTD1);

for i = 1:length(fNames)
    
    if isempty(FCTD1.(fNames{i}))
        if isempty(FCTD2.(fNames{i}))
            FCTD.(fNames{i}) = [];
        else
            FCTD.(fNames{i}) = FCTD2.(fNames{i});
        end
        
    % if struct, recurse
    elseif isstruct(FCTD1.(fNames{i})) 
        FCTD.(fNames{i}) = FastCTD_MergeFCTDGridData(FCTD1.(fNames{i}),FCTD2.(fNames{i}));

    % if it is an scalar or an matrix of number
    elseif isnumeric(FCTD1.(fNames{i}))
        if strcmpi(fNames{i},'depth')
            FCTD.depth = FCTD1.depth;
            continue;
        end
        if length(FCTD1.(fNames{i})) > 1
            FCTD.(fNames{i}) = [FCTD1.(fNames{i}) FCTD2.(fNames{i})];
        elseif ~isempty(FCTD2.(fNames{i}))
                FCTD.(fNames{i}) = [FCTD1.(fNames{i}) FCTD2.(fNames{i})];
        end
    else
        FCTD.(fNames{i}) = [];
    end 
end
return;

end


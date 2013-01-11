function f = ctor(f,varargin)
% CTOR  Chebfun Constructor
% See also CHEBFUN

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

nin = numel(varargin);

% No arguments -> return empty chebfun
if nin == 0;
    f.ID = newIDnum();
    return
end

% Chebfun preferences:
if isstruct(varargin{nin}) && (nin>1 && ~strcmpi(varargin{nin-1},'map'))
    pref = varargin{nin};
    argin = varargin(1:end-1);
else
    pref = chebfunpref;
    % Find out if call changes preferences
    argin = varargin(1);
    k = 2; j = 2;
    while k <= nin
        if ischar(varargin{k})
            varargin{k} = lower(varargin{k});
            
            % If ON or OFF used -> change to true or false
            if k < nin
                value = varargin{k+1};
                if strcmpi(value,'on')       value = true;
                elseif strcmpi(value,'off')  value = false;
                end
            end
            if strcmpi('factory',varargin{k})
                pref = chebfunpref('factory');
                k = k+1;
            elseif any(strcmpi({'chebkind','kind'},varargin{k}))
                if      strncmpi(value,'1st',1), value = 1;
                elseif  strncmpi(value,'2nd',1), value = 2; end
                if isfield(pref,'coeffs'), 
                    pref.coeffkind = value;
                    pref.chebkind = 2;
                else
                    pref.chebkind = value;
                end
                if value == 1 && ~pref.resampling
                    pref.resampling = 1;
%                     warning('CHEBFUN:chebfun:resampling',...
%                         'Switching to RESAMPLING ON mode, (Chebyshev points of 1st-kind requested)');
                end
                k = k+2; 
            elseif  any(strcmp(fieldnames(pref),varargin{k}))
                % Is the argument a preference name?
                if ischar(value)
                    % Factory values from chebfunpref
                    if strcmpi(value,'factory')
                        value = chebfunpref(varargin{k},'factory');
                    else
                        error('CHEBFUN:chebfun:prefval', ...
                            'Invalid chebfun preference value.')
                    end
                end
                pref.(varargin{k}) = value;
                k = k+2;
            elseif strcmpi('map',varargin{k})
                pref.map =  value;
                k = k+2;             
            elseif strcmpi('exps',varargin{k})
                pref.exps = value;
                k = k+2;
            elseif strncmpi('vectori',varargin{k},7)
                pref.vectorize = 0;
                k = k+1; 
            elseif strncmpi('sys',varargin{k},3)
                pref.syssize = value;
                k = k+2; 
            elseif strncmpi('coeff',varargin{k},4)
                pref.coeffs = 1; 
                if ~isfield(pref,'coeffkind'), pref.coeffkind = 1; end
                k = k+1; 
            elseif strncmpi('trunc',varargin{k},5)
                pref.trunc = value;
                if pref.trunc, pref.splitting = true; end
                k = k+2;                 
            elseif strcmpi('vectorcheck',varargin{k})
                pref.vectorcheck = value;
                k = k+2;                  
            elseif strncmpi('extrap',varargin{k},6)
                pref.extrapolate = value;
                k = k+2;     
            elseif strcmpi('simplify',varargin{k})
                pref.simplify = value;
                k = k+2;           
            elseif strcmpi('length',varargin{k}) || strcmpi('n',varargin{k})
                pref.n = value;
                k = k+2;
            elseif strcmpi('scale',varargin{k}) || strcmpi('scl',varargin{k})
                pref.scale = value;
                k = k+2;                       
            elseif strcmpi('singmap',varargin{k})
                pref.sings = value;
                k = k+2;               
            else
                argin{j} = varargin{k};
                j = j+1; k = k+1;
            end
        else
            argin{j} = varargin{k};
            j = j+1; k = k+1;
        end
    end
end

% Deal with singmaps
if isfield(pref,'sings')
    if isfield(pref,'map'),
        warning('CHEBFUN:chebfun:singmap','Map is being overridden by singmap.');
    end
    pref.map = {'sing',pref.sings};
    pref = rmfield(pref,'sings');
end

% Get domain
if length(argin) == 1,
    if isa(argin{1},'fun')
        argin{2} = argin{1}.map.par(1:2);
    else
        argin{2} = double(pref.domain);
    end
elseif isa(argin{2},'domain')
    argin{2} = double(argin{2});
end

% Deal with nonadaptive calls using 'degree'.
if isfield(pref,'n')
    argin = [argin {pref.n}];
    pref = rmfield(pref,'n');
end

% Deal with multiple function inputs.
if ~iscell(argin{1}) && ~iscell(argin{2})
    argin = unwrap_arg(argin{:});
end

if isfield(pref,'syssize') && ~iscell(argin{2})
    if isa(argin{2},'domain') || (isnumeric(argin{2}) && numel(argin{2}) > 1)
        argin{2} = repmat({argin{2}},1,pref.syssize);
    else
        domain = chebfunpref('domain');
        argin{2} = repmat({domain},1,pref.syssize);
    end
end
    
if iscell(argin{2})
    if numel(argin) >= 3, pref.n = argin{3}; argin(3:end) = []; end
    f = autosys(argin{:},pref);
    if iscell(f) && numel(f) == 1
        f = f{:};
    end
    
    % 'Truncate' option
    if isfield(pref,'trunc')
        warning('CHEBFUN:chebfun:truncsys',...
            'Truncation is not supported for systems.');
    end
    return
end

% Construct chebfun
if length(argin) == 2,
    f = ctor_adapt(f,argin{:},pref);        % adaptive call
elseif length(argin) == 3,
    f = ctor_nonadapt(f,argin{:},pref);     % non-adaptive call
else
    error('CHEBFUN:chebfun:nargin','Unrecognised input sequence.');
end

if iscell(f)
    % 'Truncate' option
    if isfield(pref,'trunc')
        warning('CHEBFUN:chebfun:truncsys',...
            'Truncation is not supported for systems.');
    end
    return
end
    
% Prune repeated endpoints and assign values to the imps matrix
if numel(f) == 1 && f.nfuns > 1 && any(diff(f.ends) == 0)
    k = 1;
    while k < length(f.ends)
        if diff(f.ends(k:k+1)) == 0
            f.ends(k+1) = [];
            f.imps(k+1) = [];
            f.nfuns = f.nfuns - 1;
            f.imps(1,k) = f.funs(k).vals(1);
            f.funs(k) = [];
        else
            k = k+1;
        end
    end
end

% 'Truncate' option
if isfield(pref,'trunc')
    if numel(f) > 1
        error('CHEBFUN:trunc:quasi',...
            '''trunc'' flag does not support matrix input');
    end
    c = chebpoly(f,0,pref.trunc);
    f = chebfun(chebpolyval(c),f.ends([1 end]));
end

end


function N = set(N,varargin)
%SET   Set chebop properties.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case {'dom','domain'}
            if ~isa(val,'domain'), val = domain(val); end
            N.domain = val;
        case 'bc'
            N.bc = [];  N.bcshow = [];
            if isa(val,'struct')  % given .left and .right
                if isfield(val,'left')
                    N = set(N,'lbc',val.left);
                end
                if isfield(val,'right')
                    N = set(N,'rbc',val.right);
                end
                if isfield(val,'bc')
                    N = set(N,'bc',val.bc);
                end                
            elseif isa(val,'function_handle') || isa(val,'cell')
                N.bc = val;
                N.bcshow = val;
            elseif strcmpi(val,'periodic')
                N.bc = createbc('periodic',N.numvar);
                N.bcshow = 'periodic';
                N.lbc = []; N.lbcshow = [];
                N.rbc = []; N.rbcshow = [];
            else % given same for both sides
                bc = createbc(val,N.numvar);
                N.lbc = bc;
                N.lbcshow = val;
                N.rbc = bc;
                N.rbcshow = val; 
            end
        case 'lbc'
            if strcmpi(val,'periodic')
                N.bc = createbc('periodic',N.numvar);
                N.bcshow = 'periodic';
                N.lbc = []; N.lbcshow = [];
                N.rbc = []; N.rbcshow = [];
            else
                N.lbc = createbc(val,N.numvar);
                N.lbcshow = val;
            end
        case 'rbc'
            if strcmpi(val,'periodic')
                N.bc = createbc('periodic',N.numvar);
                N.bcshow = 'periodic';
                N.lbc = []; N.lbcshow = [];
                N.rbc = []; N.rbcshow = [];
            else
                N.rbc = createbc(val,N.numvar);
                N.rbcshow = val;
            end
        case 'op'
            if isa(val,'function_handle') || (iscell(val) && isa(val{1},'function_handle')) ...
                    || isa(val,'linop') || (isa(val,'cell') && isa(val{1},'linop'))
                % Do nothing
            else
                error('CHEBOP:set:opType','Operator must by a function handle or linop.')
            end
            N.op = val;
            N.numvar = nargin(val);
            if ~iscell(val)
                N.opshow = {char(val)};
            else
                N.opshow = cellfun(@char,val,'uniform',false);
            end
        case 'opshow'            
            N.opshow = {char(val)};
        case 'jumplocs'            
            N.jumplocs = val;            
        case {'guess','init'}
            % Convert constant initial guesses to chebfuns
            if isnumeric(val)
                u = chebfun;
                for k = 1:size(val,2)
                    u(:,k) = chebfun(val(:,k),N.domain);
                end
                N.init = u;
            else
                N.init = val;
            end
        case 'scale'
            % Sets the dimension of the quasimatrices N operates on
            N.scale = val;
        case 'dim'
            % Sets the dimension of the quasimatrices N operates on
            N.dim = val;
        otherwise
            error('CHEBOP:set:unknownprop','Unknown chebop property')
    end
end
end

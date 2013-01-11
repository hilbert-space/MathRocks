function NewInputArg = unwrap_arg(varargin)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if length(varargin) == 2
    var2 = varargin{2};
    if ~isnumeric(var2)
        if isa(var2,'domain')
        % Deal with the domain class
            var2 = double(var2);
        elseif ~iscell(var2)
        % If the last argument isn't a domain or a vector, there's a problem.
            error('CHEBFUN:unwraparg:inseq', ['Unrecognized input sequence: ',...
                ' Last input argument was recognized neither as the vector of',...
                ' endpoints nor as the vector of Chebyshev points.'])
        end
    end
    if length(var2) == 2
        NewInputArg = {varargin(1), var2};
    elseif length(var2) == 1
        NewInputArg = {varargin(1), chebfunpref('domain'), var2};
    else
        % RodP introduced this here for calls like: chebfun(@sign,[-1 0 1])
        % It repeats the op found in varargin{1}. (Which will only be a
        % single op, as unwrap_arg is not called if argin{1} is cell array).
        ops = cell(1,length(var2)-1);
        for k = 1:length(var2)-1, ops(k) = varargin(1); end
        NewInputArg = {ops, var2};
    end
else % More than 2 inputs
    varend = varargin{end};
    if ~isnumeric(varend)
        if isa(varend,'domain')
        % Deal with the domain class
            varend = double(varend);
        else
        % If the last argument isn't a domain or a vector, there's a problem.
            error('CHEBFUN:unwraparg:inseq2', ['Unrecognized input sequence: ',...
                ' Last input argument was recognized neither as the vector of',...
                ' endpoints nor as the vector of Chebyshev points. (2)'])
        end
    end
    if length(varend) == length(varargin) 
    % The length of varend is one more than the number of ops, so we're happy.
        NewInputArg = {varargin(1:end-1), varend};
    elseif length(varend) == length(varargin)-2 || length(varend) == 1
    % This might be a non-adaptive call. Check to see if varend is a list of N
        varend2 = varargin{end-1};
        if ~isnumeric(varend2)
            if isa(varend2,'domain')
            % Deal with the domain class
                varend2 = double(varend2);
            else
                error('CHEBFUN:unwraparg:inseq3', ['Unrecognized input sequence: ',...
                    ' Last input argument was recognized neither as the vector of',...
                    ' endpoints nor as the vector of Chebyshev points. (3)'])
            end
        end
        % The length of varend2 is now one more than the number of ops, so we're happy.
        if length(varend2) ~= length(varargin)-1
            if length(varend)~=1,
                error('CHEBFUN:unwraparg:inseq4', ['Unrecognized input sequence: ',...
                    ' Intervals should be specified when defining the chebfun with two', ...
                    ' or more funs. (4)']);
            elseif length(varargin(1:end-2))==1
                ops = cell(1,length(varend)-1);
                for k = 1:length(varend2)-1, ops(k) = varargin(1); end
                varargin = [ops varargin(end-1:end)];
            end
        end
        NewInputArg = {varargin(1:end-2), varend2, varend};
%     elseif ~iscell(var2)
    else
        %         NewInputArg = unwrap_arg(varargin{1:end-2},varend,varargin{end-1});
        error('CHEBFUN:unwraparg:inseq5', ['Unrecognized input sequence: ',...
            ' Intervals should be specified when defining the chebfun with two', ...
            ' or more funs. (Perhaps ENDS and N are in the incorrect order?)']);
    end
end